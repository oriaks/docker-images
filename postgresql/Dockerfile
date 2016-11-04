FROM debian:sid
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV PGSQL_VERSION=9.6

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy ca-certificates curl gnupg && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN curl -Ls "https://www.postgresql.org/media/keys/ACCC4CF8.asc" | apt-key add - && \
    echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' > /etc/apt/sources.list.d/postgresql.list
RUN apt-get update -qy && \
    apt-get install -qy gosu postgresql-${PGSQL_VERSION} && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /var/lib/postgresql/*

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 5432/tcp
VOLUME /var/lib/postgresql

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "postgres" ]
