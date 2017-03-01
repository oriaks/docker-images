#!/bin/bash

export LAM_LANG="${LAM_LANG:=en_US}"
export LAM_PASSWORD="${LAM_PASSWORD:=lam}"
export LAM_TIMEZONE="${LAM_TIMEZONE:=America/Toronto}"
export LDAP_DOMAIN="${LDAP_DOMAIN:=${LDAP_ENV_LDAP_DOMAIN}}"
export LDAP_HOST="${LDAP_HOST:=ldap}"
export LDAP_PASSWORD="${LDAP_PASSWORD:=${LDAP_ENV_LDAP_PASSWORD}}"

export LAM_PASSWORD_SSHA=`php -r '$password = getenv("LAM_PASSWORD"); mt_srand((microtime() * 1000000)); $rand = abs(hexdec(bin2hex(openssl_random_pseudo_bytes(5)))); $salt0 = substr(pack("h*", md5($rand)), 0, 8); $salt = substr(pack("H*", sha1($salt0 . $password)), 0, 4); print "{SSHA}" . base64_encode(pack("H*", sha1($password . $salt))) . " " . base64_encode($salt) . "\n";'`
export LDAP_BASE_DN="${LDAP_BASE_DN:=dc=${LDAP_DOMAIN//\./,dc=}}"

export LDAP_USER="${LDAP_USER:=cn=Administrator,cn=Users,${LDAP_BASE_DN}}"

set -- "/docker-entrypoint.sh" "$@"

sed -i -f- /var/www/html/config/config.cfg <<- EOF
	s|^password:.*|password: ${LAM_PASSWORD_SSHA}|;
EOF

sed -i -f- /var/www/html/config/windows_samba4.conf <<- EOF
	s|^Admins:.*|Admins: ${LDAP_USER}|;
	s|^defaultLanguage:.*|defaultLanguage: ${LAM_LANG}.utf8|;
	s|^loginMethod:.*|loginMethod: search|;
	s|^loginSearchDN:.*|loginSearchDN: ${LDAP_USER}|;
	s|^loginSearchFilter:.*|loginSearchFilter: cn=%USER%|;
	s|^loginSearchPassword:.*|loginSearchPassword: ${LDAP_PASSWORD}|;
	s|^loginSearchSuffix:.*|loginSearchSuffix: CN=Users,${LDAP_BASE_DN}|;
	s|^Passwd:.*|Passwd: ${LAM_PASSWORD_SSHA}|;
	s|^modules: windowsUser_domains: .*|modules: windowsUser_domains: ${LDAP_DOMAIN}|;
	s|^ServerURL:.*|ServerURL: ldap://${LDAP_HOST}:389|;
	s|^timeZone:.*|timeZone: ${LAM_TIMEZONE}|;
	s|^treesuffix:.*|treesuffix: ${LDAP_BASE_DN}|;
	s|^types: suffix_group:.*|types: suffix_group: CN=Users,${LDAP_BASE_DN}|;
	s|^types: suffix_host:.*|types: suffix_host: CN=Computers,${LDAP_BASE_DN}|;
	s|^types: suffix_smbDomain:.*|types: suffix_smbDomain: ${LDAP_BASE_DN}|;
	s|^types: suffix_user:.*|types: suffix_user: CN=Users,${LDAP_BASE_DN}|;
EOF

exec "$@"
