class profile::important_terminal_additions {

  package { 'rubygems':
    ensure   => present,
  }  

  package { 'cowsay':
    ensure   => present,
  }
  
  package { 'fortune-mod':
    ensure   => present,
  }  

  package { 'lolcat':
    ensure   => present,
    provider => 'gem',
    require => Package['rubygems'],    
  }    
  
  file { "/etc/profile.d/motd_fun.sh":
    ensure => present,
    content => 'fortune fortunes -s | cowsay | lolcat',
  }  
  
}