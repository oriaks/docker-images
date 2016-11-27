FROM oriaks/tomcat:7
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy \
            bsdtar \
            ca-certificates \
            curl \
            && \
    curl -fLsS "http://download.axelor.com/abs/autoInstallerFR/axelor-business-suite-4.x.x-linux-fr-x64.run" | sed -e '1,/^exit 0$/d' | bsdtar -xf- -C /var/lib/tomcat7/webapps/ROOT/ --strip-components 4 ./var/www/axelor && \
    chown -R tomcat7:tomcat7 /var/lib/tomcat7/webapps/ROOT && \
    apt-get autoremove -qy --purge \
            bsdtar \
            curl \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY application.properties /var/lib/tomcat7/webapps/ROOT/WEB-INF/classes/application.properties
COPY module.properties /var/lib/tomcat7/webapps/ROOT/WEB-INF/classes/module.properties

COPY docker-pre-entrypoint.sh /docker-pre-entrypoint.sh
RUN chmod +x /docker-pre-entrypoint.sh

ENTRYPOINT [ "/docker-pre-entrypoint.sh" ]
