FROM oriaks/php:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV PHPLDAPADMIN_VERSION 1.2.3

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy bsdtar ca-certificates curl patch && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /opt/phpldapadmin && \
    curl -Ls "http://downloads.sourceforge.net/project/phpldapadmin/phpldapadmin-php5/${PHPLDAPADMIN_VERSION}/phpldapadmin-${PHPLDAPADMIN_VERSION}.tgz" | bsdtar -xf- --strip-components 1 -C /opt/phpldapadmin && \
    chown -R root:root /opt/phpldapadmin && \
    chmod -R u=rwX,g=rX,o=rX /opt/phpldapadmin

COPY apache2.conf /etc/apache2/vhost.d/default.conf
COPY config.php /opt/phpldapadmin/config/config.php
COPY ldap.conf /etc/ldap/ldap.conf
COPY php5.5.patch /opt/phpldapadmin/

RUN patch -p1 -d /opt/phpldapadmin < /opt/phpldapadmin/php5.5.patch && \
    sed -i 's|password_hash|password_hash_custom|g;' /opt/phpldapadmin/lib/TemplateRender.php

WORKDIR /opt/phpldapadmin
