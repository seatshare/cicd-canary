class profile::st2_fullinstall_consul {
  include '::st2::profile::fullinstall'
  adapter::consul_service_with_check { 'st2':
    tags => ['api', 'reactor', 'web', 'http'],
  }

  Service['dnsmasq'] -> Vcsrepo<||>
}
