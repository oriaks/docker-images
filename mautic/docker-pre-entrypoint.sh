#!/bin/bash

export DB_HOST="${DB_HOST:=mysql}"
export DB_NAME="${DB_NAME:=${MYSQL_ENV_MYSQL_DATABASE}}"
export DB_PASSWORD="${DB_PASSWORD:=${MYSQL_ENV_MYSQL_PASSWORD}}"
export DB_USER="${DB_USER:=${MYSQL_ENV_MYSQL_USER}}"

set -- "/docker-entrypoint.sh" "$@"

exec "$@"
