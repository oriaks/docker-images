#!/bin/bash

PROCNAME='node'
DAEMON='/usr/bin/node'
DAEMON_ARGS=( /opt/etherpad/node_modules/ep_etherpad-lite/node/server.js --root )

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
  export DB_HOST="${DB_HOST:=mysql}"
  export DB_NAME="${DB_NAME:=${MYSQL_ENV_MYSQL_DATABASE}}"
  export DB_PASSWORD="${DB_PASSWORD:=${MYSQL_ENV_MYSQL_PASSWORD}}"
  export DB_USER="${DB_USER:=${MYSQL_ENV_MYSQL_USER}}"
fi

exec "$@"
