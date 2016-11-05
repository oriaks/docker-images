#!/bin/bash

PROCNAME='pdns_server'
DAEMON='/usr/sbin/pdns_server'
DAEMON_ARGS=( --api=yes "--api-key=${PDNS_API_KEY}" --daemon=no --disable-syslog --guardian=yes --master=yes --setgid=pdns --setuid=pdns --slave=yes --webserver=yes --webserver-address=0.0.0.0 )

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
  sed -i -f- /etc/powerdns/pdns.d/pdns.gmysql.conf <<- EOF
	s|^gmysql-dbname=.*|gmysql-dbname=${MYSQL_ENV_MYSQL_DATABASE}|;
	s|^gmysql-host=.*|gmysql-host=mysql|;
	s|^gmysql-password=.*|gmysql-password=${MYSQL_ENV_MYSQL_PASSWORD}|;
	s|^gmysql-port=.*|gmysql-port=3306|;
	s|^gmysql-user=.*|gmysql-user=${MYSQL_ENV_MYSQL_USER}|;
EOF

  mysql -h 'mysql' -u "${MYSQL_ENV_MYSQL_USER}" "-p${MYSQL_ENV_MYSQL_PASSWORD}" "${MYSQL_ENV_MYSQL_DATABASE}" < /usr/share/doc/pdns-backend-mysql/schema.mysql.sql
fi

exec "$@"
