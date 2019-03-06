#! /bin/bash

set -eux

MY_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
export MY_IP

# write config file
envsubst < /nova.template > /etc/nova/nova.conf
envsubst < /linuxbridge_agent.template > /etc/neutron/plugins/ml2/linuxbridge_agent.ini

# create state dir
mkdir -p /var/lib/nova/$HOSTNAME/CA
mkdir -p /var/lib/nova/$HOSTNAME/buckets
mkdir -p /var/lib/nova/$HOSTNAME/images
mkdir -p /var/lib/nova/$HOSTNAME/instances
mkdir -p /var/lib/nova/$HOSTNAME/keys
mkdir -p /var/lib/nova/$HOSTNAME/networks
mkdir -p /var/lib/nova/$HOSTNAME/tmp

# launch services
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
