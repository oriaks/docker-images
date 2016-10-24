#!/bin/bash

PROCNAME='freeswitch'
DAEMON='/usr/bin/freeswitch'
DAEMON_ARGS=( -u 'freeswitch' -c )

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

  if [ -z "${SKIP_AUTO_IP}" -a -z "${EXTERNAL_IP}" ]; then
    if [ -n "${USE_IPV4}" ]; then
      EXTERNAL_IP=`curl -4 icanhazip.com 2> /dev/null`
    else
      EXTERNAL_IP=`curl icanhazip.com 2> /dev/null`
    fi
  fi

  if [ -n "${EXTERNAL_IP}" ]; then
    sed -i "s|\"sip_ext_ip=[^\"]*\"|\"sip_ext_ip=${EXTERNAL_IP}\"|;" /etc/freeswitch/vars.xml
  fi
  if [ -n "${LDAP_BIND_DN}" ]; then
    sed -i "s|\"ldap_binddn=[^\"]*\"|\"ldap_binddn=${LDAP_BIND_DN}\"|;" /etc/freeswitch/vars.xml
  fi
  if [ -n "${LDAP_BIND_PASSWORD}" ]; then
    sed -i "s|\"ldap_bindpass=[^\"]*\"|\"ldap_bindpass=${LDAP_BIND_PASSWORD}\"|;" /etc/freeswitch/vars.xml
  fi
  if [ -n "${LDAP_BASE_DN}" ]; then
    sed -i "s|\"ldap_basedn=[^\"]*\"|\"ldap_basedn=${LDAP_BASE_DN}\"|;" /etc/freeswitch/vars.xml
  fi
  if [ -n "${SIP_DOMAIN}" ]; then
    sed -i "s|\"domain=[^\"]*\"|\"domain=${SIP_DOMAIN}\"|;" /etc/freeswitch/vars.xml
  fi

  chown -R freeswitch:freeswitch /var/lib/freeswitch
fi

exec "$@"
