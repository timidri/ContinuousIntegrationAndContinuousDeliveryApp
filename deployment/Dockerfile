FROM puppetseteam/demobase

ARG BUILDNUM="no_build_number"
RUN echo "Distelli Build Number: $BUILDNUM"

COPY continuousintegrationandcontinuousdeliveryapp-0.0.7-SNAPSHOT.jar /opt/helloworldjavaapp/continuousintegrationandcontinuousdeliveryapp-0.0.7-SNAPSHOT.jar
COPY BUILD_NUMBER /opt/helloworldjavaapp/BUILD_NUMBER
RUN cat /opt/helloworldjavaapp/BUILD_NUMBER
ENTRYPOINT ["java","-jar","/opt/helloworldjavaapp/continuousintegrationandcontinuousdeliveryapp-0.0.7-SNAPSHOT.jar"]
