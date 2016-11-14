FROM debian:sid
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy \
            kea-admin \
            kea-dhcp4-server \
            mysql-client \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY kea-dhcp4.conf /etc/kea/kea-dhcp4.conf

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 67/udp
VOLUME /var/lib/kea

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "kea-dhcp4" ]
