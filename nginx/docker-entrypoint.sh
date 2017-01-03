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

  if [ ! -e /etc/nginx/cert.d/default/cert.pem -o ! -e /etc/nginx/cert.d/default/privkey.pem ]; then
    mkdir -p /etc/nginx/cert.d/default
    ln -sf /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/nginx/cert.d/default/cert.pem
    ln -sf /etc/ssl/private/ssl-cert-snakeoil.key /etc/nginx/cert.d/default/privkey.pem
  fi

  for CERT in /etc/letsencrypt/live/*; do
    if [ ! -d "/etc/nginx/cert.d/${CERT##*/}" ]; then
      ln -s "${CERT}" "/etc/nginx/cert.d/${CERT##*/}"
    fi
  done
fi

exec "$@"
