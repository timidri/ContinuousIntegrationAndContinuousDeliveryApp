class profile::platform::linux::ssh {

  include profile::compliance::linux::rhel_openssh

  case $::operatingsystemmajrelease {
    '6': { $openssh_version = '5.3p1-112.el6_7' }
    '7': { $openssh_version = '6.6.1p1-23.el7_2' }
    default: { fail('unsupported operating system') }
  }

  package { 'openssh-server':
    ensure => $openssh_version,
    before => File['/etc/ssh/sshd_config'],
  }

}
