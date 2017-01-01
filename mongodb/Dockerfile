# mongodb standalone docker image

FROM debian:jessie
MAINTAINER Karol Kozubal <karol.kozubal@oriaks.com>
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 && \
    echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/testing main" > /etc/apt/sources.list.d/mongodb.list

RUN apt-get update -qy && \
    apt-get install -qy \
            mongodb-org \
            openssl \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY mongod.conf /etc/mongod.conf

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

VOLUME /var/lib/mongodb

# exposed port
EXPOSE 27017/tcp

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "mongod" ]
