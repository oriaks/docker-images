#!/bin/bash

. /etc/coturn/envvars

if [ -n "${LDAP_BIND_DN}" -a -n "${LDAP_BIND_PASSWORD}" ]; then
  LDAP_BIND_OPTS="-D ${LDAP_BIND_DN} -w ${LDAP_BIND_PASSWORD}"
else
  LDAP_BIND_OPTS=
fi

if [ -n "${LDAP_BASE_DN}" ]; then
  LDAP_SEARCH_BASE_OPTS="-b ${LDAP_BASE_DN}"
else
  LDAP_SEARCH_BASE_OPTS=
fi

if [ -n "${LDAP_URL}" ]; then
  LDAP_URL_OPTS="-H ${LDAP_URL}"
else
  LDAP_URL_OPTS='-H ldaps://ldap'
fi

if [ -n "${SIP_DOMAIN}" ]; then
  REALM_OPTS="--realm ${SIP_DOMAIN}"
else
  REALM_OPTS=
fi

if [ -z "${LDAP_SEARCH_FILTER}" ]; then
  LDAP_SEARCH_FILTER=(objectClass=SIPIdentity)
fi

if [ -z "${LDAP_SIP_ID}" ]; then
  LDAP_SIP_ID=uid
fi

if [ -z "${LDAP_SIP_PASSWORD}" ]; then
  LDAP_SIP_PASSWORD=SIPIdentityPassword
fi

ldapsearch -x -LLL ${LDAP_URL_OPTS} ${LDAP_BIND_OPTS} ${LDAP_SEARCH_BASE_OPTS} "${LDAP_SEARCH_FILTER}" "${LDAP_SIP_ID}" "${LDAP_SIP_PASSWORD}" | while read line; do
  ATTRIBUTE=${line%%:*}
  VALUE=${line#*: }

  if [ "${ATTRIBUTE}" == 'dn' ]; then
    SIP_ID=''
    SIP_PASSWORD=''
  elif [ "${ATTRIBUTE}" == "${LDAP_SIP_ID}" ]; then
    SIP_ID="${VALUE}"
  elif [ "${ATTRIBUTE}" == "${LDAP_SIP_PASSWORD}" ]; then
    SIP_PASSWORD="${VALUE}"
  fi

  if [ -n "${SIP_ID}" -a -n "${SIP_PASSWORD}" ]; then
    turnadmin --add ${REALM_OPTS} --user "${SIP_ID}" --password "${SIP_PASSWORD}"
  fi
done
