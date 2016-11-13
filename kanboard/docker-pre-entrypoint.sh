#!/bin/bash

export DB_HOST="${DB_HOST:=mysql}"
export DB_NAME="${DB_NAME:=${MYSQL_ENV_MYSQL_DATABASE}}"
export DB_PASSWORD="${DB_PASSWORD:=${MYSQL_ENV_MYSQL_PASSWORD}}"
export DB_PREFIX="${DB_PREFIX:=wp_}"
export DB_USER="${DB_USER:=${MYSQL_ENV_MYSQL_USER}}"
export LDAP_DOMAIN="${LDAP_DOMAIN:=${LDAP_ENV_LDAP_DOMAIN}}"
export LDAP_ORGANIZATION="${LDAP_ORGANIZATION:=${LDAP_ENV_LDAP_ORGANIZATION}}"
export LDAP_HOST="${LDAP_HOST:=ldap}"
export LDAP_BASE_DN="${LDAP_BASE_DN:=dc=${LDAP_DOMAIN//\./,dc=}}"
export LDAP_USER="${LDAP_USER:=cn=admin,${LDAP_BASE_DN}}"
export LDAP_PASSWORD="${LDAP_PASSWORD:=${LDAP_ENV_LDAP_PASSWORD}}"

set -- "/docker-entrypoint.sh" "$@"

chown -R www-data:www-data /var/www/html/data
chown -R www-data:www-data /var/www/html/plugins

exec "$@"
