java::oracle { 'jdk8' :
  ensure  => 'present',
  version_major => '8u131',
  version_minor => 'b11',
  java_se => 'jdk',
}
