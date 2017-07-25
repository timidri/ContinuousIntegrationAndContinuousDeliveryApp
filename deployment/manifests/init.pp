java::oracle { 'jdk8' :
  ensure        => 'present',
  url_hash      => 'd54c1d3a095b4ff2b6607d096fa80163',
  version_major => '8u131',
  version_minor => 'b11',
  java_se       => 'jdk',
}

