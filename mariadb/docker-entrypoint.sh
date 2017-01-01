#!/bin/bash
set -x

PROCNAME='mysqld'
DAEMON='/usr/sbin/mysqld'
DAEMON_ARGS=( --init-file /etc/mysql/init.sql )

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
  export MYSQL_DATABASE="${MYSQL_DATABASE:=}"
  export MYSQL_PASSWORD="${MYSQL_PASSWORD:=}"
  export MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:=`head -c1M /dev/urandom | sha1sum | cut -d' ' -f1`}"
  export MYSQL_USER="${MYSQL_USER:=}"
  export WSREP_CLUSTER_ADDRESS="${WSREP_CLUSTER_ADDRESS:=}"
  export WSREP_CLUSTER_NAME="${WSREP_CLUSTER_NAME:=my_wsrep_cluster}"
  export WSREP_NEW_CLUSTER="${WSREP_NEW_CLUSTER:=off}"
  export WSREP_NODE_ADDRESS="${WSREP_NODE_ADDRESS:=`ip -o addr show dev eth0 scope global | awk -F '[ /]+' '{print $4}'`}"
  export WSREP_NODE_NAME="${WSREP_NODE_NAME:=`hostname`}"
  export WSREP_PC_WEIGHT="${WSREP_PC_WEIGHT:=1}"
  export WSREP_SST_PASSWORD="${WSREP_SST_PASSWORD:=}"
  export WSREP_SST_USER="${WSREP_SST_USER:=}"

  if [ ! -f /etc/mysql/certs/ca.crt ]; then
    mkdir -p /etc/mysql/certs
    openssl req -days 3650 -keyout /etc/mysql/certs/ca.key -new -newkey rsa:2048 -out /etc/mysql/certs/ca.crt -sha256 -nodes -subj '/CN=Certificate Authority' -x509
#    openssl rsa -in /etc/mysql/certs/ca.key -out /etc/mysql/certs/ca.key
  fi

  if [ ! -f /etc/mysql/certs/server.crt ]; then
    openssl req -keyout /etc/mysql/certs/server.key -new -newkey rsa:2048 -out /etc/mysql/certs/server.csr -sha256 -nodes -subj '/CN=Server Certificate'
#    openssl rsa -in /etc/mysql/certs/server.key -out /etc/mysql/certs/server.key
    if [ -f /etc/mysql/certs/ca.key ]; then
      openssl x509 -CA /etc/mysql/certs/ca.crt -CAkey /etc/mysql/certs/ca.key -days 3650 -in /etc/mysql/certs/server.csr -out /etc/mysql/certs/server.crt -req -set_serial 01
    fi
  fi

  if [ ! -f /etc/mysql/certs/server.pem ]; then
    if [ ! -f /etc/mysql/certs/dhparam.pem ]; then
      openssl dhparam -out /etc/mysql/certs/dhparam.pem 2048
    fi
    cat /etc/mysql/certs/server.key /etc/mysql/certs/server.crt /etc/mysql/certs/dhparam.pem > /etc/mysql/certs/server.pem
  fi

  if [ -n "${WSREP_SST_USER}" ]; then
    envsubst < /etc/mysql/conf.d/wsrep.cnf.template > /etc/mysql/conf.d/wsrep.cnf
  else
    rm -f /etc/mysql/conf.d/wsrep.cnf
  fi

  SQL=()

  if [ -n "${MYSQL_ROOT_PASSWORD}" ]; then
    SQL+=( "CREATE USER IF NOT EXISTS 'root'@'localhost';" )
    SQL+=( "SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${MYSQL_ROOT_PASSWORD}');" )
  fi
  SQL+=( "DELETE FROM mysql.user WHERE user='root' AND host!='localhost';" )

  if [[ ! -d /var/lib/mysql/mysql && ( -z "${WSREP_SST_USER}" || "${WSREP_NEW_CLUSTER}" = 'on' ) ]]; then
    mysql_install_db

    if [ -n "${WSREP_SST_USER}" ]; then
      SQL+=( "CREATE USER IF NOT EXISTS ${WSREP_SST_USER}@'%';" )
      SQL+=( "CREATE USER IF NOT EXISTS ${WSREP_SST_USER}@'localhost';" )
      if [ -n "${WSREP_SST_PASSWORD}" ]; then
        SQL+=( "SET PASSWORD FOR '${WSREP_SST_USER}'@'%'=PASSWORD('${WSREP_SST_PASSWORD}');" )
        SQL+=( "SET PASSWORD FOR '${WSREP_SST_USER}'@'localhost'=PASSWORD('${WSREP_SST_PASSWORD}');" )
      fi
      SQL+=( "GRANT ALL PRIVILEGES ON *.* TO '${WSREP_SST_USER}'@'%';" )
      SQL+=( "GRANT ALL PRIVILEGES ON *.* TO '${WSREP_SST_USER}'@'localhost';" )
    fi
  fi

  if [ -n "${MYSQL_DATABASE}" ]; then
    SQL+=( "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};" )
  fi

  if [ -n "${MYSQL_USER}" ]; then
    SQL+=( "CREATE USER IF NOT EXISTS ${MYSQL_USER}@'%';" )
    SQL+=( "CREATE USER IF NOT EXISTS ${MYSQL_USER}@'localhost';" )
    if [ -n "${MYSQL_PASSWORD}" ]; then
      SQL+=( "SET PASSWORD FOR '${MYSQL_USER}'@'%'=PASSWORD('${MYSQL_PASSWORD}');" )
      SQL+=( "SET PASSWORD FOR '${MYSQL_USER}'@'localhost'=PASSWORD('${MYSQL_PASSWORD}');" )
    fi
    if [ -n "${MYSQL_DATABASE}" ]; then
      SQL+=( "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';" )
      SQL+=( "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';" )
    fi
  fi

  SQL+=( "FLUSH PRIVILEGES;" )

  printf "%s\n" "${SQL[@]}" > /etc/mysql/init.sql
  chown mysql:mysql /etc/mysql/init.sql

  cat > /root/.my.cnf <<- EOF
	[client]
	user=root
	password=${MYSQL_ROOT_PASSWORD}
EOF

fi

exec "$@"
