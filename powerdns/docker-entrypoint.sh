#!/bin/bash

PROCNAME='pdns_server'
DAEMON='/usr/sbin/pdns_server'
DAEMON_ARGS=( --daemon=no --disable-syslog --guardian=yes --master=yes --setgid=pdns --setuid=pdns --slave=yes )

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
  export PDNS_API_KEY="${PDNS_API_KEY:=}"

  if [ -n "${PDNS_API_KEY}" ]; then
    DAEMON_ARGS+=( --api=yes "--api-key=${PDNS_API_KEY}" --webserver=yes --webserver-address=0.0.0.0 )
  fi

  sed -i -f- /etc/powerdns/pdns.d/pdns.gmysql.conf <<- EOF
	s|^gmysql-dbname=.*|gmysql-dbname=${DB_NAME}|;
	s|^gmysql-host=.*|gmysql-host=${DB_HOST}|;
	s|^gmysql-password=.*|gmysql-password=${DB_PASSWORD}|;
	s|^gmysql-port=.*|gmysql-port=3306|;
	s|^gmysql-user=.*|gmysql-user=${DB_USER}|;
EOF

  while [ -z `mysql -h "${DB_HOST}" -u "${DB_USER}" "-p${DB_PASSWORD}" -e "SELECT schema_name FROM information_schema.schemata WHERE schema_name='${DB_NAME}';" -Bs 2>/dev/null || true` ]; do
    sleep 1
  done

  if [ `mysql -h "${DB_HOST}" -u "${DB_USER}" "-p${DB_PASSWORD}" -e "SELECT COUNT(DISTINCT table_name) FROM information_schema.columns WHERE table_schema='${DB_NAME}';" -Bs` -eq 0 ]; then
    mysql -h "${DB_HOST}" -u "${DB_USER}" "-p${DB_PASSWORD}" "${DB_NAME}" < /usr/share/doc/pdns-backend-mysql/schema.mysql.sql
  fi
fi

exec "$@"
