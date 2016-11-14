FROM oriaks/node:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            build-essential \
            python \
            && \
    npm install -g tty.js && \
    apt-get autoremove -qy --purge \
            build-essential \
            python \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

RUN echo "" >> /etc/securetty && \
    echo "# Pseudo terminals" >> /etc/securetty && \
    for i in `seq 0 63`; do \
      echo "pts/$i" >> /etc/securetty; \
    done

RUN mkdir -p /root/.tty.js
COPY config.json /root/.tty.js/config.json

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "tty.js" ]
