#!/bin/bash

PROCNAME='apache2'
DAEMON='/usr/sbin/apache2'
DAEMON_ARGS=( -DFOREGROUND -k start )

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
