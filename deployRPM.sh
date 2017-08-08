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
echo $BUILD_NUMBER > BUILD_NUMBER
echo  $PWD
/usr/local/bin/fpm -s dir -t rpm -n helloworldjavaapp -v $BUILD_NUMBER --after-install $PWD/after-install.sh $packageName=/opt/helloworldjavaapp/continuousintegrationandcontinuousdeliveryapp-0.0.7-SNAPSHOT.jar helloworldjavaapp.service=/etc/systemd/system/helloworldjavaapp.service BUILD_NUMBER=/opt/helloworldjavaapp/BUILD_NUMBER
mv helloworldjavaapp-$BUILD_NUMBER-1.x86_64.rpm helloworldjavaapp-latest.rpm
echo "Deploying to artifact repository"
cp helloworld*.rpm /var/www/generic_website/artifacts