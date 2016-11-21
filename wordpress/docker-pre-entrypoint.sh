#!/bin/bash

export DB_HOST="${DB_HOST:=mysql}"
export DB_NAME="${DB_NAME:=${MYSQL_ENV_MYSQL_DATABASE}}"
export DB_PASSWORD="${DB_PASSWORD:=${MYSQL_ENV_MYSQL_PASSWORD}}"
export DB_PREFIX="${DB_PREFIX:=wp_}"
export DB_USER="${DB_USER:=${MYSQL_ENV_MYSQL_USER}}"
export WP_AUTH_KEY="${WP_AUTH_KEY:=`head -c1M /dev/urandom | sha1sum | cut -d' ' -f1`}"
export WP_AUTH_SALT="${WP_AUTH_SALT:=`head -c1M /dev/urandom | sha1sum | cut -d' ' -f1`}"
export WP_DEBUG="${WP_DEBUG:=false}"
export WP_LOGGED_IN_KEY="${WP_LOGGED_IN_KEY:=`head -c1M /dev/urandom | sha1sum | cut -d' ' -f1`}"
export WP_LOGGED_IN_SALT="${WP_LOGGED_IN_SALT:=`head -c1M /dev/urandom | sha1sum | cut -d' ' -f1`}"
export WP_NONCE_KEY="${WP_NONCE_KEY:=`head -c1M /dev/urandom | sha1sum | cut -d' ' -f1`}"
export WP_NONCE_SALT="${WP_NONCE_SALT:=`head -c1M /dev/urandom | sha1sum | cut -d' ' -f1`}"
export WP_SECURE_AUTH_KEY="${WP_SECURE_AUTH_KEY:=`head -c1M /dev/urandom | sha1sum | cut -d' ' -f1`}"
export WP_SECURE_AUTH_SALT="${WP_SECURE_AUTH_SALT:=`head -c1M /dev/urandom | sha1sum | cut -d' ' -f1`}"

set -- "/docker-entrypoint.sh" "$@"

chown -R www-data:www-data /var/www/html/wp-content

exec "$@"
