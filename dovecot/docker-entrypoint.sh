#!/bin/bash

PROCNAME='dovecot'
DAEMON='/usr/sbin/dovecot'
DAEMON_ARGS=( -c /etc/dovecot/dovecot.conf -F )

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
  export DOVECOT_POSTMASTER="${DOVECOT_POSTMASTER:=postmaster@localhost}"
  export LDAP_DOMAIN="${LDAP_DOMAIN:=${LDAP_ENV_LDAP_DOMAIN}}"
  export LDAP_USER="${LDAP_USER:=cn=admin,${LDAP_BASE_DN}}"
  export LDAP_PASSWORD="${LDAP_PASSWORD:=${LDAP_ENV_LDAP_PASSWORD}}"

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

  sed -i -f- /etc/dovecot/conf.d/10-ssl.conf <<- EOF
	s|^postmaster_address =.*|postmaster_address = ${DOVECOT_POSTMASTER}|;
	s|^ssl_cert =.*|ssl_cert = <${SSL_CERT}|;
	s|^ssl_key =.*|ssl_key = <${SSL_KEY}|;
EOF

  sed -i -f- /etc/dovecot/conf.d/15-lda.conf <<- EOF
	s|^postmaster_address =.*|postmaster_address = ${DOVECOT_POSTMASTER}|;
EOF

  sed -i -f- /etc/dovecot/dovecot-ldap.conf.ext <<- EOF
	s|^auth_bind_userdn =.*|auth_bind_userdn = cn=%n,cn=users,${LDAP_BASE_DN}|;
	s|^base =.*|base = ${LDAP_BASE_DN}|;
	s|^dn =.*|dn = ${LDAP_USER}|;
	s|^dnpass =.*|dnpass = ${LDAP_PASSWORD}|;
EOF

fi

exec "$@"
