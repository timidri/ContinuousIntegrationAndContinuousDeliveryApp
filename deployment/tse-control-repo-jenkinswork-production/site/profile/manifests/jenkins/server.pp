# Requires rtyler/jenkins module
class profile::jenkins::server (
  Optional[String] $gms_api_token = '',
  Optional[String] $gitlab_domain = 'gitlab.inf.puppet.vm',  
 ){
  
  $gms_server_url = "https://${$gitlab_domain}"
  $jenkins_path     = '/var/lib/jenkins'
  $jenkins_service_user      = 'jenkins_service_user'
  $token_directory  = "${jenkins_path}/.puppetlabs"
  $token_filename   = "${token_directory}/${$jenkins_service_user}_token"
  $jenkins_service_user_password = fqdn_rand_string(40, '', "${jenkins_service_user}_password")
  $jenkins_ssh_key_directory   = "${jenkins_path}/.ssh"
  $jenkins_ssh_key_file_name = 'id-control_repo.rsa'
  $jenkins_ssh_key_file = "${jenkins_ssh_key_directory}/${jenkins_ssh_key_file_name}"
  $git_management_system     = 'gitlab'
  $jenkins_role_name         = 'Code Deployers'
  $control_repo_project_name = 'puppet/control-repo'

$token_script = @(EOT)
OUTPUT=`/bin/curl -sS -k -X POST -H 'Content-Type: application/json' -d '{"login": "admin", "password": "puppetlabs", "lifetime": "1y"}' https://master.inf.puppet.vm:4433/rbac-api/v1/auth/token | python -c "import json,sys;obj=json.load(sys.stdin);print obj['token'];" >/var/lib/jenkins/.puppetlabs/token`
| EOT

  $html_contents = "<h1>Tokens and Keys!</h1><a href='pubkey.html'>Jenkins User SSH Key</a><br/><a href='auth_token.html'>Puppet Auth Token</a>"
  $doc_root = '/var/www/generic_website'

  $enhancers = [ 'ruby-devel', 'gcc', 'make', 'rpm-build', 'rubygems' ]


# Generate ssh key for jenkins user
  file { $jenkins_ssh_key_directory:
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0755',
  }  
  
  exec { 'create ssh key for jenkins user':
    cwd         => $jenkins_ssh_key_directory,
    command     => "/bin/ssh-keygen -t rsa -b 2048 -C 'jenkins' -f ${jenkins_ssh_key_file} -q -N '' && ssh-keyscan ${$gitlab_domain} >> ~/.ssh/known_hosts",
    user        => 'jenkins',
    creates     => $jenkins_ssh_key_file,  
    environment => ["HOME=${jenkins_path}"],
    require => File[ "${jenkins_path}/.ssh/"],
  }  

# For simplicity, make a copy of pub key available on webserver
  exec { 'Copy ssh key to webserver':
    command     => "/bin/cp ${jenkins_ssh_key_file}.pub /var/www/generic_website/pubkey.html",
    creates     => '/tmp/public_key_token_web',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    require =>  [ Exec['create ssh key for jenkins user'],],
  }
  
  file { "/var/www/generic_website/pubkey.html":
    ensure  => file,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0777',  
    require =>  [ Exec['Copy ssh key to webserver'] ],    
  }  

  file { $token_directory:
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0755',
  }  

# create Puppet auth token
  file { "/tmp/create_token.sh":
    ensure  => file,
    content => $token_script,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0755',  
  }

  exec { 'Create Puppet Auth Token':
    command     => '/tmp/create_token.sh',
    creates     => '/tmp/create-auth-token',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    require =>  [ File["/tmp/create_token.sh"], File[ "$token_directory"],],
  }
  
# For simplicity, make a copy of the Puppet Auth token available on webserver
  exec { 'Copy auth token to webserver':
    command     => "/bin/cp /var/lib/jenkins/.puppetlabs/token /var/www/generic_website/auth_token.html",
    creates     => '/tmp/auth_token_web',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    require =>  [ Exec['Create Puppet Auth Token'],],
  }
  
  file { '/var/www/generic_website/auth_token.html':
    ensure  => file,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0777',  
    require =>  [ Exec['Copy auth token to webserver'] ],    
  }  
  
  file { "/var/www/generic_website/index.html":
    ensure  => file,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0777',  
    content => $html_contents,
    require => [ File['/var/www/generic_website/auth_token.html'] ],    
  }    

# if gitlab token is provided, try inserting the deploy key into gitlab directly 
  if $gms_api_token != '' {
    git_deploy_key { "add_deploy_key_to_puppet_control":
      ensure       => present,
      name         => 'jenkins-deploy-key',
      path         => "${jenkins_ssh_key_file}.pub",
      token        => $gms_api_token,
      project_name => $control_repo_project_name,
      server_url   => $gms_server_url,
      provider     => $git_management_system,
      require => Exec[ 'create ssh key for jenkins user'],
    }  
  } 

# Include docker, wget, git, and apache (generic website)
  include wget
  include docker
  include git  

# install apache
  if !defined(Package['unzip']) {
    package { 'unzip': ensure => present; }
  }

  class { 'apache':
    default_vhost => false,
  }

  file { $doc_root:
    ensure => directory,
    owner  => $::apache::user,
    group  => $::apache::group,
    mode   => '0755',
  }

  apache::vhost { $::fqdn:
    port    => '80',
    docroot => $doc_root,
    require => File[$doc_root],
  }


# install java
  java::oracle { 'jdk8' :
    ensure        => 'present',
    url_hash      => 'd54c1d3a095b4ff2b6607d096fa80163',
    version_major => '8u131',
    version_minor => 'b11',
    java_se       => 'jdk',
  }

# install jenkins
  class { 'jenkins':
    configure_firewall => true,
    direct_download    => 'http://pkg.jenkins-ci.org/redhat/jenkins-2.62-1.1.noarch.rpm',
    require            => Java::Oracle['jdk8'],
  }

#unpack pre-baked jenkins config data
  archive {  "${jenkins_path}/xmls.tar.gz":
    source        => 'puppet:///modules/profile/xmls.tar.gz',
    extract       => true,
    extract_path  => $jenkins_path,
    creates       => "/tmp/xmls-file", #directory inside tgz
    require       => [ Class['jenkins'] ],
  }

# set up pipeline
  file { "${jenkins_path}/jobs/Pipeline/":
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0755',
    require => Class['jenkins']
  }

  file { "${jenkins_path}/jobs/Pipeline/config.xml":
    ensure  => file,  
    owner   => 'jenkins',
    group   => 'jenkins',
    source  => 'puppet:///modules/profile/PipelineConfig.xml',
    mode    => '0755',
    require => File["${jenkins_path}/jobs/Pipeline/"],
  }
  
  file { "${jenkins_path}/workspace/":
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0755',
  }
  
  file { "${jenkins_path}/workspace/Pipeline/":
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0755',
    require =>  File["${jenkins_path}/workspace/"]
  }  

# Set up artifact repository
  file { '/var/www/generic_website/artifacts':
    ensure  => directory,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0777',
  }

# fpm dependencies
  package { $enhancers: 
    ensure => 'installed',
    provider => 'yum'
  }
  
  package { 'fpm':
    ensure   => 'installed',
    provider => 'gem',
    install_options => [ '--no-ri', '--no-rdoc' ],
    require =>  Package[$enhancers]    
  }

# Make sure all the files in /var/lib/jenks are owned by jenkins:jenkins
  exec {'fix perms':
    command => "chown -R jenkins:jenkins ${jenkins_path} *",
    creates     => '/tmp/fix-perms',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    require =>  [ Archive["${jenkins_path}/xmls.tar.gz"],File["${jenkins_path}/jobs/Pipeline/config.xml"], Class['jenkins'] ],
  }     

# restart jenkins
  exec { 'jenkins restart':
    command     => 'systemctl restart jenkins',
    creates     => '/tmp/restart-jenkins',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    require =>  [ Archive["${jenkins_path}/xmls.tar.gz"],File["${jenkins_path}/jobs/Pipeline/config.xml"], Class['jenkins'] ],
  }
  
# restart docker  
  exec { 'docker restart':
    command     => 'systemctl restart docker',
    creates     => '/tmp/restart-docker',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    require =>  Exec['jenkins restart'],
  }
  
# create jenkins user admin
  exec { "create jenkins user admin":
    command => "/bin/cat /usr/lib/jenkins/puppet_helper.groovy | /usr/bin/java -jar /usr/lib/jenkins/jenkins-cli.jar -s http://127.0.0.1:8080 groovy = create_or_update_user admin sailseng@example.com 'puppetlabs' 'Managed by Puppet'",
    creates => '/tmp/jenkins-admin-usercreated-perms',
    require => Class['jenkins']
  } 
  
#  add jenkins user to docker group
  exec { "add jenkins user to docker group":
    command => '/sbin/usermod -a -G docker jenkins',
    creates => '/tmp/usermod-perms',
    require => Class['jenkins']
  } 
  
# install Maven
  class { 'maven::maven':
    version => "3.0.5", # version to install
  } 
  
  file { '/usr/local/apache-maven':
    ensure  => 'link',
    target  => '/opt/apache-maven-3.0.5',
    require => Class['maven::maven'],
  }

}
