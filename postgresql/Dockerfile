FROM debian:sid
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            ca-certificates \
            curl \
            gnupg \
            && \
    curl -fLsS "https://www.postgresql.org/media/keys/ACCC4CF8.asc" | apt-key add - && \
    echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' > /etc/apt/sources.list.d/postgresql.list && \
    apt-get autoremove -qy --purge \
            ca-certificates \
            curl \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

ENV PGSQL_VERSION=9.6

RUN apt-get update -qy && \
    apt-get install -qy \
            gosu \
            postgresql-${PGSQL_VERSION} \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/* \
           && \
    rm -rf /var/lib/postgresql/*

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 5432/tcp
VOLUME /var/lib/postgresql

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "postgres" ]
