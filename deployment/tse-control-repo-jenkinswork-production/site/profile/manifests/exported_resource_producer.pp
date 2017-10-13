class profile::exported_resource_producer {

  @@host { $facts['fqdn'] :
    comment      => 'Abir put this here',
    ip           => $facts['ipaddress'],
    tag          => 'abirshostname',
  }

}