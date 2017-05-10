#!/bin/bash
set -x

PROCNAME='sogod'
DAEMON='/usr/sbin/sogod'
DAEMON_ARGS=( -WOWorkersCount 3 )
DAEMON_USER='sogo'

HTTPD_PROCNAME='apache2'
HTTPD_DAEMON='/usr/sbin/apache2'
HTTPD_DAEMON_ARGS=( -DFOREGROUND -k start )

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
elif [ "${1}" = "${HTTPD_PROCNAME}" ]; then
  shift
  if [ -n "${1}" ]; then
    set -- "${HTTPD_DAEMON}" "$@"
  else
    set -- "${HTTPD_DAEMON}" "${HTTPD_DAEMON_ARGS[@]}"
  fi
fi

if [ "$1" = "${DAEMON}" ]; then
  export LDAP_DOMAIN="${LDAP_DOMAIN:=${LDAP_ENV_LDAP_DOMAIN}}"

  export LDAP_BASE_DN="${LDAP_BASE_DN:=dc=${LDAP_DOMAIN//\./,dc=}}"
  export LDAP_USER="${LDAP_USER:=cn=administrator,cn=users,${LDAP_BASE_DN}}"
  export LDAP_PASSWORD="${LDAP_PASSWORD:=${LDAP_ENV_LDAP_PASSWORD}}"
  export MYSQL_DATABASE="${MYSQL_DATABASE:=${MYSQL_ENV_MYSQL_DATABASE}}"
  export MYSQL_PASSWORD="${MYSQL_PASSWORD:=${MYSQL_ENV_MYSQL_PASSWORD}}"
  export MYSQL_USER="${MYSQL_USER:=${MYSQL_ENV_MYSQL_USER}}"
  export SOGO_DOMAIN="${SOGO_DOMAIN:=test.com}"
  export SOGO_LANG="${SOGO_LANG:=English}"
  export SOGO_TIMEZONE="${SOGO_TIMEZONE:=America/Toronto}"
  export SOGO_TITLE="${SOGO_TITLE:=SOGo}"

  sed -i -f- /etc/sogo/sogo.conf <<- EOF
	s|^\([[:space:]]*SOGoProfileURL\) =.*|\1 = "mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@mysql:3306/${MYSQL_DATABASE}/sogo_user_profile";|;
	s|^\([[:space:]]*OCSFolderInfoURL\) =.*|\1 = "mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@mysql:3306/${MYSQL_DATABASE}/sogo_folder_info";|;
	s|^\([[:space:]]*OCSSessionsFolderURL\) =.*|\1 = "mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@mysql:3306/${MYSQL_DATABASE}/sogo_sessions_folder";|;
	s|^\([[:space:]]*SOGoMailDomain\) =.*|\1 = ${SOGO_DOMAIN};|;
	s|^\([[:space:]]*baseDN\) =.*|\1 = "${LDAP_BASE_DN}";|;
	s|^\([[:space:]]*bindDN\) =.*|\1 = "${LDAP_USER}";|;
	s|^\([[:space:]]*bindPassword\) =.*|\1 = ${LDAP_PASSWORD};|;
	s|^\([[:space:]]*SOGoPageTitle\) =.*|\1 = ${SOGO_TITLE};|;
	s|^\([[:space:]]*SOGoLanguage\) =.*|\1 = ${SOGO_LANG};|;
	s|^\([[:space:]]*SOGoTimeZone\) =.*|\1 = ${SOGO_TIMEZONE};|;
EOF

  if [ `id -u` = '0' ]; then
    set -- gosu "${DAEMON_USER}" "$@"
  fi
fi

if [ "$1" = "${HTTPD_DAEMON}" ]; then
  export MAIL_FROM="${MAIL_FROM:=}"
  export MAIL_HOST="${MAIL_HOST:=smtp}"
  export MAIL_PASSWORD="${MAIL_PASSWORD:=}"
  export MAIL_STARTTLS="${MAIL_STARTTLS:=NO}"
  export MAIL_TLS="${MAIL_TLS:=NO}"
  export MAIL_USER="${MAIL_USER:=}"
  export VIRTUAL_HOST="${VIRTUAL_HOST:=}"

  if [ -z "${MAIL_PORT}" ]; then
    if [ "${MAIL_STARTTLS}" = "YES" ]; then
      export MAIL_PORT='587'
    elif [ "${MAIL_TLS}" = "YES" ]; then
      export MAIL_PORT='465'
    else
      export MAIL_PORT='25'
    fi
  fi

  if [ "${MAIL_STARTTLS}" = "YES" ]; then
    export MAIL_TLS='YES'
  fi

  if [ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem -o ! -f /etc/ssl/private/ssl-cert-snakeoil.key ]; then
    dpkg-reconfigure ssl-cert
  fi

  SSMTP=()
  REVALIASES=()

  [ -n "${MAIL_FROM}"     ] && REVALIASES+=( "root:${MAIL_FROM}" "www-data:${MAIL_FROM}" )
  [ -n "${MAIL_HOST}"     ] && SSMTP+=( "mailhub=${MAIL_HOST}:${MAIL_PORT}" )
  [ -n "${MAIL_PASSWORD}" ] && SSMTP+=( "AuthPass=${MAIL_PASSWORD}" )
  [ -n "${MAIL_STARTTLS}" ] && SSMTP+=( "UseSTARTTLS=${MAIL_STARTTLS}" )
  [ -n "${MAIL_TLS}"      ] && SSMTP+=( "UseTLS=${MAIL_TLS}" )
  [ -n "${MAIL_USER}"     ] && SSMTP+=( "AuthUser=${MAIL_USER}" )
  [ -n "${VIRTUAL_HOST}"  ] && SSMTP+=( "hostname=${VIRTUAL_HOST%%,*}" )

  SSMTP+=( "FromLineOverride=YES" )

  printf "%s\n" "${REVALIASES[@]}" > /etc/ssmtp/revaliases
  printf "%s\n" "${SSMTP[@]}" > /etc/ssmtp/ssmtp.conf

  . /etc/apache2/envvars

  mkdir -p "${APACHE_LOCK_DIR}"
  mkdir -p "${APACHE_RUN_DIR}"

  rm -f "${APACHE_PID_FILE}"
fi

exec "$@"
