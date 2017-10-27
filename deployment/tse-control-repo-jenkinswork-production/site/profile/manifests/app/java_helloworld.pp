# Install java app as a service
class profile::app::java_helloworld (
     String $src_rpm = 'http://jenkins.pdx.puppet.vm/artifacts/helloworldjavaapp-latest.rpm',
     Boolean $install_service = true,
) {

  # Install Java
#  java::oracle { 'jdk8' :
#    ensure        => 'present',
#    url_hash      => '090f390dda5b47b9b721c7dfaa008135',
#    version_major => '8u144',
#    version_minor => 'b01',
#    java_se       => 'jdk',
#  }

  java::oracle { 'jdk8' :
    ensure        => 'present',
    version_major => '8u151',
    version_minor => 'b12',
    java_se       => 'jdk',
    url    => 'https://s3.amazonaws.com/saleseng/files/oracle/jdk-8u151-linux-x64.rpm',
  }



  # Install RPM
  package { 'helloworldjavaapp':
    ensure          => 'latest',
    provider        => 'rpm',
    source          => $src_rpm,
  }

  # Start service
  exec { 'helloworldjavaapp restart':
    command     => '/bin/systemctl restart helloworldjavaapp',
    creates     => '/tmp/restart-helloworldjavaapp',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    require =>  [ Package['helloworldjavaapp'], Java::Oracle['jdk8'] ],
  }

}
