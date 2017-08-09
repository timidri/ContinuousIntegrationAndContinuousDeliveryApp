#!/bin/bash -ex
packageName=`ls target/continuousintegrationandcontinuousdeliveryapp*.jar`
versionid=`echo $packageName | awk -F "-" '{ print $2}'`
versionname=`echo $packageName | awk -F "-" '{ print $3}' | awk -F "." '{ print $1}'`
version=`echo $versionid-$versionname`
echo "version: $version"
dockerImageName=maju6406/jenkins-docker-webapp
dockerpid=`docker ps -a | grep $dockerImageName | grep "Up" | awk -F " " '{ print $1 }'`
if [[ $dockerpid != "" ]];then 
   docker kill $dockerpid
   docker rm $dockerpid
fi
echo "Building Docker image"
docker build -t $dockerImageName deployment/.
echo "Running Docker container"
docker run --net host --add-host jenkins.pdx.puppet.vm:192.168.0.101 -p 8090:8090 -d $dockerImageName
#dockerImageId=`docker images | grep $dockerImageName | grep latest | awk -F " " '{print $3}'` 
#docker tag $dockerImageId $dockerImageName:$version
#docker login -u $DOCKER_USER -p $DOCKER_PASSWORD
#echo "Pushing image to DockerHub"
#docker push $dockerImageName:$version
