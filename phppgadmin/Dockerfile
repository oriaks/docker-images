FROM oriaks/php:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV PHPPGADMIN_VERSION 5.1

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy bsdtar ca-certificates curl && \
    apt-get install -qy php5-json php5-pgsql php5-readline && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /opt/phppgadmin && \
    curl -Ls "http://downloads.sourceforge.net/project/phppgadmin/phpPgAdmin%20%5Bstable%5D/phpPgAdmin-${PHPPGADMIN_VERSION}/phpPgAdmin-${PHPPGADMIN_VERSION}.tar.gz" | bsdtar -xf- --strip-components 1 -C /opt/phppgadmin && \
    chown -R root:root /opt/phppgadmin && \
    chmod -R u=rwX,g=rX,o=rX /opt/phppgadmin

COPY apache2.conf /etc/apache2/vhost.d/default.conf
COPY config.inc.php /opt/phppgadmin/conf/config.inc.php

COPY docker-pre-entrypoint.sh /docker-pre-entrypoint.sh
RUN chmod +x /docker-pre-entrypoint.sh

WORKDIR /opt/phppgadmin

ENTRYPOINT [ "/docker-pre-entrypoint.sh" ]
