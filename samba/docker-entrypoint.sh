#!/bin/bash

PROCNAME='samba'
DAEMON='/usr/sbin/samba'
DAEMON_ARGS=( -i )

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
  export SAMBA_DNS_FORWARDER="${SAMBA_DNS_FORWARDER:=8.8.8.8}"
  export SAMBA_HOSTNAME="${SAMBA_HOSTNAME:=`hostname -s`}"
  export SAMBA_IP="${SAMBA_IP:=`hostname -i`}"
  export SAMBA_PASSWORD="${SAMBA_PASSWORD:=}"
  export SAMBA_REALM="${SAMBA_REALM:=`hostname -d | tr '[a-z]' '[A-Z]'`}"

  export SAMBA_DOMAIN="${SAMBA_DOMAIN:=`echo "${SAMBA_REALM}" | awk -F '.' '{print $1}'`}"

  if [ ! -f /etc/samba/smb.conf ]; then
    samba-tool domain provision \
      --adminpass=${SAMBA_PASSWORD} \
      --domain=${SAMBA_DOMAIN} \
      --host-ip=${SAMBA_IP} \
      --host-name=${SAMBA_HOSTNAME} \
      --option="dns forwarder = ${SAMBA_DNS_FORWARDER}" \
      --option='ldap server require strong auth = allow_sasl_over_tls' \
      --option='ntlm auth = yes' \
      --realm=${SAMBA_REALM} \
      --use-rfc2307
  fi

  chmod 750 /var/lib/samba/winbindd_privileged
fi

exec "$@"
