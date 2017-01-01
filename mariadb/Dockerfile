FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            apt-transport-https \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

ENV MARIADB_VERSION 10.1

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0xcbcb082a1bb943db && \
    echo "deb http://nyc2.mirrors.digitalocean.com/mariadb/repo/${MARIADB_VERSION}/debian jessie main" > /etc/apt/sources.list.d/mariadb.list

RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 4D1BB29D63D98E422B2113B19334A25F8507EFA5 && \
    echo 'deb https://repo.percona.com/apt jessie main' > /etc/apt/sources.list.d/percona.list

RUN apt-get update -qy && \
    apt-get install -qy \
            galera-3 \
            gettext-base \
            mariadb-client \
            mariadb-server \
            percona-xtrabackup \
            ssl-cert \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/* \
           && \
    rm -rf /var/lib/mysql/* \
           /var/log/mysql/* \
           && \
    rm -rf /etc/ssl/certs/ssl-cert-snakeoil.pem \
           /etc/ssl/private/ssl-cert-snakeoil.key

COPY docker.cnf /etc/mysql/conf.d/docker.cnf
COPY ssl.cnf /etc/mysql/conf.d/ssl.cnf
COPY wsrep.cnf /etc/mysql/conf.d/wsrep.cnf.template

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 3306/tcp
EXPOSE 4444/tcp
EXPOSE 4567/tcp
EXPOSE 4568/tcp
VOLUME /var/lib/mysql

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "mysqld" ]
