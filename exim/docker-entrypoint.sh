#!/bin/bash

PROCNAME='exim4'
DAEMON='/usr/sbin/exim4'
DAEMON_ARGS=( -bd -q30m -v )

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
  export SMTP_MAILNAME="${SMTP_MAILNAME:=${HOSTNAME}}"
  export SMTP_RELAY="${SMTP_RELAY:=`ip addr show dev eth0 | awk '$1 == "inet" { print $2 }'`}"

  if [ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem -o ! -f /etc/ssl/private/ssl-cert-snakeoil.key ]; then
    dpkg-reconfigure ssl-cert
  fi

  echo "${SMTP_MAILNAME}" > /etc/mailname
  sed -i "s|^dc_relay_nets=.*|dc_relay_nets='${SMTP_RELAY}'|;" /etc/exim4/update-exim4.conf.conf

  update-exim4.conf -v
fi

exec "$@"
