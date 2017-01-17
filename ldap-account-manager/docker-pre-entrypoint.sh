#!/bin/bash

export LDAP_DOMAIN="${LDAP_DOMAIN:=${LDAP_ENV_LDAP_DOMAIN}}"

export LDAP_HOST="${LDAP_HOST:=ldap}"
export LDAP_BASE_DN="${LDAP_BASE_DN:=dc=${LDAP_DOMAIN//\./,dc=}}"
export LDAP_USER="${LDAP_USER:=cn=Administrator,cn=Users,${LDAP_BASE_DN}}"
export LDAP_PASSWORD="${LDAP_PASSWORD:=${LDAP_ENV_LDAP_PASSWORD}}"

set -- "/docker-entrypoint.sh" "$@"

sed -i -f- /var/www/html/config/windows_samba4.conf <<- EOF
	s|^Admins:.*|Admins: ${LDAP_USER}|;
	s|^loginSearchSuffix:.*|loginSearchSuffix: ${LDAP_BASE_DN}|;
	s|^Passwd:.*|Passwd: {SSHA}OW6HxHoXGgcSYk1rKNElBXo+W33+9ekg|;
	s|^ServerURL:.*|ServerURL: ldap://${LDAP_HOST}:389|;
	s|^treesuffix:.*|treesuffix: ${LDAP_BASE_DN}|;
	s|^types: suffix_group:.*|types: suffix_group: ${LDAP_BASE_DN}|;
	s|^types: suffix_host:.*|types: suffix_host: CN=Computers,${LDAP_BASE_DN}|;
	s|^types: suffix_smbDomain:.*|types: suffix_smbDomain: ${LDAP_BASE_DN}|;
	s|^types: suffix_user:.*|types: suffix_user: ${LDAP_BASE_DN}|;
EOF

exec "$@"
