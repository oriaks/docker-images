FROM oriaks/php:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            php5-ldap \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

ENV PHPLDAPADMIN_VERSION 1.2.3

COPY php5.5.patch /tmp/php5.5.patch
RUN apt-get update -qy && \
    apt-get install -qy \
            bsdtar \
            ca-certificates \
            curl \
            patch \
            && \
    curl -fLsS "http://downloads.sourceforge.net/project/phpldapadmin/phpldapadmin-php5/${PHPLDAPADMIN_VERSION}/phpldapadmin-${PHPLDAPADMIN_VERSION}.tgz" | bsdtar -xf- --strip-components 1 -C /var/www/html && \
    patch -p1 -d /var/www/html < /tmp/php5.5.patch && \
    sed -i 's|password_hash|password_hash_custom|g;' /var/www/html/lib/TemplateRender.php && \
    apt-get autoremove -qy --purge \
            bsdtar \
            curl \
            patch \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/* \
           && \
    rm -rf /tmp/php5.5.patch

COPY apache2.conf /etc/apache2/vhost.d/default.conf
COPY config.php /var/www/html/config/config.php
COPY ldap.conf /etc/ldap/ldap.conf

RUN chown -R root:root /var/www/html && \
    chmod -R u=rwX,g=rX,o=rX /var/www/html

COPY docker-pre-entrypoint.sh /docker-pre-entrypoint.sh
RUN chmod +x /docker-pre-entrypoint.sh

ENTRYPOINT [ "/docker-pre-entrypoint.sh" ]
