class profile::compliance {

  case $::osfamily {
    'RedHat': { include profile::compliance::linux_rhel }
    'windows': { include profile::compliance::windows }
    default: { fail('unsupported operating system') }
  }

}
