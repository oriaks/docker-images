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
  if [ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem -o ! -f /etc/ssl/private/ssl-cert-snakeoil.key ]; then
    dpkg-reconfigure ssl-cert
  fi

  if [ ! `find /var/www/html -type f | wc -l` -gt 0 ]; then
    chown --reference /var/www/html.default /var/www/html
    chmod --reference /var/www/html.default /var/www/html
    cp -Rp /var/www/html.default/* /var/www/html/
  fi

  . /etc/apache2/envvars

  mkdir -p "${APACHE_LOCK_DIR}"
  mkdir -p "${APACHE_RUN_DIR}"

  rm -f "${APACHE_PID_FILE}"
fi

exec "$@"
