#!/bin/bash

export DB_HOST="${DB_HOST:=pgsql}"
export DB_NAME="${DB_NAME:=${PGSQL_ENV_PGSQL_DATABASE}}"
export DB_PASSWORD="${DB_PASSWORD:=${PGSQL_ENV_PGSQL_PASSWORD}}"
export DB_USER="${DB_USER:=${PGSQL_ENV_PGSQL_USER}}"

set -- "/docker-entrypoint.sh" "$@"

sed -f- -i /var/lib/tomcat7/webapps/ROOT/WEB-INF/classes/application.properties <<- EOF
	s|^db.default.url = .*|db.default.url = jdbc:postgresql://${DB_HOST}:5432/${DB_NAME}|;
	s|^db.default.user = .*|db.default.user = ${DB_USER}|;
	s|^db.default.password = .*|db.default.password = ${DB_PASSWORD}|;
EOF

exec "$@"
