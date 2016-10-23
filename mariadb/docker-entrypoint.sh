#!/bin/bash

PROCNAME='mysqld'
DAEMON='/usr/sbin/mysqld'
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
  if [ ! -d /var/lib/mysql/mysql ]; then
    mysql_install_db
  fi

  SQL=()

  if [ -n "${MYSQL_ROOT_PASSWORD}" ]; then
    mysqld --bootstrap <<- EOF
	UPDATE mysql.user SET password=PASSWORD('${MYSQL_ROOT_PASSWORD}') WHERE user='root';
EOF
    cat > /root/.my.cnf <<- EOF
	[client]
	user=root
	password=${MYSQL_ROOT_PASSWORD}
EOF
  fi

  if [ -n "${MYSQL_DATABASE}" ]; then
    SQL+=( "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};" )
  fi

  if [ -n "${MYSQL_USER}" ]; then
    SQL+=( "CREATE USER IF NOT EXISTS ${MYSQL_USER}@'%';" )
    SQL+=( "CREATE USER IF NOT EXISTS ${MYSQL_USER}@'localhost';" )
    if [ -n "${MYSQL_PASSWORD}" ]; then
      SQL+=( "UPDATE mysql.user SET password=PASSWORD('${MYSQL_PASSWORD}') WHERE user='${MYSQL_USER}';" )
    fi
    if [ -n "${MYSQL_DATABASE}" ]; then
      SQL+=( "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';" )
      SQL+=( "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';" )
    fi
    SQL+=( "FLUSH PRIVILEGES;" )
  fi

  TMPFILE=`mktemp`
  chown mysql:mysql "${TMPFILE}"
  printf "%s\n" "${SQL[@]}" > "${TMPFILE}"
  mysqld --skip-networking --init-file="${TMPFILE}"
  rm -f "${TMPFILE}"

fi

exec "$@"
