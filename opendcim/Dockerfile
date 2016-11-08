# openDCIM Dockerfile
# @TODO Add LDAP authentication for Apache
# @TODO 

FROM debian:jessie
MAINTAINER Karol Kozubal <karol.kozubal@oriaks.com>

EXPOSE 443

ENV DCIM_MYSQL_HOST mysql 
ENV DCIM_DBNAME opendcim
ENV DCIM_DBUSER opendcim
ENV DCIM_DBPASS opendcim
ENV DEBIAN_FRONTEND=noninteractive

COPY sources.list /etc/apt/sources.list

RUN apt-get update -y && \
    apt-get install -y \
    apache2 \
    graphviz \
    locales \
    php5 \
    php5-curl \
    php-gettext \
    php5-mysql \
    php5-snmp \
    snmp-mibs-downloader \
    wget

# Fixing locale data, openDCIM uses this for setting the app language
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN cd /var/www && \
    wget http://opendcim.org/packages/openDCIM-4.3.1.tar.gz && \
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

CMD ["-D", "FOREGROUND"]
ENTRYPOINT ["apachectl"]
