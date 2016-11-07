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
  sed -i -f- /etc/kea/kea-dhcp4.conf <<- EOF
	/lease-database/,/}/ {
		s|"user": [^,]*|"user": "${MYSQL_ENV_MYSQL_USER}"|;
		s|"password": [^,]*|"password": "${MYSQL_ENV_MYSQL_PASSWORD}"|;
		s|"name": [^,]*|"name": "${MYSQL_ENV_MYSQL_DATABASE}"|;
	}
EOF

  mysql -h 'mysql' -u "${MYSQL_ENV_MYSQL_USER}" "-p${MYSQL_ENV_MYSQL_PASSWORD}" "${MYSQL_ENV_MYSQL_DATABASE}" < /usr/share/kea-admin/scripts/mysql/dhcpdb_create.mysql

fi

exec "$@"
