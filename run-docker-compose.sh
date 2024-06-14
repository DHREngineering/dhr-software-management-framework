#!/bin/bash

docker compose run --build --detach --name printer11 -p 50011:8080 printer-service 11 bambu
docker compose run --build --detach --name printer12 -p 50012:8080 printer-service 12 bambu
docker compose run --build --detach --name printer13 -p 50013:8080 printer-service 13 bambu
docker compose run --build --detach --name printer14 -p 50014:8080 printer-service 14 bambu
docker compose run --build --detach --name printer15 -p 50015:8080 printer-service 15 bambu
docker compose run --build --detach --name printer21 -p 50021:8080 printer-service 21 bambu
docker compose run --build --detach --name printer22 -p 50022:8080 printer-service 22 bambu
docker compose run --build --detach --name printer23 -p 50023:8080 printer-service 23 bambu
docker compose run --build --detach --name printer24 -p 50024:8080 printer-service 24 bambu
docker compose run --build --detach --name printer25 -p 50025:8080 printer-service 25 bambu
docker compose run --build --detach --name printer31 -p 50031:8080 printer-service 31 bambu
docker compose run --build --detach --name printer32 -p 50032:8080 printer-service 32 bambu
docker compose run --build --detach --name printer33 -p 50033:8080 printer-service 33 bambu
docker compose run --build --detach --name printer34 -p 50034:8080 printer-service 34 bambu
docker compose run --build --detach --name printer35 -p 50035:8080 printer-service 35 bambu
docker compose run --build --detach --name printer41 -p 50041:8080 printer-service 41 bambu
docker compose run --build --detach --name printer42 -p 50042:8080 printer-service 42 bambu
docker compose run --build --detach --name printer43 -p 50043:8080 printer-service 43 bambu
docker compose run --build --detach --name printer44 -p 50044:8080 printer-service 44 bambu
docker compose run --build --detach --name printer45 -p 50045:8080 printer-service 45 bambu

docker compose run --build --detach --name pantheon-api -p 9971:9971 pantheon-api

docker compose run --name rabbitmq --build --detach -p 5672:5672 -p 15672:15672 -p 15692:15692 rabbitmq
# add admin user after rabbitmq is up
sleep 10
docker exec rabbitmq bash -c "rabbitmq-plugins enable rabbitmq_management &&
rabbitmqctl add_user admin admin &&
rabbitmqctl set_user_tags admin administrator &&
rabbitmqctl set_permissions -p / admin '.*' '.*' '.*'"

docker compose run --name mosquitto --build --detach -p 1883:1883 -p 9001:9001 mosquitto

if [ ! -d "/home/dhr/mysql" ]; then
    mkdir /home/dhr/mysql
    docker compose run --build mysql
    chown -R mysql:mysql /home/dhr/mysql
    chmod -R 770 /home/dhr/mysql
fi
docker compose run --build --detach --name printer-utilization printer-utilization

# exit with status 0 to prevent docker-cluster-controller.service from breaking
exit 0