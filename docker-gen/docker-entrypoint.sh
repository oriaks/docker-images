#!/bin/bash

PROCNAME='docker-gen'
DAEMON='/usr/local/bin/docker-gen'

if [ -z "$1" ]; then
  set -- "${DAEMON}"
elif [ "${1:0:1}" = '-' ]; then
  set -- "${DAEMON}" "$@"
elif [ "$1" = "${PROCNAME}" ]; then
  shift
  if [ -n "${1}" ]; then
    set -- "${DAEMON}" "$@"
  else
    set -- "${DAEMON}"
  fi
fi

if [ "$1" = "${DAEMON}" ]; then
  for i; do
    shift
    if [ "$previous" = '-notify-sighup' ]; then
      set -- "$@" `awk "{if (\\$2==\"$i\") print \\$3}" /etc/hosts`
    else
      set -- "$@" "$i"
    fi
    previous="$i"
  done
fi

exec "$@"
