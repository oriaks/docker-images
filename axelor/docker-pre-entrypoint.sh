#!/bin/bash

set -- "/docker-entrypoint.sh" "$@"

sed -f- -i /var/lib/tomcat7/webapps/ROOT/WEB-INF/classes/application.properties <<- EOF
	s|^db.default.url = .*|db.default.url = jdbc:postgresql://pgsql:5432/${PGSQL_ENV_PGSQL_DATABASE}|;
	s|^db.default.user = .*|db.default.user = ${PGSQL_ENV_PGSQL_USER}|;
	s|^db.default.password = .*|db.default.password = ${PGSQL_ENV_PGSQL_PASSWORD}|;
EOF

exec "$@"
