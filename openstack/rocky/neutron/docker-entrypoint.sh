#! /bin/bash

set -eux

# Bootstrap database
until mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "SELECT 1"; do
  >&2 echo "Waiting for database"
  sleep 1
done

mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "CREATE DATABASE IF NOT EXISTS neutron"
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '${NEUTRON_DB_PASSWORD}';"
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '${NEUTRON_DB_PASSWORD}';"

# write config file
CONN="mysql+pymysql://neutron:${NEUTRON_DB_PASSWORD}@${MYSQL_HOST}/neutron"
export CONN

MY_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
export MY_IP

envsubst < /neutron.template > /etc/neutron/neutron.conf
envsubst < /m12_conf.template > /etc/neutron/plugins/ml2/ml2_conf.ini
envsubst < /linuxbridge_agent.template > /etc/neutron/plugins/ml2/linuxbridge_agent.ini
envsubst < /l3_agent.template > /etc/neutron/l3_agent.ini
envsubst < /dhcp_agent.template > /etc/neutron/dhcp_agent.ini

# sync db
neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head

BOOTSTRAP_FILE=/var/lib/neutron/.bootstrapped

if [ ! -f  ${BOOTSTRAP_FILE} ]; then
    # Wait for keystone
    until openstack catalog list; do
	>&2 echo "Waiting for keystone"
	sleep 1
    done

    # create networking user
    openstack user create ${NEUTRON_USER} --password ${NEUTRON_PASSWORD} --domain ${OS_SERVICE_DOMAIN_NAME}
    openstack role add --project service --user ${NEUTRON_USER} admin

    # create networking service
    openstack service create --name neutron --description "OpenStack Networking" network
    openstack endpoint create --region ${OS_REGION} network public http://${HOSTNAME}:9696
    openstack endpoint create --region ${OS_REGION} network admin http://${HOSTNAME}:9696
    openstack endpoint create --region ${OS_REGION} network internal http://${HOSTNAME}:9696
    
    touch ${BOOTSTRAP_FILE}    
fi

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
