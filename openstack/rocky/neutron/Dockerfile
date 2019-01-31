FROM ubuntu:18.04
MAINTAINER Evan Pipho <evan@10000coins.com>

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get -y --no-install-recommends install software-properties-common mysql-client \
 && add-apt-repository cloud-archive:rocky \
 && apt-get update \
 && apt-get -y --no-install-recommends install python-openstackclient 

RUN apt-get -y --no-install-recommends install iproute2 supervisor gettext neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod a+x /docker-entrypoint.sh

ADD neutron.conf /neutron.template
ADD m12_conf.ini /m12_conf.template
ADD linuxbridge_agent.ini /linuxbridge_agent.template
ADD l3_agent.ini /l3_agent.template
ADD dhcp_agent.ini /dhcp_agent.template

ENTRYPOINT ["/docker-entrypoint.sh"]