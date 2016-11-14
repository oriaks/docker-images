FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy --no-install-recommends \
            openssh-server \
            rsync \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/* \
           && \
    rm -rf /etc/ssh/ssh_host_*key*

RUN mkdir -p /var/lib/ssh

RUN sed -i 's|^PermitRootLogin .*|PermitRootLogin yes|;' /etc/ssh/sshd_config && \
    sed -i 's|/etc/ssh/ssh_host_|/var/lib/ssh/ssh_host_|g;' /etc/ssh/sshd_config

RUN echo "" >> /etc/securetty && \
    echo "# Pseudo terminals" >> /etc/securetty && \
    for i in `seq 0 63`; do \
      echo "pts/$i" >> /etc/securetty; \
    done

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 22/tcp
VOLUME /home
VOLUME /var/lib/ssh
WORKDIR /home

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "sshd" ]
