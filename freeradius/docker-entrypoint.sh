#!/bin/bash
set -x

PROCNAME='freeradius'
DAEMON='/usr/sbin/freeradius'
DAEMON_ARGS=( -f -xx )

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
  export LDAP_DOMAIN="${LDAP_DOMAIN:=${LDAP_ENV_LDAP_DOMAIN}}"
  export LDAP_USER="${LDAP_USER:=cn=admin,${LDAP_BASE_DN}}"
  export LDAP_PASSWORD="${LDAP_PASSWORD:=${LDAP_ENV_LDAP_PASSWORD}}"

  export LDAP_BASE_DN="${LDAP_BASE_DN:=dc=${LDAP_DOMAIN//\./,dc=}}"

  if [ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem -o ! -f /etc/ssl/private/ssl-cert-snakeoil.key ]; then
    dpkg-reconfigure ssl-cert
  fi

  sed -i -f- /etc/freeradius/3.0/mods-available/ldap <<-EOF
	s|base_dn[[:space:]]*=[[:space:]]*['"][^$].*|base_dn = '${LDAP_BASE_DN}'|;
	s|identity[[:space:]]*=.*|identity = '${LDAP_USER}'|;
	s|password[[:space:]]*=.*|password = '${LDAP_PASSWORD}'|;
EOF

  if [ -d /var/lib/samba/winbindd_privileged ]; then
    chgrp freerad /var/lib/samba/winbindd_privileged
  fi
fi

exec "$@"
