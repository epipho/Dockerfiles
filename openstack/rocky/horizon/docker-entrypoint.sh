#! /bin/bash

set -ex

# set dashboard to root
sed -i "s#WSGIScriptAlias /horizon#WSGIScriptAlias /#" /etc/apache2/conf-available/openstack-dashboard.conf

source /etc/apache2/envvars
exec apache2 -DFOREGROUND
