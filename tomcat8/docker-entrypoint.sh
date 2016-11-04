#!/bin/bash

PROCNAME='java'
DAEMON='/usr/bin/java'
DAEMON_ARGS=(
 -classpath /usr/share/tomcat8/bin/bootstrap.jar:/usr/share/tomcat8/bin/tomcat-juli.jar
 -Dcatalina.base=/var/lib/tomcat8
 -Dcatalina.home=/usr/share/tomcat8
 -Djava.awt.headless=true
 -Djava.endorsed.dirs=/usr/share/tomcat8/endorsed
 -Djava.io.tmpdir=/tmp/tomcat8-tomcat8-tmp
 -Djava.util.logging.config.file=/var/lib/tomcat8/conf/logging.properties
 -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager
 -Xmx1024m
 -XX:+UseConcMarkSweepGC
 org.apache.catalina.startup.Bootstrap start
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
