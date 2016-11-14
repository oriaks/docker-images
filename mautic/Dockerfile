FROM oriaks/php:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            php5-imap \
            php5-intl \
            php5-mcrypt \
            php5-mysql \
            php5-curl \
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

ENV MAUTIC_VERSION 2.2.1

RUN apt-get update -qy && \
    apt-get install -qy \
            bsdtar \
            ca-certificates \
            curl \
            git \
            && \
    curl -fLsS "https://github.com/mautic/mautic/archive/${MAUTIC_VERSION}.zip" | bsdtar -xf- --strip-components 1 -C /var/www/html && \
    mkdir -p /var/www/html/.git/hooks && \
    composer install --no-ansi --no-dev --no-interaction --optimize-autoloader --prefer-dist --working-dir /var/www/html && \
    apt-get autoremove -qy --purge \
            bsdtar \
            git \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY apache2.conf /etc/apache2/vhost.d/default.conf
COPY local.php /var/www/html/app/config/local.php

RUN chown -R root:root /var/www/html && \
    chmod -R u=rwX,g=rX,o=rX /var/www/html && \
    chown -R www-data:www-data /var/www/html/app/cache && \
    chown -R www-data:www-data /var/www/html/app/config/local.php && \
    chown -R www-data:www-data /var/www/html/app/logs && \
    chown -R www-data:www-data /var/www/html/media/files

COPY docker-pre-entrypoint.sh /docker-pre-entrypoint.sh
RUN chmod +x /docker-pre-entrypoint.sh

VOLUME /var/www/media/files

ENTRYPOINT [ "/docker-pre-entrypoint.sh" ]
