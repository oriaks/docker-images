FROM debian:jessie
MAINTAINER Michael Richard <michael.richard@oriaks.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 && \
    echo 'deb http://nginx.org/packages/debian/ jessie nginx' > /etc/apt/sources.list.d/nginx.list
RUN apt-get update -qy && \
    apt-get install -qy ca-certificates nginx ssl-cert && \
    apt-get autoremove -qy --purge && \
    apt-get clean -qy && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -f /etc/ssl/certs/ssl-cert-snakeoil.pem /etc/ssl/private/ssl-cert-snakeoil.key

RUN ln -sf /proc/self/fd/1 /var/log/nginx/access.log && \
    ln -sf /proc/self/fd/2 /var/log/nginx/error.log

COPY default.conf /etc/nginx/conf.d/

RUN mkdir -p /var/www && \
    cp -Rp /usr/share/nginx/html /var/www/

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80/tcp
EXPOSE 443/tcp
VOLUME /var/www/html
WORKDIR /var/www/html

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "nginx" ]
