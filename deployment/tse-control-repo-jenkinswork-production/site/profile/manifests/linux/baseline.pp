class profile::linux::baseline {
  package { 'unzip':
    ensure => installed,
  }

  # USERS
  if $::operatingsystem == 'CentOS' {
    user { 'puppetdemo':
      ensure     => present,
      managehome => true,
      groups     => ['wheel'],
      comment    => 'user for CentOS',
    }

  }
  elsif $::operatingsystem == 'Ubuntu' {
    user { 'puppetdemo':
      ensure     => present,
      managehome => true,
      groups     => ['sudo'],
      password   => 'user for Ubuntu',
    }
  }
}
