FROM debian:jessie-backports
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy && \
    apt-get install -qy \
            apt-transport-https \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/*

ENV SOGO_VERSION 3

RUN apt-key adv --keyserver keys.gnupg.net --recv-key 0x810273C4 && \
    echo "deb http://packages.inverse.ca/SOGo/nightly/${SOGO_VERSION}/debian/ jessie jessie" > /etc/apt/sources.list.d/sogo.list

RUN apt-get update -qy && \
    apt-get install -qy \
            apache2 \
            ca-certificates \
            gosu \
            sogo \
            sogo-activesync \
            ssl-cert \
            ssmtp \
            sudo \
            && \
    apt-get autoremove -qy --purge \
            && \
    apt-get clean -qy && \
    rm -rf /tmp/* \
           /var/lib/apt/lists/* \
           /var/tmp/* \
           && \
    rm -rf /etc/ssl/certs/ssl-cert-snakeoil.pem \
           /etc/ssl/private/ssl-cert-snakeoil.key \
           /var/www/html/*

#apt-get purge \
#  autotools-dev \
#  binutils \
#  cpp \
#  cpp-4.9 \
#  dbus \
#  gcc \
#  gcc-4.9 \
#  gnustep-base-common \
#  gnustep-base-runtime \
#  gnustep-common \
#  gnustep-make \
#  gobjc \
#  gobjc-4.9 \
#  init-system-helpers \
#  libalgorithm-c3-perl \
#  libarchive-extract-perl \
#  libasan1 \
#  libatomic1 \
#  libavahi-client3 \
#  libavahi-common-data \
#  libavahi-common3 \
#  libc-dev-bin \
#  libc6-dev \
#  libcap-ng0 \
#  libcgi-fast-perl \
#  libcgi-pm-perl \
#  libcilkrts5 \
#  libclass-c3-perl \
#  libclass-c3-xs-perl \
#  libcloog-isl4 \
#  libcpan-meta-perl \
#  libcurl3 \
#  libdata-optlist-perl \
#  libdata-section-perl \
#  libdbus-1-3 \
#  libevent-2.0-5 \
#  libexpat1 \
#  libfcgi-perl \
#  libgcc-4.9-dev \
#  libgdbm3 \
#  libglib2.0-0 \
#  libglib2.0-data \
#  libgnustep-base1.24 \
#  libgomp1 \
#  libicu52 \
#  libisl10 \
#  libitm1 \
#  liblasso3 \
#  liblog-message-perl \
#  liblog-message-simple-perl \
#  liblsan0 \
#  libmemcached11 \
#  libmodule-build-perl \
#  libmodule-pluggable-perl \
#  libmodule-signature-perl \
#  libmpc3 \
#  libmpfr4 \
#  libmro-compat-perl \
#  libmysqlclient18 \
#  libobjc-4.9-dev \
#  libobjc4 \
#  libpackage-constants-perl \
#  libparams-util-perl \
#  libpod-latex-perl \
#  libpod-readme-perl \
#  libquadmath0 \
#  libregexp-common-perl \
#  libsbjson2.3 \
#  libsoftware-license-perl \
#  libsope-appserver4.9 \
#  libsope-core4.9 \
#  libsope-gdl1-4.9 \
#  libsope-ldap4.9 \
#  libsope-mime4.9 \
#  libsope-xml4.9 \
#  libsub-exporter-perl \
#  libsub-install-perl \
#  libterm-ui-perl \
#  libtext-soundex-perl \
#  libtext-template-perl \
#  libtsan0 \
#  libubsan0 \
#  libwbxml2-0 \
#  libxml2 \
#  libxmlsec1 \
#  libxmlsec1-openssl \
#  libxslt1.1 \
#  linux-libc-dev \
#  manpages \
#  manpages-dev \
#  memcached \
#  mysql-common \
#  perl \
#  perl-modules \
#  rename \
#  sgml-base \
#  shared-mime-info \
#  sope4.9-gdl1-mysql \
#  sope4.9-libxmlsaxdriver \
#  tmpreaper \
#  unzip \
#  xdg-user-dirs \
#  xml-core \
#  zip \
#

COPY ldap.conf /etc/ldap/ldap.conf
COPY sogo.conf /etc/sogo/sogo.conf
RUN chown -R sogo:sogo /etc/sogo

RUN mkdir -p /etc/apache2/vhost.d

COPY remoteip.conf /etc/apache2/mods-available/remoteip.conf
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY default.conf /etc/apache2/vhost.d/default.conf
COPY default-ssl.conf /etc/apache2/sites-available/default-ssl.conf

RUN sed -i 's|%h|%a|g;' /etc/apache2/apache2.conf

RUN for file in /etc/apache2/mods-enabled/*.conf; do \
      ln -sf `echo $file | sed 's|mods-enabled|mods-available|;'` $file; \
    done

RUN a2enmod expires && \
    a2enmod headers && \
    a2enmod proxy && \
    a2enmod proxy_http && \
    a2enmod remoteip && \
    a2enmod rewrite && \
    a2enmod ssl && \
    a2ensite default-ssl
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/2 /var/log/apache2/error.log

RUN sed -i 's|127.0.0.1|sogo|g;' /etc/apache2/conf-available/SOGo.conf

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 20000/tcp
VOLUME /var/lib/sogo
VOLUME /var/spool/sogo

#EXPOSE 80/tcp
#EXPOSE 443/tcp
#VOLUME /var/log/apache2

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "sogod" ]
#CMD [ "apache2" ]
