FROM oriaks/php:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            php5-curl \
            php5-gd \
            php5-imap \
            php5-ldap \
            php5-mysql \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

ENV LIMESURVEY_VERSION 2.55.2+161103

RUN apt-get update -qy && \
    apt-get install -qy \
            bsdtar \
            ca-certificates \
            curl \
            && \
    curl -fLsS "https://github.com/LimeSurvey/LimeSurvey/archive/${LIMESURVEY_VERSION}.tar.gz" | bsdtar -xf- -C /var/www/html --strip-components 1 && \
    apt-get autoremove -qy --purge \
            bsdtar \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY apache2.conf /etc/apache2/vhost.d/default.conf
COPY dbconfig_view.php /var/www/html/application/views/installer/dbconfig_view.php
COPY ldap.conf /etc/ldap/ldap.conf

RUN chown -R root:root /var/www/html

COPY docker-pre-entrypoint.sh /docker-pre-entrypoint.sh
RUN chmod +x /docker-pre-entrypoint.sh

VOLUME /var/www/html/application/config
VOLUME /var/www/html/upload

ENTRYPOINT [ "/docker-pre-entrypoint.sh" ]
