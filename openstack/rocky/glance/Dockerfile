FROM ubuntu:18.04
MAINTAINER Evan Pipho <evan@10000coins.com>

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get -y --no-install-recommends install software-properties-common mysql-client \
 && add-apt-repository cloud-archive:rocky \
 && apt-get update \
 && apt-get -y --no-install-recommends install python-openstackclient 

RUN apt-get -y --no-install-recommends install supervisor glance gettext

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod a+x /docker-entrypoint.sh

ADD glance-api.conf /glance-api.template

EXPOSE 9292

ENTRYPOINT ["/docker-entrypoint.sh"]