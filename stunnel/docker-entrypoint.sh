#!/bin/bash

PROCNAME='stunnel4'
DAEMON='/usr/bin/stunnel4'
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
  export STUNNEL_ACCEPT="${STUNNEL_ACCEPT:=}"
  export STUNNEL_CLIENT="${STUNNEL_CLIENT:='yes'}"
  export STUNNEL_CONNECT="${STUNNEL_CONNECT:=}"
  export STUNNEL_SERVICE="${STUNNEL_SERVICE:='default'}"

  if [ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem -o ! -f /etc/ssl/private/ssl-cert-snakeoil.key ]; then
    dpkg-reconfigure ssl-cert
  fi

  if [ -n "${STUNNEL_ACCEPT}" -a -n "${STUNNEL_CONNECT}" ]; then
    cat >> "/etc/stunnel/conf.d/${STUNNEL_SERVICE}.conf" <<- EOF
	[${STUNNEL_SERVICE}]
	client  = ${STUNNEL_CLIENT}
	accept  = ${STUNNEL_ACCEPT}
	connect = ${STUNNEL_CONNECT}
EOF
  fi
fi

exec "$@"
