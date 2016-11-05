#!/bin/bash

set -- "/docker-entrypoint.sh" "$@"

if [ ! -f /opt/phpmyadmin/config.secret.inc.php ]; then
  cat > /opt/phpmyadmin/config.secret.inc.php <<- EOF
	<?php
	/**
	 * This is needed for cookie based authentication to encrypt password in
	 * cookie. Needs to be 32 chars long.
	 */
	\$cfg['blowfish_secret'] = '`cat /dev/urandom | tr -dc 'a-zA-Z0-9~!@#$%^&*_()+}{?></";.,[]=-' | fold -w 32 | head -n 1`'; /* YOU MUST FILL IN THIS FOR COOKIE AUTH! */
EOF
fi

exec "$@"
