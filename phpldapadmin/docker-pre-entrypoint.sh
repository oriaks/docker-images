#!/bin/bash

export LDAP_DOMAIN="${LDAP_ENV_LDAP_DOMAIN:=}"
export LDAP_ORGANIZATION="${LDAP_ENV_LDAP_ORGANIZATION:=}"

export LDAP_HOST="${LDAP_HOST:=ldap}"
export LDAP_BASE_DN="${LDAP_BASE_DN:=dc=${LDAP_DOMAIN//\./,dc=}}"
export LDAP_BIND_DN="${LDAP_BIND_DN:=cn=admin,${LDAP_BASE_DN}}"
export LDAP_BIND_PASSWORD="${LDAP_BIND_PASSWORD:=${LDAP_ENV_LDAP_PASSWORD}}"

set -- "/docker-entrypoint.sh" "$@"

exec "$@"
