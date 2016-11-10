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
  export SMTP_FROM="${SMTP_FROM:=}"
  export SMTP_HOST="${SMTP_HOST:=smtp}"
  export SMTP_PASSWORD="${SMTP_PASSWORD:=}"
  export SMTP_STARTTLS="${SMTP_STARTTLS:=NO}"
  export SMTP_TLS="${SMTP_TLS:=NO}"
  export SMTP_USER="${SMTP_USER:=}"
  export VIRTUAL_HOST="${VIRTUAL_HOST:=}"

  if [ -z "${SMTP_PORT}" ]; then
    if [ "${SMTP_STARTTLS}" = "YES" ]; then
      export SMTP_PORT='587'
    elif [ "${SMTP_TLS}" = "YES" ]; then
      export SMTP_PORT='465'
    else
      export SMTP_PORT='25'
    fi
  fi

  if [ "${SMTP_STARTTLS}" = "YES" ]; then
    export SMTP_TLS='YES'
  fi

  if [ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem -o ! -f /etc/ssl/private/ssl-cert-snakeoil.key ]; then
    dpkg-reconfigure ssl-cert
  fi

  SSMTP=()
  REVALIASES=()

  [ -n "${SMTP_FROM}"     ] && REVALIASES+=( "root:${SMTP_FROM}" "www-data:${SMTP_FROM}" )
  [ -n "${SMTP_HOST}"     ] && SSMTP+=( "mailhub=${SMTP_HOST}:${SMTP_PORT}" )
  [ -n "${SMTP_PASSWORD}" ] && SSMTP+=( "AuthPass=${SMTP_PASSWORD}" )
  [ -n "${SMTP_STARTTLS}" ] && SSMTP+=( "UseSTARTTLS=${SMTP_STARTTLS}" )
  [ -n "${SMTP_TLS}"      ] && SSMTP+=( "UseTLS=${SMTP_TLS}" )
  [ -n "${SMTP_USER}"     ] && SSMTP+=( "AuthUser=${SMTP_USER}" )
  [ -n "${VIRTUAL_HOST}"  ] && SSMTP+=( "hostname=${VIRTUAL_HOST}" )

  printf "%s\n" "${REVALIASES[@]}" > /etc/ssmtp/revaliases
  printf "%s\n" "${SSMTP[@]}" > /etc/ssmtp/ssmtp.conf

  . /etc/apache2/envvars

  mkdir -p "${APACHE_LOCK_DIR}"
  mkdir -p "${APACHE_RUN_DIR}"

  rm -f "${APACHE_PID_FILE}"
fi

exec "$@"
