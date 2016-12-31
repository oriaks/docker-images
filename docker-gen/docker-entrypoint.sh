#!/bin/bash

PROCNAME='docker-gen'
DAEMON='/usr/local/bin/docker-gen'
DAEMON_ARGS=( -config /etc/docker-gen/docker-gen.cfg )

if [ -z "$1" ]; then
  set -- "${DAEMON}" "${DAEMON_ARGS[@]}"
elif [ "${1:0:1}" = '-' ]; then
  set -- "${DAEMON}" "$@"
elif [ "$1" = "${PROCNAME}" ]; then
  shift
  if [ -n "${1}" ]; then
    set -- "${DAEMON}" "$@"
  else
    set -- "${DAEMON}" "${DAEMON_ARGS[@]}"
  fi
fi

exec "$@"
