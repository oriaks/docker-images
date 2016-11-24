#!/bin/bash

PROCNAME='java'
DAEMON='/usr/bin/java'
DAEMON_ARGS=(
 -classpath /usr/share/tomcat8/bin/bootstrap.jar:/usr/share/tomcat8/bin/tomcat-juli.jar
 -Dcatalina.base=/var/lib/tomcat8
 -Dcatalina.home=/usr/share/tomcat8
 -Djava.awt.headless=true
 -Djava.endorsed.dirs=/usr/share/tomcat8/endorsed
 -Djava.io.tmpdir=/tmp/tomcat8-tomcat8-tmp
 -Djava.util.logging.config.file=/var/lib/tomcat8/conf/logging.properties
 -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager
 -Xmx1024m
 -XX:+UseConcMarkSweepGC
 org.apache.catalina.startup.Bootstrap start
)

if [ -z "$1" ]; then
  set -- "${DAEMON}" "${DAEMON_ARGS[@]}"
elif [ "${1:0:1}" = '-' ]; then
  set -- "${DAEMON}" "$@"
elif [ "${1}" = "${PROCNAME}" ]; then
  shift
  if [ -n "${1}" ]; then
    set -- "${DAEMON}" "$@"
  else
    set -- "${DAEMON}" "${DAEMON_ARGS[@]}"
  fi
fi

if [ "$1" = "${DAEMON}" ]; then
  export DB_HOST="${DB_HOST:=mysql}"
  export DB_NAME="${DB_NAME:=${MYSQL_ENV_MYSQL_DATABASE}}"
  export DB_PASSWORD="${DB_PASSWORD:=${MYSQL_ENV_MYSQL_PASSWORD}}"
  export DB_USER="${DB_USER:=${MYSQL_ENV_MYSQL_USER}}"

  if [ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem -o ! -f /etc/ssl/private/ssl-cert-snakeoil.key ]; then
    dpkg-reconfigure ssl-cert
  fi

  if [ -n "${DB_NAME}" ]; then
    sed -i -f- /var/lib/tomcat8/webapps/ROOT/WEB-INF/bluedragon/bluedragon.xml <<- EOF
	/<datasource name=\"mysql\">/,/<name>mysql<\/name>/ {
		s|<databasename>[^<]*</databasename>|<databasename>${DB_NAME}</databasename>|;
		s|<hoststring>[^<]*</hoststring>|<hoststring>jdbc:mysql://${DB_HOST}:3306/${DB_NAME}?cacheResultSetMetadata=false\&amp;autoReconnect=true\&amp;useEncoding=true\&amp;characterEncoding=UTF-8\&amp;zeroDateTimeBehavior=convertToNull</hoststring>|;
		s|<password>[^<]*</password>|<password>${DB_PASSWORD}</password>|;
		s|<server>[^<]*</server>|<server>${DB_HOST}</server>|;
		s|<username>[^<]*</username>|<username>${DB_USER}</username>|;
	};
EOF

    sed -i -f- /var/lib/tomcat8/webapps/ROOT/admin/controller/circuit.xml.cfm <<- EOF
	s|\(<set name=\"session.firsttime.db_name\" value=\"\)[^\"]*\(\" />\)|\1${DB_NAME}\2|;
	s|\(<set name=\"session.firsttime.db_pass\" value=\"\)[^\"]*\(\" />\)|\1${DB_PASSWORD}\2|;
	s|\(<set name=\"session.firsttime.db_schema\" value=\"\)[^\"]*\(\" />\)|\1${DB_NAME}\2|;
	s|\(<set name=\"session.firsttime.db_server\" value=\"\)[^\"]*\(\" />\)|\1${DB_HOST}\2|;
	s|\(<set name=\"session.firsttime.db_user\" value=\"\)[^\"]*\(\" />\)|\1${DB_USER}\2|;
EOF
  fi
fi

exec "$@"
