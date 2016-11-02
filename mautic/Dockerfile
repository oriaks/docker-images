FROM oriaks/php:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV COMPOSER_VERSION 1.2.1
ENV MAUTIC_VERSION 2.2.1

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy bsdtar ca-certificates curl git && \
    apt-get install -qy php5-imap php5-intl php5-mcrypt php5-mysql && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /opt/composer && \
    curl -Ls -o /opt/composer/composer.phar "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar" && \
    chown -R root:root /opt/composer && \
    chmod -R u=rwX,g=rX,o=rX /opt/composer

RUN mkdir -p /opt/mautic && \
    curl -Ls "https://github.com/mautic/mautic/archive/${MAUTIC_VERSION}.zip" | bsdtar -xf- --strip-components 1 -C /opt/mautic && \
    mkdir -p /opt/mautic/.git/hooks && \
    php /opt/composer/composer.phar install --no-ansi --no-interaction --working-dir /opt/mautic && \
    chown -R root:root /opt/mautic && \
    chmod -R u=rwX,g=rX,o=rX /opt/mautic && \
    chown -R www-data:www-data /opt/mautic/app/cache && \
    chown -R www-data:www-data /opt/mautic/app/logs && \
    chown -R www-data:www-data /opt/mautic/media/files

COPY apache2.conf /etc/apache2/vhost.d/default.conf
COPY local.php /opt/mautic/app/config/local.php

RUN chown www-data:www-data /opt/mautic/app/config/local.php

VOLUME /opt/mautic/media/files
WORKDIR /opt/mautic
