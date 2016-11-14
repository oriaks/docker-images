#!/bin/bash

PROCNAME='redis-server'
DAEMON='/usr/local/bin/redis-server'
DAEMON_ARGS=( /opt/redis/redis.conf )

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
   # unused for now
   echo "standalone configuration..."
   echo "protected-mode set to no"
fi

exec "$@"
