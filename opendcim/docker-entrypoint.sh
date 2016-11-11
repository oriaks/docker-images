#!/bin/bash

PROCNAME='apache2'
DAEMON='/usr/sbin/apache2'
DAEMON_ARGS=( -DFOREGROUND -k start )
LDAPCONF='/etc/apache2/sites-available/default-ssl.conf.ldap'

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
  if [ ! -f /etc/ssl/certs/ssl-cert-snakeoil.pem -o ! -f /etc/ssl/private/ssl-cert-snakeoil.key ]; then
    dpkg-reconfigure ssl-cert
  fi

  . /etc/apache2/envvars

  mkdir -p "${APACHE_LOCK_DIR}"
  mkdir -p "${APACHE_RUN_DIR}"

  rm -f "${APACHE_PID_FILE}"
fi

if [ "${AUTHLDAP}" = 'yes' ]; then
  sed -i -- 's@AuthLDAPURL@'"$AUTHLDAPURL"'@' ${LDAPCONF}
  sed -i -- 's@AuthLDAPBindDN@'"$AUTHLDAPBINDDN"'@' ${LDAPCONF}
  sed -i -- 's@AuthLDAPBindPassword@'"$AUTHLDAPBINDPASSWORD"'@' ${LDAPCONF}
  sed -i -- 's@Require@'"$REQUIRE"'@' ${LDAPCONF}
  mv ${LDAPCONF} /etc/apache2/sites-available/default-ssl.conf
  # Cleanup password file and .htaccess
  rm /opt/www/opendcim/.htaccess
  rm /opt/www/opendcim.password
  a2enmod authnz_ldap
else
 rm ${LDAPCONF}
fi

exec "$@"
