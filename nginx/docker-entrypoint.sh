#!/bin/bash

PROCNAME='nginx'
DAEMON='/usr/sbin/nginx'
DAEMON_ARGS=( -g 'daemon off;' )

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
    chown --reference /usr/share/nginx/html /var/www/html
    chmod --reference /usr/share/nginx/html /var/www/html
    cp -Rp /usr/share/nginx/html/* /var/www/html/
  fi
fi

exec "$@"
