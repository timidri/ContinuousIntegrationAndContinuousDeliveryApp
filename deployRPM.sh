#!/bin/bash -ex
packageName=`ls target/continuousintegrationandcontinuousdeliveryapp*.jar`
versionid=`echo $packageName | awk -F "-" '{ print $2}'`
versionname=`echo $packageName | awk -F "-" '{ print $3}' | awk -F "." '{ print $1}'`
version=`echo $versionid-$versionname`
echo "version: $version"
echo "Cleaning up previous artifacts"
rm -rf helloworld*.rpm
rm -rf /var/www/generic_website/artifacts/helloworld*.rpm
rm -rf /var/www/generic_website/artifacts/helloworld*.jar
cp -r $packageName /var/www/generic_website/artifacts
echo "Create RPM"
/usr/local/bin/fpm -s dir -t rpm -n helloworldjavaapp -v 0.0.7 $packageName=/opt/helloworldjavaapp/continuousintegrationandcontinuousdeliveryapp-0.0.7-SNAPSHOT.jar helloworldjavaapp.service=/etc/systemd/system/helloworldjavaapp.service
echo "Deploying to artifact repository"
cp helloworld*.rpm /var/www/generic_website/artifacts