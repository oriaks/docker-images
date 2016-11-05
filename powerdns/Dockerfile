FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy curl && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN curl -Ls 'https://repo.powerdns.com/FD380FBB-pub.asc' | apt-key add - && \
    echo 'deb http://repo.powerdns.com/debian jessie-auth-40 main' > /etc/apt/sources.list.d/powerdns.list
RUN apt-get update -qy && \
    apt-get install -qy pdns-backend-mysql pdns-server && \
    apt-get install -qy --no-install-recommends mysql-client && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cp /usr/share/pdns-backend-mysql/pdns.local.gmysql.conf /etc/powerdns/pdns.d/pdns.gmysql.conf

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 53/tcp
EXPOSE 53/udp
EXPOSE 8081/tcp

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "pdns_server" ]
