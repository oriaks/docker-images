FROM oriaks/php:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV PHPMYADMIN_VERSION 4.6.4
ENV METRO_THEME_VERSION 2.5

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy bsdtar ca-certificates curl && \
    apt-get install -qy php5-curl php5-gd php5-json php5-mysql && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /opt/phpmyadmin && \
    curl -Ls "https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz" | bsdtar -xf- --strip-components 1 -C /opt/phpmyadmin

RUN curl -Ls "https://files.phpmyadmin.net/themes/metro/${METRO_THEME_VERSION}/metro-${METRO_THEME_VERSION}.zip" | bsdtar -xf- -C /opt/phpmyadmin/themes

RUN chown -R root:root /opt/phpmyadmin && \
    chmod -R u=rwX,g=rX,o=rX /opt/phpmyadmin

COPY apache2.conf /etc/apache2/vhost.d/default.conf
COPY config.inc.php /opt/phpmyadmin/config.inc.php

COPY docker-pre-entrypoint.sh /docker-pre-entrypoint.sh
RUN chmod +x /docker-pre-entrypoint.sh

WORKDIR /opt/phpmyadmin

ENTRYPOINT [ "/docker-pre-entrypoint.sh" ]
