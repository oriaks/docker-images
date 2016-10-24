#!/bin/bash
set -x

PROCNAME='turnserver'
DAEMON='/usr/bin/turnserver'
DAEMON_ARGS=( -c '/etc/coturn/turnserver.conf' -v )
USER='turnserver'

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

  if [ ! -f /etc/coturn/envvars ]; then
    cat > /etc/coturn/envvars <<- EOF
	LDAP_BASE_DN="${LDAP_BASE_DN}"
	LDAP_BIND_DN="${LDAP_BIND_DN}"
	LDAP_BIND_PASSWORD="${LDAP_BIND_PASSWORD}"
	SIP_DOMAIN="${SIP_DOMAIN}"
EOF
  fi

  if [ -z "${SKIP_AUTO_IP}" -a -z "${EXTERNAL_IP}" ]; then
    if [ -n "${USE_IPV4}" ]; then
      EXTERNAL_IP=`curl -4 icanhazip.com 2> /dev/null`
    else
      EXTERNAL_IP=`curl icanhazip.com 2> /dev/null`
    fi
  fi

  if [ -n "${EXTERNAL_IP}" ]; then
    sed -i "s|^external-ip=.*|external-ip=${EXTERNAL_IP}|;" /etc/coturn/turnserver.conf
  fi
  if [ -n "${SIP_DOMAIN}" ]; then
    sed -i "s|^realm=.*|realm=${SIP_DOMAIN}|;" /etc/coturn/turnserver.conf
  fi

  if [ `id -u` = '0' ]; then
    set -- gosu "${USER}" "$@"
#    exec gosu "${USER}" "$@"
  fi

  /ldap2turn.sh
fi

exec "$@"
