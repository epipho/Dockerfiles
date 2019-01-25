FROM ubuntu:18.04
MAINTAINER Evan Pipho <evan@10000coins.com>

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get -y --no-install-recommends install build-essential python-dev python-setuptools python-pip \
 && pip install wheel \
 && pip install python-openstackclient

ENTRYPOINT ["sleep", "99999999999999999"]