FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy curl && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -s https://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub | apt-key add - && \
    echo 'deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main' > /etc/apt/sources.list.d/freeswitch.list

RUN apt-get update -qy && \
    apt-get install -qy ca-certificates freeswitch freeswitch-mod-console freeswitch-mod-dialplan-xml freeswitch-mod-dptools freeswitch-mod-logfile freeswitch-mod-sofia freeswitch-mod-xml-ldap && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY freeswitch.xml /etc/freeswitch/freeswitch.xml
COPY ldap.conf /etc/ldap/ldap.conf
COPY vars.xml /etc/freeswitch/vars.xml

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 5060/tcp
EXPOSE 5060/udp
VOLUME /var/lib/freeswitch

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "freeswitch" ]
