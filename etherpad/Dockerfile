FROM oriaks/node:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

ENV ETHERPAD_VERSION 1.6.0

RUN apt-get update -qy && \
    apt-get install -qy \
            bsdtar \
            build-essential \
            ca-certificates \
            curl \
            git \
            libssl-dev \
            pkg-config \
            python \
            && \
    mkdir -p /opt/etherpad && \
    curl -fLsS "https://github.com/ether/etherpad-lite/archive/${ETHERPAD_VERSION}.tar.gz" | bsdtar -xf- --strip-components 1 -C /opt/etherpad && \
    /opt/etherpad/bin/installDeps.sh && \
    apt-get autoremove -qy --purge \
            bsdtar \
            build-essential \
            ca-certificates \
            curl \
            git \
            libssl-dev \
            pkg-config \
            python \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY settings.json /opt/etherpad/settings.json

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

WORKDIR /opt/etherpad

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "node" ]
