#! /bin/bash

set -eux

# Bootstrap database
until mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "SELECT 1"; do
  >&2 echo "Waiting for database"
  sleep 1
done

mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "CREATE DATABASE IF NOT EXISTS keystone"
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '${KEYSTONE_DB_PASSWORD}';"
mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '${KEYSTONE_DB_PASSWORD}';"

CONNECTION_STRING="mysql+pymysql://keystone:${KEYSTONE_DB_PASSWORD}@${MYSQL_HOST}/keystone"
sed -i "s#{{CONN}}#${CONNECTION_STRING}#" /etc/keystone/keystone.conf

# populate database
keystone-manage db_sync
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

# boostrap identity
keystone-manage bootstrap --bootstrap-password ${OS_PASSWORD} \
  --bootstrap-username ${OS_USERNAME} \
  --bootstrap-admin-url http://${HOSTNAME}:5000/v3/ \
  --bootstrap-internal-url http://${HOSTNAME}:5000/v3/ \
  --bootstrap-public-url http://${HOSTNAME}:5000/v3/ \
  --bootstrap-region-id ${OS_REGION}

exec /usr/bin/keystone-wsgi-public --port 5000
