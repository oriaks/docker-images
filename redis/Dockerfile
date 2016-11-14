# redis standalone docker image

FROM debian:jessie
MAINTAINER Karol Kozubal <karol.kozubal@oriaks.com>

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
    bsdtar \
    curl \
    ca-certificates \
    gcc \
    make \
    openssh-server \
    sed \
    ssl-cert \
    tcl
    
# cleanup
RUN apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /etc/redis && \
    mkdir /opt/redis && \
    mkdir /tmp/redis && \
    curl http://download.redis.io/redis-stable.tar.gz | bsdtar -xf- -C /tmp/redis && \
    cd /tmp/redis/redis-stable && \
    make && \
    make test && \
    make install

COPY redis.conf /opt/redis/redis.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# exposed port
EXPOSE 6379

VOLUME /etc/redis
VOLUME /opt/redis

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "redis-server" ]

