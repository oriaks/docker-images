FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            apache2 \
            ca-certificates \
            openssh-sftp-server \
            ssl-cert \
            ssmtp \
            sudo \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/* \
           && \
    rm -rf /etc/ssl/certs/ssl-cert-snakeoil.pem \
           /etc/ssl/private/ssl-cert-snakeoil.key \
           /var/www/html/*

RUN mkdir -p /etc/apache2/vhost.d

COPY remoteip.conf /etc/apache2/mods-available/remoteip.conf
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
COPY default.conf /etc/apache2/vhost.d/default.conf

RUN sed -i 's|%h|%a|g;' /etc/apache2/apache2.conf

RUN for file in /etc/apache2/mods-enabled/*.conf; do \
      ln -sf `echo $file | sed 's|mods-enabled|mods-available|;'` $file; \
    done

RUN a2enmod expires && \
    a2enmod remoteip && \
    a2enmod rewrite && \
    a2enmod ssl && \
    a2ensite default-ssl

RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/2 /var/log/apache2/error.log

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80/tcp
EXPOSE 443/tcp
VOLUME /var/log/apache2
WORKDIR /var/www/html

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "apache2" ]
