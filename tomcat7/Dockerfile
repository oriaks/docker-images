FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy \
            tomcat7 \
            ssl-cert \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/* \
           && \
    rm -rf /var/lib/tomcat7/webapps/ROOT/*

RUN sed -i 's|8080|80|g;' /etc/tomcat7/server.xml

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80/tcp
EXPOSE 443/tcp
WORKDIR /var/lib/tomcat7/webapps

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "java" ]
