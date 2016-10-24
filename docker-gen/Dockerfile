FROM jwilder/docker-gen:latest
MAINTAINER Michael Richard <michael.richard@oriaks.com>

RUN mkdir -p /etc/docker-gen/templates
COPY nginx.tmpl /etc/docker-gen/templates/

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "docker-gen" ]
