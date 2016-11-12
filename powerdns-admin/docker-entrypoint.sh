#!/bin/bash

PROCNAME='run.py'
DAEMON='/opt/powerdns-admin/run.py'
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
  export DB_HOST="${DB_HOST:=mysql}"
  export DB_NAME="${DB_NAME:=${MYSQL_ENV_MYSQL_DATABASE}}"
  export DB_PASSWORD="${DB_PASSWORD:=${MYSQL_ENV_MYSQL_PASSWORD}}"
  export DB_USER="${DB_USER:=${MYSQL_ENV_MYSQL_USER}}"

  export LDAP_DOMAIN="${LDAP_DOMAIN:=${LDAP_ENV_LDAP_DOMAIN}}"
  export LDAP_ORGANIZATION="${LDAP_ORGANIZATION:=${LDAP_ENV_LDAP_ORGANIZATION}}"

  export LDAP_HOST="${LDAP_HOST:=ldap}"
  export LDAP_BASE_DN="${LDAP_BASE_DN:=dc=${LDAP_DOMAIN//\./,dc=}}"
  export LDAP_USER="${LDAP_USER:=cn=admin,${LDAP_BASE_DN}}"
  export LDAP_PASSWORD="${LDAP_PASSWORD:=${LDAP_ENV_LDAP_PASSWORD}}"

  export PDNS_HOST="${PDNS_HOST:=pdns}"
  export PDNS_API_KEY="${PDNS_API_KEY:=${PDNS_ENV_PDNS_API_KEY}}"

  cd /opt/powerdns-admin
  source ./flask/bin/activate

  WAITFOR_DB=60 ./create_db.py
fi

exec "$@"
