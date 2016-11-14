FROM oriaks/apache:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            libapache2-mod-php5 \
            && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

RUN a2dismod mpm_event && \
    a2enmod mpm_prefork
