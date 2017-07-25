#!/bin/bash -ex
echo "Deploying app.jar to docker folder"
packageName=`ls target/continuousintegrationandcontinuousdeliveryapp*.jar`
versionid=`echo $packageName | awk -F "-" '{ print $2}'`
versionname=`echo $packageName | awk -F "-" '{ print $3}' | awk -F "." '{ print $1}'`
version=`echo $versionid-$versionname`
echo "version: $version"
rm -rf helloworld*.rpm
rm -rf /var/www/generic_website/artifacts/helloworld*.rpm
rm -rf /var/www/generic_website/artifacts/helloworld*.jar
cp -r $packageName /var/www/generic_website/artifacts
/usr/local/bin/fpm -s dir -t rpm -n helloworldjavaapp -v 0.0.7 $packageName=/opt/helloworldjavaapp/continuousintegrationandcontinuousdeliveryapp-0.0.7-SNAPSHOT.jar helloworldjavaapp.service=/etc/systemd/system/helloworldjavaapp.service
cp helloworld*.rpm /var/www/generic_website/artifacts
# Docker instructions
#echo $DOCKER_USER
#echo $DOCKER_PASSWORD
#cp -r $packageName deployment/app.jar
#dockerImageName=maju6406/jenkins-docker-webapp
#dockerpid=`docker ps -a | grep $dockerImageName | grep "Up" | awk -F " " '{ print $1 }'`
#if [[ $dockerpid != "" ]];then 
#   docker kill $dockerpid
#   docker rm $dockerpid
#fi
#docker build -t $dockerImageName deployment/.
#docker run -d -p 8090:8090 $dockerImageName
#dockerImageId=`docker images | grep $dockerImageName | grep latest | awk -F " " '{print $3}'` 
#docker tag $dockerImageId $dockerImageName:$version
#docker login -u $DOCKER_USER -p $DOCKER_PASSWORD
#docker push $dockerImageName:$version