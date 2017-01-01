#!/bin/bash

PROCNAME='java'
DAEMON='/usr/bin/java'
DAEMON_ARGS=( -Xmx1024M -jar /usr/lib/unifi/lib/ace.jar start )

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

exec "$@"
