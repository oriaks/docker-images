# mongodb standalone docker image

FROM debian:jessie
MAINTAINER Karol Kozubal <karol.kozubal@oriaks.com>

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 && \
    echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/testing main" > /etc/apt/sources.list.d/mongodb-org-3.4.list && \
    apt-get update -qy && \
    apt-get install -qy \
    apt-utils \
    openssl \
    mongodb-org

#COPY mongo.conf /etc/mongod.conf

# cleanup
RUN apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /var/lib/mongodb && mkdir -p /var/log/mongodb

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

VOLUME /var/lib/mongodb
VOLUME /var/log/mongodb

# exposed port
EXPOSE 27017

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "mongod" ]

