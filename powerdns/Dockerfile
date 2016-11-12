FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            curl \
            && \
    curl -fLsS 'https://repo.powerdns.com/FD380FBB-pub.asc' | apt-key add - && \
    echo 'deb http://repo.powerdns.com/debian jessie-auth-40 main' > /etc/apt/sources.list.d/powerdns.list && \
    apt-get autoremove -qy --purge \
            curl \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

RUN apt-get update -qy && \
    apt-get install -qy --no-install-recommends \
            mysql-client \
            pdns-backend-mysql \
            pdns-server \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

RUN cp /usr/share/pdns-backend-mysql/pdns.local.gmysql.conf /etc/powerdns/pdns.d/pdns.gmysql.conf

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 53/tcp
EXPOSE 53/udp
EXPOSE 8081/tcp

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "pdns_server" ]
