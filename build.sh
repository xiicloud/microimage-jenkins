#!/bin/bash

set -e

export CON_NAME=jenkins_t
export REG_URL=d.nicescale.com:5000
export IMAGE=jenkins
export TAGS="1.625.2"
export BASE_IMAGE=microimages/jdk
JENKINS_WAR=/root/downloads/jenkins.war

docker pull $BASE_IMAGE

#cp $JENKINS_WAR ./

docker build -t microimages/$IMAGE .

#./test.sh

echo "---> Starting push microimages/$IMAGE:$VERSION"

for t in $TAGS; do
  docker tag -f microimages/$IMAGE microimages/$IMAGE:$t
done

docker push microimages/$IMAGE
