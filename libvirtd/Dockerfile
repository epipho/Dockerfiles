FROM ubuntu:18.04
MAINTAINER Evan Pipho <evan@10000coins.com>

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get -y --no-install-recommends install libvirt-daemon-system qemu supervisor iptables ebtables iproute2 dmidecode dnsmasq

# add ca-cert for TLS
ADD certs/ca_cert.pem /etc/pki/CA/cacert.pem

# add server key and cert
ADD certs/server_cert.pem /etc/pki/libvirt/servercert.pem
ADD certs/server_key.pem /etc/pki/libvirt/private/serverkey.pem

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 6910

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
