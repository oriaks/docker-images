FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            apt-transport-https \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

RUN apt-get update -qy && \
    apt-get install -qy \
            curl \
            && \
    curl -fLsS 'https://download.pydio.com/pub/linux/debian/key/pubkey' | apt-key add - && \
    echo 'deb https://download.pydio.com/pub/linux/debian/ jessie-backports main' > /etc/apt/sources.list.d/pydio.list && \
    apt-get autoremove -qy --purge \
            curl \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

RUN apt-get update -qy && \
    apt-get install -qy \
            ca-certificates \
            pydio \
            pydio-all \
            ssl-cert \
            ssmtp \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY remoteip.conf /etc/apache2/mods-available/remoteip.conf

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

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "apache2" ]
