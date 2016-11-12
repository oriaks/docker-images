FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            ca-certificates \
            ldap-utils \
            ldapvi \
            schema2ldif \
            slapd \
            slapd-smbk5pwd \
            ssl-cert \
            vim-tiny \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/* \
           && \
    rm -rf /etc/ldap/slapd.d/* \
           /etc/ssl/certs/ssl-cert-snakeoil.pem \
           /etc/ssl/private/ssl-cert-snakeoil.key \
           /var/lib/ldap/*

RUN usermod -aG ssl-cert openldap

COPY ldap.conf /etc/ldap/ldap.conf
COPY ldaprc /root/.ldaprc
COPY ldapvirc /root/.ldapvirc
COPY schema/ /etc/ldap/schema/
COPY slapd.init.ldif /usr/share/slapd/slapd.init.ldif

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 389/tcp
EXPOSE 636/tcp
VOLUME /etc/ldap/slapd.d
VOLUME /var/lib/ldap

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "slapd" ]
