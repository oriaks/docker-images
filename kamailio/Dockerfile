FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xfb40d3e6508ea4c8 && \
    echo 'deb http://deb.kamailio.org/kamailio jessie main' > /etc/apt/sources.list.d/kamailio.list
RUN apt-get update -qy && \
    apt-get install -qy ca-certificates curl kamailio kamailio-ldap-modules kamailio-presence-modules kamailio-sqlite-modules && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY kamctlrc /etc/kamailio/kamctlrc
COPY kamailio.cfg /etc/kamailio/kamailio.cfg
COPY kamailio-local.cfg /etc/kamailio/kamailio-local.cfg
COPY ldap.cfg /etc/kamailio/ldap.cfg
COPY ldap.conf /etc/ldap/ldap.conf

RUN mkdir -p /var/lib/kamailio && \
    chown kamailio:kamailio /var/lib/kamailio

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 5060/tcp
EXPOSE 5060/udp

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "kamailio" ]
