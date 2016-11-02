<?php
$parameters = array(
	'db_driver' => 'pdo_mysql',
	'db_host' => 'mysql',
	'db_name' => getenv('MYSQL_ENV_MYSQL_DATABASE'),
	'db_password' => getenv('MYSQL_ENV_MYSQL_PASSWORD'),
	'db_port' => '3306',
	'db_table_prefix' => null,
	'db_user' => getenv('MYSQL_ENV_MYSQL_USER'),
	'install_source' => 'Docker',
);
