#!/bin/bash

PROCNAME='kea-dhcp4'
DAEMON='/usr/sbin/kea-dhcp4'
DAEMON_ARGS=( -c '/etc/kea/kea-dhcp4.conf' )

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

  sed -i -f- /etc/kea/kea-dhcp4.conf <<- EOF
	/lease-database/,/}/ {
		s|"host": [^,]*|"host": "${DB_HOST}"|;
		s|"user": [^,]*|"user": "${DB_USER}"|;
		s|"password": [^,]*|"password": "${DB_PASSWORD}"|;
		s|"name": [^,]*|"name": "${DB_NAME}"|;
	}
EOF

  while [ -z `mysql -h "${DB_HOST}" -u "${DB_USER}" "-p${DB_PASSWORD}" -e "SELECT schema_name FROM information_schema.schemata WHERE schema_name='${DB_NAME}';" -Bs 2>/dev/null || true` ]; do
    sleep 1
  done

  if [ `mysql -h "${DB_HOST}" -u "${DB_USER}" "-p${DB_PASSWORD}" -e "SELECT COUNT(DISTINCT table_name) FROM information_schema.columns WHERE table_schema='${DB_NAME}';" -Bs` -eq 0 ]; then
    mysql -h "${DB_HOST}" -u "${DB_USER}" "-p${DB_PASSWORD}" "${DB_NAME}" < /usr/share/kea-admin/scripts/mysql/dhcpdb_create.mysql
  fi
fi

exec "$@"
