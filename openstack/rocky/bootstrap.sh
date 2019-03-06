#! /bin/bash

# download cirrus test image
docker-compose exec cli bash -c "if [[ ! -f cirros-0.4.0.img ]]; then curl http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img -o cirros-0.4.0.img; fi"
docker-compose exec cli openstack image create --id c9e636ec-a045-4d06-8b28-5950da7c2279 --disk-format qcow2 --container-format bare --public --file cirros-0.4.0.img cirros-0.4.0 

# create flavor
docker-compose exec cli openstack flavor create --id b9e2836c-d1a8-4263-bff9-0896f36c505c --ram 512 --disk 2 --public m1.small
