FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            ca-certificates \
            dovecot-imapd \
            dovecot-ldap \
            dovecot-lmtpd \
            dovecot-managesieved \
            dovecot-pop3d \
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

COPY 10-auth.conf /etc/dovecot/conf.d/10-auth.conf
COPY 10-logging.conf /etc/dovecot/conf.d/10-logging.conf
COPY 10-mail.conf /etc/dovecot/conf.d/10-mail.conf
COPY 10-master.conf /etc/dovecot/conf.d/10-master.conf
COPY 10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf
COPY 15-lda.conf /etc/dovecot/conf.d/15-lda.conf
COPY 15-mailboxes.conf /etc/dovecot/conf.d/15-mailboxes.conf
COPY auth-ldap.conf.ext /etc/dovecot/conf.d/auth-ldap.conf.ext
COPY dovecot-ldap.conf.ext /etc/dovecot/dovecot-ldap.conf.ext
COPY ldap.conf /etc/ldap/ldap.conf

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 24/tcp
EXPOSE 110/tcp
EXPOSE 143/tcp
EXPOSE 993/tcp
EXPOSE 995/tcp
EXPOSE 3659/tcp
EXPOSE 4190/tcp

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "dovecot" ]
