FROM alpine:3.8
MAINTAINER Evan Pipho <evan@10000coins.com>

RUN apk update \
 && apk add py-pip \
 && pip install --upgrade pip \
 && mkdir /data \
 && pip install pypiserver

EXPOSE 8080
VOLUME ["/data"]

ENTRYPOINT ["/usr/bin/pypi-server", "--port", "8080", "--passwords", ".", "--authenticate", ".", "--overwrite",  "/data"]
