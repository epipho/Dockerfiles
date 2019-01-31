#! /bin/bash

set -eux

# write config file
envsubst < /nova.template > /etc/nova/nova.conf

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
