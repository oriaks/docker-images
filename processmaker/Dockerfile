FROM oriaks/php:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            php5-curl \
            php5-gd \
            php5-ldap \
            php5-mcrypt \
            php5-mysql \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

ENV PROCESSMAKER_VERSION 3.0.1.8

RUN apt-get update -qy && \
    apt-get install -qy \
            bsdtar \
            ca-certificates \
            curl \
            && \
    curl -fLsS "http://downloads.sourceforge.net/project/processmaker/ProcessMaker/${PROCESSMAKER_VERSION}/processmaker-${PROCESSMAKER_VERSION}-community.tar.gz" | bsdtar -xf- -C /var/www/html --strip-components 1 && \
    apt-get autoremove -qy --purge \
            bsdtar \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY apache2.conf /etc/apache2/vhost.d/default.conf
COPY installer_cards.js /var/www/html/workflow/engine/templates/installer/installer_cards.js

RUN chown -R root:root /var/www/html

COPY docker-pre-entrypoint.sh /docker-pre-entrypoint.sh
RUN chmod +x /docker-pre-entrypoint.sh

VOLUME /var/www/html/shared
VOLUME /var/www/html/workflow/engine/js/labels

ENTRYPOINT [ "/docker-pre-entrypoint.sh" ]
