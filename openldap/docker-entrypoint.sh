#!/bin/bash

[ ! -n "${LDAP_LOG_LEVEL}" ] && LDAP_LOG_LEVEL=0

PROCNAME='slapd'
DAEMON='/usr/sbin/slapd'
DAEMON_ARGS=( -h 'ldapi:/// ldaps:// ldap://' -u 'openldap' -g 'openldap' -d "${LDAP_LOG_LEVEL}" )

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

setup_syncprov () {
  while [ ! -e /run/slapd/ldapi ]; do
    sleep 1
  done

  echo "Setting up syncprov..."
  LDAP_DB_DN=$(ldapsearch -b cn=config -LLLQ "(olcSuffix=${LDAP_BASE_DN})" dn | awk '{print $2}')

  if [ -n "${LDAP_SYNCPROV_URI}" ]; then
    ldapmodify <<- EOF
	dn: ${LDAP_DB_DN}
	changetype: modify
	add: olcSyncRepl
	olcSyncRepl:
	  rid=0
	  binddn="${LDAP_SYNCPROV_DN}"
	  bindmethod=simple
	  credentials=${LDAP_SYNCPROV_PASSWORD}
	  logbase="cn=accesslog"
	  logfilter="(&(objectClass=auditWriteObject)(reqResult=0))"
	  provider=${LDAP_SYNCPROV_URI}
	  retry="60 +"
	  schemachecking=on
	  searchbase="${LDAP_BASE_DN}"
	  syncdata=accesslog
	  tls_reqcert=never
	  type=refreshAndPersist
	-
	add: olcUpdateRef
	olcUpdateRef: ${LDAP_SYNCPROV_URI}
	EOF
  else
    ldapmodify <<- EOF
	# AccessLog database definition
	dn: olcDatabase=mdb,cn=config
	changetype: add
	olcDatabase: mdb
	objectClass: olcDatabaseConfig
	objectClass: olcMdbConfig
	olcDbDirectory: /var/lib/ldap/cn=accesslog
	olcDbIndex: default eq
	olcDbIndex: entryCSN,objectClass,reqEnd,reqResult,reqStart
	olcRootDN: ${LDAP_SYNCPROV_DN}
	olcSuffix: cn=accesslog

	# AccessLog database SyncProv overlay definition
	dn: olcOverlay=syncprov,olcDatabase={2}mdb,cn=config
	changetype: add
	olcOverlay: syncprov
	objectClass: olcOverlayConfig
	objectClass: olcSyncProvConfig
	olcSpNoPresent: TRUE
	olcSpReloadHint: TRUE

	# Primary database AccessLog overlay definition
	dn: olcOverlay=accesslog,${LDAP_DB_DN}
	changetype: add
	olcOverlay: accesslog
	objectClass: olcAccessLogConfig
	objectClass: olcOverlayConfig
	olcAccessLogDB: cn=accesslog
	olcAccessLogOps: writes
	olcAccessLogSuccess: TRUE
	# scan the accesslog DB every day, and purge entries older than 7 days
	olcAccessLogPurge: 07+00:00 01+00:00

	# Primary database SyncProv overlay definition
	dn: olcOverlay=syncprov,${LDAP_DB_DN}
	changetype: add
	olcOverlay: syncprov
	objectClass: olcOverlayConfig
	objectClass: olcSyncProvConfig
	olcSpNoPresent: TRUE

	EOF
  fi
}

if [ "$1" = "${DAEMON}" ]; then
  export LDAP_DOMAIN="${LDAP_DOMAIN:=nodomain}"
  export LDAP_BASE_DN="${LDAP_BASE_DN:=`echo ${LDAP_DOMAIN} | sed 's|^|dc=|;s|\.|,dc=|g;'`}"

  export LDAP_ADMIN_DN="${LDAP_ADMIN_DN:=cn=admin,${LDAP_BASE_DN}}"
  export LDAP_ADMIN_PASSWORD="${LDAP_ADMIN_PASSWORD:=admin}"
  export LDAP_ORGANIZATION="${LDAP_ORGANIZATION:=${LDAP_DOMAIN}}"
  export LDAP_SYNCPROV_DN="${LDAP_SYNCPROV_DN:=${LDAP_ADMIN_DN}}"
  export LDAP_SYNCPROV_PASSWORD="${LDAP_SYNCPROV_PASSWORD:=${LDAP_ADMIN_PASSWORD}}"
  export LDAP_SYNCPROV_URI="${LDAP_SYNCPROV_URI:=}"

  if [ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem -o ! -f /etc/ssl/private/ssl-cert-snakeoil.key ]; then
    dpkg-reconfigure ssl-cert
  fi

  if [ ! -f '/etc/ldap/slapd.d/cn=config.ldif' -o ! -f "/var/lib/ldap/${LDAP_BASE_DN}/data.mdb" ]; then
    for schema_file in /etc/ldap/schema/*.schema; do
      schema_ldif=`echo "${schema_file}" | sed 's|\.schema$|.ldif|;'`
      [ ! -f "${schema_ldif}" ] && schema2ldif "${schema_file}" > "${schema_ldif}"
    done

    cat > /root/.ldaprc <<-EOF
	BASE ${LDAP_BASE_DN}
	SASL_MECH EXTERNAL
	TLS_REQCERT never
	URI ldapi:///
	EOF

    cat > /root/.ldapvirc <<-EOF
	profile default
	base: ${LDAP_BASE_DN}
	host: ldapi:///
	sasl-mech: EXTERNAL
	EOF

    cat <<-EOF | debconf-set-selections
	slapd shared/organization string ${LDAP_ORGANIZATION}
	slapd slapd/backend select MDB
	slapd slapd/domain string ${LDAP_DOMAIN}
	slapd slapd/dump_database select when needed
	slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION
	slapd slapd/internal/adminpw password ${LDAP_ADMIN_PASSWORD}
	slapd slapd/internal/generated_adminpw password ${LDAP_ADMIN_PASSWORD}
	slapd slapd/invalid_config boolean true
	slapd slapd/move_old_database boolean true
	slapd slapd/no_configuration boolean false
	slapd slapd/password1 password ${LDAP_ADMIN_PASSWORD}
	slapd slapd/password2 password ${LDAP_ADMIN_PASSWORD}
	slapd slapd/purge_database boolean true
	EOF

    mkdir -p "/var/lib/ldap/${LDAP_BASE_DN}"
    mkdir -p /var/lib/ldap/cn=accesslog
    dpkg-reconfigure -f noninteractive slapd

    if [ -n "${LDAP_SYNCPROV_DN}" -a -n "${LDAP_SYNCPROV_PASSWORD}" ]; then
      setup_syncprov &
    fi
  fi

  ulimit -n 1024
fi

echo "Starting slapd..."
exec "$@"
