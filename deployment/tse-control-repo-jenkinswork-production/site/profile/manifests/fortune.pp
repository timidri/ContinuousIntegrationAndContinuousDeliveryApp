class profile::fortune {
  package { 'fortune':
    ensure   => present,
  }
}