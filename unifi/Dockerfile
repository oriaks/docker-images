FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50 && \
    echo "deb http://www.ubnt.com/downloads/unifi/debian unifi5 ubiquiti" > /etc/apt/sources.list.d/unifi.list

RUN apt-get update -qy && \
    apt-get install -qy \
            unifi \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY system.properties /usr/lib/unifi/data/system.properties

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 3478/tcp
EXPOSE 6789/tcp
EXPOSE 8080/tcp
EXPOSE 8443/tcp
EXPOSE 8843/tcp
EXPOSE 8880/tcp
VOLUME /usr/lib/unifi/data
WORKDIR /usr/lib/unifi

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "java" ]
