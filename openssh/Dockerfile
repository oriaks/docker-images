FROM ubuntu:xenial
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy --no-install-recommends \
            libnss-extrausers \
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

RUN sed -i '/^\(passwd\|group\|shadow\):/{ s/$/ extrausers/; }' /etc/nsswitch.conf && \
    sed -i 's|^password.*pam_unix.so|password\t[success=2 default=ignore]\tpam_extrausers.so obscure sha512\n&|;' /etc/pam.d/common-password

RUN touch /var/lib/extrausers/group && \
    touch /var/lib/extrausers/gshadow && \
    touch /var/lib/extrausers/passwd && \
    touch /var/lib/extrausers/shadow && \
    touch /var/lib/extrausers/subgid && \
    touch /var/lib/extrausers/subuid && \
    chown root:shadow /var/lib/extrausers/gshadow && \
    chown root:shadow /var/lib/extrausers/shadow && \
    chmod 640 /var/lib/extrausers/gshadow && \
    chmod 640 /var/lib/extrausers/shadow

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 22/tcp
VOLUME /home
VOLUME /var/lib/extrausers
VOLUME /var/lib/ssh
WORKDIR /home

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "sshd" ]
