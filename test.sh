#!/bin/bash

set -xe

docker rm -f "$CON_NAME" > /dev/null 2>&1 || true
docker run -d --name $CON_NAME $IMAGE

docker exec $CON_NAME ps ax|grep -i "jenkin[s]"
sleep 30
docker exec $CON_NAME wget -O - http://localhost:8080/login|grep -i jenkins

docker rm -f $CON_NAME

echo "---> The test pass"
