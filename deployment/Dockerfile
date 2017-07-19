FROM centos
RUN  yum install -y wget
RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm"
RUN yum localinstall jdk-8u131-linux-x64.rpm -y
EXPOSE 8090
ADD  app.jar myApp.jar
ENTRYPOINT ["java","-jar","myApp.jar"]