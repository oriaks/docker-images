FROM debian:stretch

ARG OPENLDAP_VERSION=2.4.44

LABEL description="OpenLDAP Server" \
      maintainer="Michael Richard <michael.richard.ing@gmail.com>" \
      version="${OPENLDAP_VERSION}"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            ca-certificates \
            "ldap-utils=${OPENLDAP_VERSION}+*" \
            ldapvi \
            schema2ldif \
            "slapd=${OPENLDAP_VERSION}+*" \
            "slapd-smbk5pwd=${OPENLDAP_VERSION}+*" \
            ssl-cert \
            vim-tiny \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /etc/ldap/slapd.d/* \
           /etc/ssl/certs/ssl-cert-snakeoil.pem \
           /etc/ssl/private/ssl-cert-snakeoil.key \
           /tmp/* \
           /var/lib/apt/lists/* \
           /var/lib/ldap/* \
           /var/tmp/*

RUN usermod -aG ssl-cert openldap

# TEMPORARY FOR DEBUG PURPOSE
RUN apt-get update -qy && \
    apt-get install -qy \
            procps \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY assets/schema/ /etc/ldap/schema/
COPY assets/slapd.init.ldif /usr/share/slapd/slapd.init.ldif

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 389/tcp \
       636/tcp
VOLUME /etc/ldap/slapd.d \
       /var/lib/ldap

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
CMD [ "slapd" ]
