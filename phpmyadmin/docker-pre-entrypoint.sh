#!/bin/bash

export DB_HOST="${DB_HOST:=mysql}"
export DB_NAME="${DB_NAME:=${MYSQL_ENV_MYSQL_DATABASE}}"
export DB_PASSWORD="${DB_PASSWORD:=${MYSQL_ENV_MYSQL_PASSWORD}}"
export DB_USER="${DB_USER:=${MYSQL_ENV_MYSQL_USER}}"

set -- "/docker-entrypoint.sh" "$@"

if [ ! -f /var/www/html/config.secret.inc.php ]; then
  cat > /var/www/html/config.secret.inc.php <<- EOF
	<?php
	/**
	 * This is needed for cookie based authentication to encrypt password in
	 * cookie. Needs to be 32 chars long.
	 */
	\$cfg['blowfish_secret'] = '`cat /dev/urandom | tr -dc 'a-zA-Z0-9~!@#$%^&*_()+}{?></";.,[]=-' | fold -w 32 | head -n 1`'; /* YOU MUST FILL IN THIS FOR COOKIE AUTH! */
EOF
fi

exec "$@"
