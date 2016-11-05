#!/bin/bash

PROCNAME='run.py'
DAEMON='/opt/powerdns-admin/run.py'
DAEMON_ARGS=( )

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
  cd /opt/powerdns-admin
  source ./flask/bin/activate
  ./create_db.py
fi

exec "$@"
