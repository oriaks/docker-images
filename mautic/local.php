<?php
$parameters = array(
	'db_driver' => 'pdo_mysql',
	'db_host' => getenv('DB_HOST'),
	'db_name' => getenv('DB_NAME'),
	'db_password' => getenv('DB_PASSWORD'),
	'db_port' => '3306',
	'db_table_prefix' => null,
	'db_user' => getenv('DB_USER'),
	'install_source' => 'Docker',
);
