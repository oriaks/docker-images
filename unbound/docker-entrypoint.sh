#!/bin/bash

PROCNAME='unbound'
DAEMON='/usr/sbin/unbound'
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
  if [ ! -f /etc/unbound/unbound_control.key -o ! -f /etc/unbound/unbound_control.pem -o ! -f /etc/unbound/unbound_server.key -o ! -f /etc/unbound/unbound_server.pem ]; then
    dpkg-reconfigure unbound
  fi
fi

exec "$@"
