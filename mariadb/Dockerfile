FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qy && \
    apt-get install -qy apt-transport-https && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0xcbcb082a1bb943db && \
    echo 'deb http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.1/debian jessie main' > /etc/apt/sources.list.d/mariadb.list
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 4D1BB29D63D98E422B2113B19334A25F8507EFA5 && \
    echo 'deb https://repo.percona.com/apt jessie main' > /etc/apt/sources.list.d/percona.list
RUN apt-get update -qy && \
    apt-get install -qy mariadb-client mariadb-server percona-xtrabackup && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /var/lib/mysql/* /var/log/mysql/*

RUN sed -i 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf

COPY docker.cnf /etc/mysql/conf.d/docker.cnf

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 3306/tcp
VOLUME /var/lib/mysql

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "mysqld" ]
