FROM oriaks/tomcat:7
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV AXELOR_VERSION 4.0.0-RC4

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy bsdtar ca-certificates curl && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -Ls "http://download.axelor.com/abs/abs-${AXELOR_VERSION}-en.war" | bsdtar -xf- -C /var/lib/tomcat7/webapps/ROOT/ && \
    chown -R tomcat7:tomcat7 /var/lib/tomcat7/webapps/ROOT

COPY docker-pre-entrypoint.sh /docker-pre-entrypoint.sh
RUN chmod +x /docker-pre-entrypoint.sh

ENTRYPOINT [ "/docker-pre-entrypoint.sh" ]
