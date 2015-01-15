class profile::cicd_repo(
  $location    = 'http://apt.service.consul',
  $key_content = undef,
  $key         = undef,
) {
  apt::source { 'cicd':
    ensure      => present,
    location    => $location,
    release     => $::lsbdistcodename,
    include_src => false,
    key         => $key,
    key_content => $key_content,
  }
}
