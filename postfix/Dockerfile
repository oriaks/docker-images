FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            ca-certificates \
            postfix \
            postfix-ldap \
            rsyslog \
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
           /etc/ssl/private/ssl-cert-snakeoil.key

RUN apt-get update -qy && \
    apt-get install -qy \
            mailutils \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

#COPY aliases.d /etc/postfix/aliases.d
COPY ldap.conf /etc/ldap/ldap.conf
#COPY login-maps.d /etc/postfix/login-maps.d
#COPY mailboxes.d /etc/postfix/mailboxes.d
COPY main.cf /etc/postfix/main.cf
COPY master.cf /etc/postfix/master.cf
#COPY virtual_domains /etc/postfix/virtual_domains

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 25/tcp
EXPOSE 465/tcp
EXPOSE 587/tcp

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "master" ]
