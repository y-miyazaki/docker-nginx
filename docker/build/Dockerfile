#--------------------------------------------------------------
# build image
#--------------------------------------------------------------
ARG NGINX_VERSION=1.17.5-alpine
FROM nginx:${NGINX_VERSION}

#--------------------------------------------------------------
# Install dependent packages
#--------------------------------------------------------------
RUN apk update && \
  apk --no-cache add curl dnsmasq && \
  # forward request and error logs to docker log collector
  ln -sf /dev/stdout /var/log/nginx/access.log && \
  ln -sf /dev/stderr /var/log/nginx/error.log && \
  # remove default.conf for security
  rm -f /etc/nginx/conf.d/default.conf

#--------------------------------------------------------------
# copy template and error files.
#--------------------------------------------------------------
COPY nginx/nginx.template.conf /etc/nginx/
COPY nginx/proxy.template.conf /etc/nginx/conf.d/
COPY robots/ /etc/nginx/robots/

#--------------------------------------------------------------
# setting shells
#--------------------------------------------------------------
COPY ./shell /shell
RUN chmod 775 /shell/* && \
  mv /shell/* /usr/local/bin/ && \
  rm -rf /shell

ENTRYPOINT []
CMD ["/usr/local/bin/cmd"]
