FROM debian:stretch
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            freeradius \
            freeradius-krb5 \
            freeradius-ldap \
            heimdal-clients \
            ssl-cert \
            winbind \
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
           /etc/ssl/private/ssl-cert-snakeoil.key

COPY ldap /etc/freeradius/3.0/mods-available/ldap
COPY ldap.conf /etc/ldap/ldap.conf
COPY mschap /etc/freeradius/3.0/mods-available/mschap
COPY radiusd.conf /etc/freeradius/3.0/radiusd.conf
RUN ln -sf ../mods-available/ldap /etc/freeradius/3.0/mods-enabled/ldap

RUN apt-get update -qy && \
    apt-get install -qy \
            libnl-genl-3-200 \
            vim-tiny \
            wget \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY eapol_test /usr/local/bin/eapol_test
COPY peap-mschapv2.conf /root/peap-mschapv2.conf
RUN chmod +x /usr/local/bin/eapol_test

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 1812/tcp
EXPOSE 1812/udp
EXPOSE 1813/tcp
EXPOSE 1813/udp

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "freeradius" ]
