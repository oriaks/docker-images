# openDCIM Dockerfile

FROM debian:jessie
MAINTAINER Karol Kozubal <karol.kozubal@oriaks.com>

COPY nonfree.list /etc/apt/sources.d/nonfree.list

RUN apt-get update -qy && \
    apt-get install -qy \
    apache2 \
    curl \
    graphviz \
    locales \
    php5 \
    php5-curl \
    php-gettext \
    php5-mysql \
    php5-snmp \
    snmp-mibs-downloader

# Fixing locale data, openDCIM uses this for setting the app language
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN cd /var/www && \
    curl -O http://opendcim.org/packages/openDCIM-4.3.1.tar.gz && \
    tar -xvf openDCIM-4.3.1.tar.gz && \
    rm -f openDCIM-4.3.1.tar.gz && \
    ln -s openDCIM-4.3.1 dcim

RUN chgrp -R www-data /var/www/dcim/pictures /var/www/dcim/drawings

COPY db.inc.php /var/www/dcim/db.inc.php 
COPY default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
COPY .htaccess /var/www/dcim/.htaccess

RUN htpasswd -cb /var/www/opendcim.password dcim dcim

RUN a2enmod ssl && \
    a2enmod rewrite && \
    a2ensite default-ssl && \
    service apache2 restart
 
ENV DCIM_MYSQL_HOST mysql 
ENV DCIM_DBNAME opendcim
ENV DCIM_DBUSER opendcim
ENV DCIM_DBPASS opendcim

EXPOSE 443

CMD ["-D", "FOREGROUND"]
ENTRYPOINT ["apachectl"]

# @TODO change webroot to /opt ... use a regular directory
# @TODO Add LDAP auth to apache
