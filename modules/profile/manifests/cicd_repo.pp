class profile::cicd_repo {
  $_location = 'http://repo.apt.service.consul'

  apt::source { 'cicd':
    ensure      => present,
    location    => $_location,
    release     => $::lsbdistcodename,
    include_src => false,
    key         => 'A01FCCCF', # demo@gpg.key
    key_source  => "${_location}/pubkey.gpg",
  }
}
