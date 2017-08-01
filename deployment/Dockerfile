FROM centos

ENV PUPPET_AGENT_VERSION="1.8.2" R10K_VERSION="2.2.2" 

RUN rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm && \
    yum upgrade -y && \
    yum update -y && \
    yum install -y puppet-agent-"$PUPPET_AGENT_VERSION" && \
    mkdir -p /etc/puppetlabs/facter/facts.d/ && \
    yum clean all

RUN yum update -y && \
    yum install -y git && \
    /opt/puppetlabs/puppet/bin/gem install r10k:"$R10K_VERSION" --no-ri --no-rdoc && \
    yum clean all

#COPY control-repo/Puppetfile /Puppetfile
#RUN echo 192.168.0.95  gitlab.inf.puppet.vm gitlab >> /etc/hosts && \
#    echo 192.168.0.101 jenkins.pdx.puppet.vm jenkins centos-7-2.pdx.puppet.vm >> /etc/hosts
#    /opt/puppetlabs/puppet/bin/r10k puppetfile install --moduledir /etc/puppetlabs/code/modules

COPY Puppetfile /Puppetfile
RUN cat /Puppetfile
#RUN ls -la /etc/puppetlabs/code/environments/production/
COPY control-repo/ /etc/puppetlabs/code/environments/production/
# Removing unneeded metadata.json
RUN rm -rf /etc/puppetlabs/code/environments/production/site/profile/metadata.json
#RUN ls -la /etc/puppetlabs/code/environments/production/
#RUN cat /etc/puppetlabs/code/environments/production/site/profile/manifests/app/java_helloworld.pp
RUN /opt/puppetlabs/puppet/bin/r10k puppetfile install --moduledir /etc/puppetlabs/code/modules

COPY manifests /manifests
RUN /opt/puppetlabs/bin/puppet config print    
RUN echo SERVER_TEST
RUN cat /etc/hosts
#RUN ping -c 4 jenkins.pdx.puppet.vm
RUN yum update -y && \
#    /opt/puppetlabs/bin/puppet module list --tree && \
    FACTER_hostname=jenkins-docker-webapp /opt/puppetlabs/bin/puppet apply -e "class{ 'profile::app::java_helloworld':  src_rpm => 'http://192.168.0.101/artifacts/helloworldjavaapp-0.0.7-1.x86_64.rpm', install_service => false}" --verbose --show_diff --summarize  --app_management && \
    yum clean all

LABEL com.puppet.inventory="/inventory.json"
RUN /opt/puppetlabs/bin/puppet module install puppetlabs-inventory && \
    /opt/puppetlabs/bin/puppet inventory all > /inventory.json

EXPOSE 8090
#ADD  app.jar myApp.jar
ENTRYPOINT ["java","-jar","/opt/helloworldjavaapp/continuousintegrationandcontinuousdeliveryapp-0.0.7-SNAPSHOT.jar"]
