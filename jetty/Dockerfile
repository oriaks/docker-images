FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy \
            jetty8 \
            ssl-cert \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/* \
           && \
    rm -rf /var/lib/jetty8/webapps/root/*

RUN mkdir -p /var/cache/jetty8/data && \
    chown -R jetty:adm /var/cache/jetty8

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80/tcp
EXPOSE 443/tcp
WORKDIR /var/lib/jetty8/webapps

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "java" ]
