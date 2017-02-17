FROM debian:stretch
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            ca-certificates \
            samba \
            samba-dsdb-modules \
            samba-vfs-modules \
            winbind \
            && \
    rm -f /etc/samba/smb.conf && \
    find /var/run/samba /var/lib/samba /var/cache/samba /var/lib/samba/private -name '*.[lt]db' | xargs rm -f && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY ldap.conf /etc/ldap/ldap.conf
RUN ln -sf /var/lib/samba/private/krb5.conf /etc/krb5.conf

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 53/tcp
EXPOSE 53/udp
EXPOSE 88/tcp
EXPOSE 88/udp
EXPOSE 135/tcp
EXPOSE 137/udp
EXPOSE 138/udp
EXPOSE 139/tcp
EXPOSE 389/tcp
EXPOSE 389/udp
EXPOSE 445/tcp
EXPOSE 464/tcp
EXPOSE 464/udp
EXPOSE 636/tcp
EXPOSE 1024/tcp
EXPOSE 3268/tcp
EXPOSE 3269/tcp
VOLUME /etc/samba
VOLUME /var/cache/samba
VOLUME /var/lib/samba
VOLUME /var/run/samba

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "samba" ]
