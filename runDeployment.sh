#!/bin/bash -ex
echo "Deploying app.jar to docker folder"
packageName=`ls target/continuousintegrationandcontinuousdeliveryapp*.jar`
versionid=`echo $packageName | awk -F "-" '{ print $2}'`
versionname=`echo $packageName | awk -F "-" '{ print $3}' | awk -F "." '{ print $1}'`
version=`echo $versionid-$versionname`
echo "version: $version"
cp -r $packageName deployment/app.jar
dockerImageName=maju6406/jenkins-docker-webapp
dockerpid=`docker ps -a | grep $dockerImageName | grep "Up" | awk -F " " '{ print $1 }'`
if [[ $dockerpid != "" ]];then 
   docker kill $dockerpid
   docker rm $dockerpid
fi
docker build -t $dockerImageName deployment/.
docker run -d -p 8090:8090 $dockerImageName
dockerImageId=`docker images | grep $dockerImageName | grep latest | awk -F " " '{print $3}'` 
docker tag $dockerImageId $dockerImageName:$version
docker login -u $DOCKER_USER -p $DOCKER_PASSWORD
docker push $dockerImageName:$version
