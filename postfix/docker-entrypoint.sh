#!/bin/bash

PROCNAME='master'
DAEMON='/usr/lib/postfix/master'
DAEMON_ARGS=( -d )

if [ -z "$1" ]; then
  set -- "${DAEMON}" "${DAEMON_ARGS[@]}"
elif [ "${1:0:1}" = '-' ]; then
  set -- "${DAEMON}" "$@"
elif [ "${1}" = "${PROCNAME}" ]; then
  shift
  if [ -n "${1}" ]; then
    set -- "${DAEMON}" "$@"
  else
    set -- "${DAEMON}" "${DAEMON_ARGS[@]}"
  fi
fi

if [ "$1" = "${DAEMON}" ]; then
  export LDAP_DOMAIN="${LDAP_DOMAIN:=${LDAP_ENV_LDAP_DOMAIN}}"
  export LDAP_USER="${LDAP_USER:=cn=admin,${LDAP_BASE_DN}}"
  export LDAP_PASSWORD="${LDAP_PASSWORD:=${LDAP_ENV_LDAP_PASSWORD}}"
  export SMTP_MAILNAME="${SMTP_MAILNAME:=${HOSTNAME}}"

  export LDAP_BASE_DN="${LDAP_BASE_DN:=dc=${LDAP_DOMAIN//\./,dc=}}"

  if [ -f /var/lib/ssl/cert.pem -a -f /var/lib/ssl/privkey.pem ]; then
    export SSL_CERT='/var/lib/ssl/cert.pem'
    export SSL_KEY='/var/lib/ssl/privkey.pem'
  else
    if [ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem -o ! -f /etc/ssl/private/ssl-cert-snakeoil.key ]; then
      dpkg-reconfigure ssl-cert
    fi
    export SSL_CERT='/etc/ssl/certs/ssl-cert-snakeoil.pem'
    export SSL_KEY='/etc/ssl/private/ssl-cert-snakeoil.key'
  fi

  postconf -e "myhostname = ${SMTP_MAILNAME}"
  postconf -e "smtpd_sender_login_maps = proxy:ldap:/etc/postfix/login-maps.d/${LDAP_DOMAIN}"
  postconf -e "smtpd_tls_cert_file = ${SSL_CERT}"
  postconf -e "smtpd_tls_key_file = ${SSL_KEY}"
  postconf -e "virtual_alias_maps = proxy:ldap:/etc/postfix/aliases.d/${LDAP_DOMAIN}"

  echo "${LDAP_DOMAIN} OK" > /etc/postfix/virtual_domains
  postmap /etc/postfix/virtual_domains

  mkdir -p /etc/postfix/aliases.d
  cat > "/etc/postfix/aliases.d/${LDAP_DOMAIN}" <<- EOF
	bind = yes
	bind_dn = ${LDAP_USER}
	bind_pw = ${LDAP_PASSWORD}
	domain = ${LDAP_DOMAIN}
	query_filter = (&(objectClass=user)(otherMailbox=%s))
	result_attribute = mail
	search_base = ${LDAP_BASE_DN}
	server_host = ldap
	start_tls = yes
	version = 3
EOF

  mkdir -p /etc/postfix/login-maps.d
  cat > "/etc/postfix/login-maps.d/${LDAP_DOMAIN}" <<- EOF
	bind = yes
	bind_dn = ${LDAP_USER}
	bind_pw = ${LDAP_PASSWORD}
	domain = ${LDAP_DOMAIN}
	query_filter = (&(objectClass=user)(|(mail=%s)(otherMailbox=%s)))
	result_attribute = userPrincipalName
	search_base = ${LDAP_BASE_DN}
	server_host = ldap
	start_tls = yes
	version = 3
EOF

  /usr/sbin/rsyslogd
fi

exec "$@"
