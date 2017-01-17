FROM oriaks/php:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy \
            php5-gd \
            php5-imagick \
            php5-json \
            php5-ldap \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

ENV LDAP_ACCOUNT_MANAGER_VERSION 5.6

RUN apt-get update -qy && \
    apt-get install -qy \
            bsdtar \
            ca-certificates \
            curl \
            && \
    curl -fLsS "http://downloads.sourceforge.net/project/lam/LAM/${LDAP_ACCOUNT_MANAGER_VERSION}/ldap-account-manager-${LDAP_ACCOUNT_MANAGER_VERSION}.tar.bz2" | bsdtar -xf- --strip-components 1 -C /var/www/html && \
    apt-get autoremove -qy --purge \
            bsdtar \
            curl \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY apache2.conf /etc/apache2/vhost.d/default.conf
COPY config.cfg /var/www/html/config/config.cfg
COPY ldap.conf /etc/ldap/ldap.conf
COPY windows_samba4.conf /var/www/html/config/windows_samba4.conf

RUN chown -R root:root /var/www/html && \
    chmod -R u=rwX,g=rX,o=rX /var/www/html && \
    chmod u=rwx,g=rx,o=rx /var/www/html/lib/lamdaemon.pl && \
    chown -R www-data:www-data /var/www/html/config && \
    chown -R www-data:www-data /var/www/html/sess && \
    chown -R www-data:www-data /var/www/html/tmp

COPY docker-pre-entrypoint.sh /docker-pre-entrypoint.sh
RUN chmod +x /docker-pre-entrypoint.sh

ENTRYPOINT [ "/docker-pre-entrypoint.sh" ]
