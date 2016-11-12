FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy \
            unbound \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/* \
           && \
    rm -rf /etc/unbound/*.key \
           /etc/unbound/*.pem

COPY interface.conf /etc/unbound/unbound.conf.d/interface.conf

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 53/tcp
EXPOSE 53/udp
EXPOSE 8953/tcp
EXPOSE 8953/udp

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "unbound" ]
