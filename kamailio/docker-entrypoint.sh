#!/bin/bash

PROCNAME='kamailio'
DAEMON='/usr/sbin/kamailio'
DAEMON_ARGS=( -f /etc/kamailio/kamailio.cfg -P /var/run/kamailio/kamailio.pid -m 64 -M 8 -u kamailio -g kamailio -D )

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
  [ ! -n "${LDAP_BASE_DN}"       ] && LDAP_BASE_DN=`echo "${LDAP_ENV_LDAP_DOMAIN}" | sed 's|^|dc=|;s|\.|,dc=|g;'`
  [ ! -n "${LDAP_BIND_DN}"       ] && LDAP_BIND_DN="cn=admin,${LDAP_BASE_DN}"
  [ ! -n "${LDAP_BIND_PASSWORD}" ] && LDAP_BIND_PASSWORD="${LDAP_ENV_LDAP_PASSWORD}"
  [ ! -n "${SIP_DOMAIN}"         ] && SIP_DOMAIN="${LDAP_ENV_LDAP_DOMAIN}"

  if [ ! -f /var/lib/kamailio/kamailio.db ]; then
    kamdbctl create
  fi

  if [ -z "${SKIP_AUTO_IP}" -a -z "${EXTERNAL_IP}" ]; then
    if [ -n "${USE_IPV4}" ]; then
      EXTERNAL_IP=`curl -4 icanhazip.com 2> /dev/null`
    else
      EXTERNAL_IP=`curl icanhazip.com 2> /dev/null`
    fi
  fi

  if [ -n "${EXTERNAL_IP}" ]; then
    sed -i "s|/EXTERNAL_IP/[^/]*/|/EXTERNAL_IP/'${EXTERNAL_IP}'/|;" /etc/kamailio/kamailio-local.cfg
  fi
  if [ -n "${EXTERNAL_IP_PORT}" ]; then
    sed -i "s|/EXTERNAL_PORT/[^/]*/|/EXTERNAL_PORT/'${EXTERNAL_PORT}'/|;" /etc/kamailio/kamailio-local.cfg
  fi
  if [ -n "${LDAP_BIND_DN}" ]; then
    sed -i "s|^ldap_bind_dn[[:space:]]*=.*|ldap_bind_dn = \"${LDAP_BIND_DN}\"|;" /etc/kamailio/ldap.cfg
  fi
  if [ -n "${LDAP_BIND_PASSWORD}" ]; then
    sed -i "s|^ldap_bind_password[[:space:]]*=.*|ldap_bind_password = \"${LDAP_BIND_PASSWORD}\"|;" /etc/kamailio/ldap.cfg
  fi
  if [ -n "${LDAP_BASE_DN}" ]; then
    sed -i "s|/LDAP_BASE_DN/[^/]*/|/LDAP_BASE_DN/'${LDAP_BASE_DN}'/|;" /etc/kamailio/kamailio-local.cfg
  fi
  if [ -n "${SIP_DOMAIN}" ]; then
    sed -i "s|/SIP_DOMAIN/[^/]*/|/SIP_DOMAIN/'${SIP_DOMAIN}'/|;" /etc/kamailio/kamailio-local.cfg
  fi

  chown -R kamailio:kamailio /var/lib/kamailio
fi

exec "$@"
