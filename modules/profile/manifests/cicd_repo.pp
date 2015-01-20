class profile::cicd_repo(
  $location    = 'http://apt.service.consul',
  $key         = 'A01FCCCF',
) {
  apt::source { 'cicd':
    ensure      => present,
    location    => $location,
    release     => $::lsbdistcodename,
    include_src => false,
    key         => $key,
    key_server  => 'pgp.mit.edu',
  }
}
