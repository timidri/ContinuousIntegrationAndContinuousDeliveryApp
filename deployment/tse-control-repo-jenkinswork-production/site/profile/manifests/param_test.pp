# param_test
class profile::param_test (
  Optional[String] $splunk_server = undef,
){
  if $splunk_server == undef {
    $splunk_nodes_query = 'resources[certname] { type = "Class" and title = "Apache" }'
    $_splunk_server = puppetdb_query($splunk_nodes_query)[0][certname]
  } else {
    $_splunk_server = $splunk_server
  }

  notify { "This is my test value: $_splunk_server": }
}