FROM ubuntu:18.04
MAINTAINER Evan Pipho <evan@10000coins.com>

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get -y --no-install-recommends install software-properties-common mysql-client \
 && add-apt-repository cloud-archive:rocky \
 && apt-get update \
 && apt-get -y --no-install-recommends install python-openstackclient 

RUN apt-get -y --no-install-recommends install keystone

ADD keystone.conf /etc/keystone/keystone.conf

ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod a+x /docker-entrypoint.sh

EXPOSE 5000

ENTRYPOINT ["/docker-entrypoint.sh"]