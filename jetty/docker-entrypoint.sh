#!/bin/bash

PROCNAME='java'
DAEMON='/usr/bin/java'
DAEMON_ARGS=(
    -cp /usr/share/java/commons-daemon.jar:/usr/share/jetty8/start.jar:/usr/lib/jvm/default-java/lib/tools.jar
    -Djava.awt.headless=true
    -Djava.io.tmpdir=/var/cache/jetty8/data
    -Djava.library.path=/usr/lib
    -Djetty.home=/usr/share/jetty8
    -Djetty.host=0.0.0.0 -Djetty.port=80
    -Djetty.logs=/var/log/jetty8
    -Djetty.state=/var/lib/jetty8/jetty.state
    -DSTART=/etc/jetty8/start.config
    -Xmx1024m
    org.eclipse.jetty.start.Main etc/jetty-logging.xml etc/jetty-started.xml
)

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
  if [ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem -o ! -f /etc/ssl/private/ssl-cert-snakeoil.key ]; then
    dpkg-reconfigure ssl-cert
  fi
fi

exec "$@"
