#!/bin/bash

export DB_HOST="${DB_HOST:=pgsql}"
export DB_NAME="${DB_NAME:=${PGSQL_ENV_PGSQL_DATABASE}}"
export DB_PASSWORD="${DB_PASSWORD:=${PGSQL_ENV_PGSQL_PASSWORD}}"
export DB_USER="${DB_USER:=${PGSQL_ENV_PGSQL_USER}}"

set -- "/docker-entrypoint.sh" "$@"

exec "$@"
