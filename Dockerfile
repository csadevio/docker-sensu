# FROM phusion/baseimage
FROM ruby
MAINTAINER Christian Sakshaug <christian@csadevio.net>
# Based on good work at https://github.com/sstarcher/docker-sensu

RUN apt-get update
RUN apt-get install -y wget ca-certificates
RUN wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | apt-key add -
RUN echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list

#ENV PATH /opt/sensu/embedded/bin:$PATH
ENV PATH /opt/sensu/bin:$PATH

RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y sensu

RUN wget https://github.com/jwilder/dockerize/releases/download/v0.0.2/dockerize-linux-amd64-v0.0.2.tar.gz
RUN tar -C /usr/local/bin -xzvf dockerize-linux-amd64-v0.0.2.tar.gz

ENV DEFAULT_PLUGINS_REPO sensu-plugins

ADD templates /etc/sensu/templates
ADD bin /bin/
ADD generators /etc/sensu/generators

# Plugins needed for handlers
RUN /bin/install slack mailer pagerduty

# Plugins needed for checks and maybe handlers
RUN /bin/install aws consul docker dns etcd ftp graphite http redis elasticsearch

# Clean up
RUN apt-get autoremove -y
RUN apt-get -y clean
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 4567
VOLUME ["/etc/sensu/conf.d"]

# Client Config
ENV CLIENT_SUBSCRIPTIONS all,default

# Common Config
ENV RUNTIME_INSTALL ''
ENV LOG_LEVEL warn
ENV EMBEDDED_RUBY true
ENV CONFIG_FILE /etc/sensu/config.json
ENV CONFIG_DIR /etc/sensu/conf.d
ENV EXTENSION_DIR /etc/sensu/extensions
ENV PLUGINS_DIR /etc/sensu/plugins
ENV HANDLERS_DIR /etc/sensu/handlers

ENTRYPOINT ["/bin/start"]
