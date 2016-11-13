FROM oriaks/php:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            php5-gd \
            php5-json \
            php5-ldap \
            php5-mysql \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

ENV COMPOSER_VERSION 1.2.1

RUN apt-get update -qy && \
    apt-get install -qy \
            bsdtar \
            ca-certificates \
            curl \
            && \
    curl -fLsS -o /usr/local/bin/composer "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar" && \
    chown root:root /usr/local/bin/composer && \
    chmod u=rwx,g=rx,o=rx /usr/local/bin/composer && \
    apt-get autoremove -qy --purge \
            bsdtar \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

ENV KANBOARD_VERSION 1.0.34

RUN apt-get update -qy && \
    apt-get install -qy \
            bsdtar \
            ca-certificates \
            curl \
            && \
    curl -fLsS "https://github.com/kanboard/kanboard/archive/v${KANBOARD_VERSION}.tar.gz" | bsdtar -xf- -C /var/www/html --strip-components 1 && \
    composer install --no-ansi --no-dev --no-interaction --optimize-autoloader --prefer-dist --working-dir /var/www/html && \
    apt-get autoremove -qy --purge \
            bsdtar \
            curl \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY apache2.conf /etc/apache2/vhost.d/default.conf
COPY ldap.conf /etc/ldap/ldap.conf
COPY config.php /var/www/html/config.php

RUN chown -R root:root /var/www/html

COPY docker-pre-entrypoint.sh /docker-pre-entrypoint.sh
RUN chmod +x /docker-pre-entrypoint.sh

VOLUME /var/www/html/data
VOLUME /var/www/html/plugins

ENTRYPOINT [ "/docker-pre-entrypoint.sh" ]
