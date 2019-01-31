#! /bin/bash

set -eux

# Bootstrap database
until mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "SELECT 1"; do
  >&2 echo "Waiting for database"
  sleep 1
done

mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "CREATE DATABASE IF NOT EXISTS nova"
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "CREATE DATABASE IF NOT EXISTS nova_cell0"
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "CREATE DATABASE IF NOT EXISTS nova_api"
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "CREATE DATABASE IF NOT EXISTS placement"

mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DB_PASSWORD}';"
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DB_PASSWORD}';"
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '${NOVA_DB_PASSWORD}';"
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY '${PLACEMENT_DB_PASSWORD}';"

mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DB_PASSWORD}';"
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DB_PASSWORD}';"
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '${NOVA_DB_PASSWORD}';"
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY '${PLACEMENT_DB_PASSWORD}';"

# write config file
NOVA_CONN="mysql+pymysql://nova:${NOVA_DB_PASSWORD}@${MYSQL_HOST}/nova"
API_CONN="mysql+pymysql://nova:${NOVA_DB_PASSWORD}@${MYSQL_HOST}/nova_api"
PLACEMENT_CONN="mysql+pymysql://placement:${PLACEMENT_DB_PASSWORD}@${MYSQL_HOST}/placement"

export NOVA_CONN
export API_CONN
export PLACEMENT_CONN

envsubst < /nova.template > /etc/nova/nova.conf

# update databases
nova-manage api_db sync
nova-manage cell_v2 map_cell0
nova-manage db sync

BOOTSTRAP_FILE=/var/lib/nova/.bootstrapped

if [ ! -f  ${BOOTSTRAP_FILE} ]; then
    # Wait for keystone
    until openstack catalog list; do
	>&2 echo "Waiting for keystone"
	sleep 1
    done

    # create compute user
    openstack user create ${NOVA_USER} --password ${NOVA_PASSWORD} --domain ${OS_SERVICE_DOMAIN_NAME}
    openstack role add --project service --user ${NOVA_USER} admin

    # create compute service
    openstack service create --name nova --description "OpenStack Compute" compute
    openstack endpoint create --region ${OS_REGION} compute public http://${HOSTNAME}:8774/v2.1
    openstack endpoint create --region ${OS_REGION} compute admin http://${HOSTNAME}:8774/v2.1
    openstack endpoint create --region ${OS_REGION} compute internal http://${HOSTNAME}:8774/v2.1

    # create placement user
    openstack user create ${PLACEMENT_USER} --password ${PLACEMENT_PASSWORD} --domain ${OS_SERVICE_DOMAIN_NAME}
    openstack role add --project service --user ${PLACEMENT_USER} admin

    # create compute service
    openstack service create --name placement --description "OpenStack Placement API" placement
    openstack endpoint create --region ${OS_REGION} placement public http://${HOSTNAME}:8778
    openstack endpoint create --region ${OS_REGION} placement admin http://${HOSTNAME}:8778
    openstack endpoint create --region ${OS_REGION} placement internal http://${HOSTNAME}:8778

    # create cells
    nova-manage cell_v2 create_cell --name=cell1 --verbose
    
    touch ${BOOTSTRAP_FILE}    
fi

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
