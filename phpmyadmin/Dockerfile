FROM oriaks/php:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

RUN apt-get update -qy && \
    apt-get install -qy \
            php5-curl \
            php5-gd \
            php5-json \
            php5-mysql \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

ENV PHPMYADMIN_VERSION 4.6.4
ENV METRO_THEME_VERSION 2.5

RUN apt-get update -qy && \
    apt-get install -qy \
            bsdtar \
            ca-certificates \
            curl \
            && \
    curl -fLsS "https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz" | bsdtar -xf- -C /var/www/html --strip-components 1 && \
    curl -fLsS "https://files.phpmyadmin.net/themes/metro/${METRO_THEME_VERSION}/metro-${METRO_THEME_VERSION}.zip" | bsdtar -xf- -C /var/www/html/themes && \
    apt-get autoremove -qy --purge \
            bsdtar \
            curl \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY apache2.conf /etc/apache2/vhost.d/default.conf
COPY config.inc.php /var/www/html/config.inc.php

RUN chown -R root:root /var/www/html && \
    chmod -R u=rwX,g=rX,o=rX /var/www/html

COPY docker-pre-entrypoint.sh /docker-pre-entrypoint.sh
RUN chmod +x /docker-pre-entrypoint.sh

ENTRYPOINT [ "/docker-pre-entrypoint.sh" ]
