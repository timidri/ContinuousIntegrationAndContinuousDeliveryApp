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

COPY Puppetfile /Puppetfile
RUN /opt/puppetlabs/puppet/bin/r10k puppetfile install --moduledir /etc/puppetlabs/code/modules

COPY manifests /manifests
    
RUN yum update -y && \
    FACTER_hostname=jenkins-docker-webapp /opt/puppetlabs/bin/puppet apply manifests/init.pp --verbose --show_diff --summarize  --app_management && \
    yum clean all

LABEL com.puppet.inventory="/inventory.json"
RUN /opt/puppetlabs/bin/puppet module install puppetlabs-inventory && \
    /opt/puppetlabs/bin/puppet inventory all > /inventory.json

EXPOSE 8090
ADD  app.jar myApp.jar
ENTRYPOINT ["java","-jar","myApp.jar"]