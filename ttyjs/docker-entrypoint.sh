#!/bin/bash

PROCNAME='tty.js'
DAEMON='/usr/bin/tty.js'
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
  export TTY_PASSWORD="${TTY_PASSWORD:=}"
  export TTY_SHELL="${TTY_SHELL:=/bin/bash}"
  export TTY_USER="${TTY_USER:=root}"

  if [ -n "${TTY_USER}" ]; then
    if ! getent passwd "${TTY_USER}" >/dev/null 2>&1; then
      useradd -d "/home/${TTY_USER}" -m -s "${TTY_SHELL}" -U "${TTY_USER}"
    fi
    if [ -n "${TTY_PASSWORD}" ]; then
      echo "${TTY_USER}:${TTY_PASSWORD}" | chpasswd -c SHA256
    fi
  fi
fi

exec "$@"
