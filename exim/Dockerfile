FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            ca-certificates \
            exim4-daemon-light \
            ssl-cert \
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

RUN echo "" > /etc/mailname && \
    sed -i "s|^dc_eximconfig_configtype=.*|dc_eximconfig_configtype='internet'|;" /etc/exim4/update-exim4.conf.conf && \
    sed -i "s|^dc_local_interfaces=.*|dc_local_interfaces='0.0.0.0'|;" /etc/exim4/update-exim4.conf.conf && \
    sed -i "s|^dc_other_hostnames=.*|dc_other_hostnames=''|;" /etc/exim4/update-exim4.conf.conf && \
    update-exim4.conf -v

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 25/tcp
EXPOSE 465/tcp
EXPOSE 587/tcp
VOLUME /var/spool/exim4
VOLUME /var/spool/mail

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "exim4" ]
