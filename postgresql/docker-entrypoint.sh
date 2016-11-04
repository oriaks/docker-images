#!/bin/bash

PROCNAME='postgres'
DAEMON="/usr/lib/postgresql/${PGSQL_VERSION}/bin/postgres"
DAEMON_ARGS=( -c "config_file=/etc/postgresql/${PGSQL_VERSION}/main/postgresql.conf" -D /var/lib/postgresql -h 0.0.0.0 )
USER=postgres

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
  chown postgres:postgres /var/lib/postgresql

  if [ ! -d "/var/lib/postgresql/${PGSQL_VERSION}/main" ]; then
    su -c "/usr/lib/postgresql/${PGSQL_VERSION}/bin/initdb -D /var/lib/postgresql/${PGSQL_VERSION}/main" -l postgres
  fi

  SQL=()

  if [ -n "${PGSQL_DATABASE}" ]; then
    SQL+=( "CREATE DATABASE ${PGSQL_DATABASE};" )
  fi

  if [ -n "${PGSQL_USER}" ]; then
    SQL+=( "CREATE USER ${PGSQL_USER} WITH SUPERUSER;" )
    if [ -n "${PGSQL_PASSWORD}" ]; then
      SQL+=( "ALTER USER ${PGSQL_USER} WITH SUPERUSER PASSWORD '${PGSQL_PASSWORD}';" )
    else
      SQL+=( "ALTER USER ${PGSQL_USER} WITH SUPERUSER;" )
    fi
  fi

  if [ -n "${PGSQL_PASSWORD}" ]; then
    cat > "/etc/postgresql/${PGSQL_VERSION}/main/pg_hba.conf" <<- 'EOF'
	local all all trust
	host all all 0.0.0.0/0 md5
EOF
  else
    cat > "/etc/postgresql/${PGSQL_VERSION}/main/pg_hba.conf" <<- 'EOF'
	local all all trust
	host all all 0.0.0.0/0 trust
EOF
  fi

  for QUERY in "${SQL[@]}"; do
    echo "${QUERY}" | su -c "/usr/lib/postgresql/${PGSQL_VERSION}/bin/postgres --single -D /var/lib/postgresql/${PGSQL_VERSION}/main" -l postgres
  done

  mkdir -p "/var/run/postgresql/${PGSQL_VERSION}-main.pg_stat_tmp"
  chown postgres:postgres "/var/run/postgresql/${PGSQL_VERSION}-main.pg_stat_tmp"

  if [ `id -u` = '0' ]; then
    set -- gosu "${USER}" "$@"
  fi

fi

exec "$@"
