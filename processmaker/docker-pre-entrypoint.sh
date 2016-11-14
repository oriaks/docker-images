#!/bin/bash

export DB_HOST="${DB_HOST:=mysql}"
export DB_NAME="${DB_NAME:=${MYSQL_ENV_MYSQL_DATABASE}}"
export DB_PASSWORD="${DB_PASSWORD:=${MYSQL_ENV_MYSQL_PASSWORD}}"
export DB_USER="${DB_USER:=${MYSQL_ENV_MYSQL_USER}}"

set -- "/docker-entrypoint.sh" "$@"

if [ -f '/var/www/html/shared/srvConf.singleton' ]; then
  if [ ! -f '/var/www/html/workflow/engine/config/env.ini' ]; then
    cat > '/var/www/html/workflow/engine/config/env.ini' << 'EOF'
default_lang = "en"
default_skin = "neoclassic"
EOF
  fi
  if [ ! -f '/var/www/html/workflow/engine/config/paths_installed.php' ]; then
    cat > '/var/www/html/workflow/engine/config/paths_installed.php' << 'EOF'
<?php
  define('PATH_DATA',         '/var/www/html/shared/');
  define('PATH_C',            '/var/www/html/shared/compiled/');
  define('HASH_INSTALLATION', 'mZdsaGOTmmtpb22Xl2ptbZeTlpZjZ2qWmJvGw8ecZmJnaqejocSepaqlls2ap21sk2PGamRsbZaZmZeZm5hhl2ZnbGaTmJ2UmJ5rkmdqqKfRlMqkpaKWzJzW');
  define('SYSTEM_HASH',       '5712a92785b5585b1e1255a7dbaf6025');
EOF
  fi
fi

chown -R www-data:www-data '/var/www/html/shared'
chown -R www-data:www-data '/var/www/html/workflow/engine/config'
chown -R www-data:www-data '/var/www/html/workflow/engine/js/labels'

exec "$@"
