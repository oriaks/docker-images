FROM oriaks/php:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            php5-json \
            php5-pgsql \
            php5-readline \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

ENV PHPPGADMIN_VERSION 5.1

RUN apt-get update -qy && \
    apt-get install -qy \
            bsdtar \
            ca-certificates \
            curl \
            && \
    curl -fLsS "https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz" | bsdtar -xf- -C /var/www/html --strip-components 1 && \
    curl -fLsS "http://downloads.sourceforge.net/project/phppgadmin/phpPgAdmin%20%5Bstable%5D/phpPgAdmin-${PHPPGADMIN_VERSION}/phpPgAdmin-${PHPPGADMIN_VERSION}.tar.gz" | bsdtar -xf- --strip-components 1 -C /var/www/html && \
    apt-get autoremove -qy --purge \
            bsdtar \
            curl \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY apache2.conf /etc/apache2/vhost.d/default.conf
COPY config.inc.php /var/www/html/conf/config.inc.php

RUN chown -R root:root /var/www/html && \
    chmod -R u=rwX,g=rX,o=rX /var/www/html

COPY docker-pre-entrypoint.sh /docker-pre-entrypoint.sh
RUN chmod +x /docker-pre-entrypoint.sh

ENTRYPOINT [ "/docker-pre-entrypoint.sh" ]
