#! /bin/bash

set -eux

# Bootstrap database
until mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "SELECT 1"; do
  >&2 echo "Waiting for database"
  sleep 1
done

mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "CREATE DATABASE IF NOT EXISTS glance"
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '${GLANCE_DB_PASSWORD}';"
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '${GLANCE_DB_PASSWORD}';"

# write config file
CONN="mysql+pymysql://glance:${GLANCE_DB_PASSWORD}@${MYSQL_HOST}/glance"
export CONN
envsubst < /glance-api.template > /etc/glance/glance-api.conf

# update db
glance-manage db_sync

BOOTSTRAP_FILE=/data/.bootstrapped

if [ ! -f  ${BOOTSTRAP_FILE} ]; then
    # Wait for keystone
    until openstack catalog list; do
	>&2 echo "Waiting for keystone"
	sleep 1
    done

    # create service project
    openstack project create ${OS_SERVICE_PROJECT_NAME} --domain ${OS_SERVICE_DOMAIN_NAME}

    # create user
    openstack user create ${GLANCE_USER} --password ${GLANCE_PASSWORD} --domain ${OS_SERVICE_DOMAIN_NAME}
    openstack role add --project service --user ${GLANCE_USER} admin

    # create service
    openstack service create --name glance --description "OpenStack Image" image
    openstack endpoint create --region ${OS_REGION} image public http://${HOSTNAME}:9292
    openstack endpoint create --region ${OS_REGION} image admin http://${HOSTNAME}:9292
    openstack endpoint create --region ${OS_REGION} image internal http://${HOSTNAME}:9292
    
    touch ${BOOTSTRAP_FILE}    
fi

exec glance-api
