FROM debian:stretch
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN echo 'deb http://httpredir.debian.org/debian stretch contrib' > /etc/apt/sources.list.d/contrib.list && \
    echo 'deb http://httpredir.debian.org/debian stretch non-free' > /etc/apt/sources.list.d/non-free.list

RUN apt-get update -qy && \
    apt-get install -qy \
            tomcat8 \
            ssl-cert \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/* \
           && \
    rm -rf /var/lib/tomcat8/webapps/ROOT/*

RUN apt-get update -qy && \
    apt-get install -qy \
            dcraw \
            fdkaac \
            ffmpeg \
            file \
            flac \
            ghostscript \
            gpac \
            imagemagick \
            lame \
            libimage-exiftool-perl \
            mp4v2-utils \
            openjdk-8-jre-headless \
            vorbis-tools \
            xxd \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/* \
           && \
    rm -rf /var/lib/mysql/* \
           /var/log/mysql/*

ENV RAZUNA_VERSION 1.9

RUN apt-get update -qy && \
    apt-get install -qy \
            bsdtar \
            ca-certificates \
            curl \
            && \
    mkdir -p /var/lib/tomcat8/webapps/ROOT && \
#    curl -fLsS "https://github.com/razuna/razuna/archive/Razuna-${RAZUNA_VERSION}.tar.gz" | bsdtar -xf- --strip-components 1 -C /var/lib/tomcat8/webapps/ROOT/ && \
    curl -fLsS "https://github.com/oriaks/razuna/archive/master.tar.gz" | bsdtar -xf- --strip-components 1 -C /var/lib/tomcat8/webapps/ROOT/ && \
    apt-get autoremove -qy --purge \
            bsdtar \
            curl \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

ENV RAZUNA_SEARCHSERVER_VERSION 2.4

RUN apt-get update -qy && \
    apt-get install -qy \
            bsdtar \
            ca-certificates \
            curl \
            && \
    mkdir -p /var/lib/tomcat8/webapps/razuna-searchserver && \
    curl -fLsS "https://github.com/razuna/razuna-searchserver/archive/razuna-searchserver-v${RAZUNA_SEARCHSERVER_VERSION}.tar.gz" | bsdtar -xf- --strip-components 1 -C /var/lib/tomcat8/webapps/razuna-searchserver/ && \
    apt-get autoremove -qy --purge \
            bsdtar \
            curl \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

RUN ln -s /usr/share/java/tomcat8-el-api-8.0.39.jar /usr/share/java/el-api-3.0.jar && \
    ln -s /usr/share/java/tomcat8-jsp-api-8.0.39.jar /usr/share/java/jsp-api-2.3.jar

RUN sed -i 's|8080|80|g;' /etc/tomcat8/server.xml

COPY circuit.xml.cfm /var/lib/tomcat8/webapps/ROOT/admin/controller/circuit.xml.cfm
COPY dsp_firsttime.cfm /var/lib/tomcat8/webapps/ROOT/admin/views/dsp_firsttime.cfm
COPY dsp_firsttime_account.cfm /var/lib/tomcat8/webapps/ROOT/admin/views/ajaxparts/dsp_firsttime_account.cfm
RUN sed -i 's|localhost:80.0|localhost|g;' /var/lib/tomcat8/webapps/ROOT/global/cfc/*.cfc
RUN echo '<cflocation url="raz1/dam/index.cfm">' > /var/lib/tomcat8/webapps/ROOT/index.cfm

COPY ogg-cover-art /usr/local/bin/ogg-cover-art
RUN chmod +x /usr/local/bin/ogg-cover-art

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80/tcp
EXPOSE 443/tcp
VOLUME /var/lib/tomcat8/webapps/ROOT/admin/backup
VOLUME /var/lib/tomcat8/webapps/ROOT/assets
VOLUME /var/lib/tomcat8/webapps/ROOT/db
VOLUME /var/lib/tomcat8/webapps/ROOT/raz1
VOLUME /var/lib/tomcat8/webapps/ROOT/raz2
VOLUME /var/lib/tomcat8/webapps/ROOT/WEB-INF/bluedragon
VOLUME /var/lib/tomcat8/webapps/razuna-searchserver/WEB-INF/bluedragon
VOLUME /var/lib/tomcat8/webapps/razuna-searchserver/WEB-INF/collections
WORKDIR /var/lib/tomcat8/webapps

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "java" ]
