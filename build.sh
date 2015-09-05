#!/bin/bash

set -e

export CON_NAME=jenkins_t
export REG_URL=d.nicescale.com:5000
export IMAGE=jenkins
export TAGS="1.609.2"
export BASE_IMAGE=microimages/jre
JENKINS_WAR=/root/downloads/jenkins.war

docker pull $REG_URL/$BASE_IMAGE

docker tag -f $REG_URL/$BASE_IMAGE $BASE_IMAGE

cp $JENKINS_WAR ./

docker build -t $REG_URL/microimages/$IMAGE .

#./test.sh

echo "---> Starting push $REG_URL/microimages/$IMAGE:$VERSION"

for t in $TAGS; do
  docker tag -f $REG_URL/microimages/$IMAGE $REG_URL/microimages/$IMAGE:$t
done

docker push $REG_URL/microimages/$IMAGE
