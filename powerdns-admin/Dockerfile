FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            libffi6 \
            libldap-2.4-2 \
            libmysqlclient18 \
            libsasl2-2 \
            python-virtualenv \
            virtualenv \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

RUN apt-get update -qy && \
    apt-get install -qy \
            bsdtar \
            ca-certificates \
            curl \
            && \
    mkdir -p /opt/powerdns-admin && \
    curl -fLsS "https://github.com/ngoduykhanh/PowerDNS-Admin/archive/master.tar.gz" | bsdtar -xf- --strip-components 1 -C /opt/powerdns-admin && \
    apt-get autoremove -qy --purge \
            bsdtar \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

RUN apt-get update -qy && \
    apt-get install -qy \
            gcc \
            libffi-dev \
            libldap2-dev \
            libmysqlclient-dev \
            libsasl2-dev \
            python-dev \
            python-pip \
            && \
    cd /opt/powerdns-admin && \
    virtualenv flask && \
    . ./flask/bin/activate && \
    pip install -r requirements.txt && \
    pip install MySQL-python && \
    apt-get autoremove -qy --purge \
            gcc \
            libffi-dev \
            libldap2-dev \
            libmysqlclient-dev \
            libsasl2-dev \
            python-dev \
            python-pip \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

COPY config.py /opt/powerdns-admin/config.py

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80/tcp
EXPOSE 443/tcp
WORKDIR /opt/powerdns-admin

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "run.py" ]
