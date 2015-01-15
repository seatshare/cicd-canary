class profile::st2_full_install_consul {
  class { '::st2':
    version => hiera('st2::version', '0.6.0'),
  }

  class { '::st2::profile::mongodb': }
  -> class { '::st2::profile::rabbitmq': }
  -> class { '::st2::profile::nodejs': }
  -> class { '::st2::role::client': }
  -> class { '::st2::role::mistral':
    manage_mysql => true,
  }
  -> class { '::st2::role::server': }
  class { '::st2::role::web': }

  adapter::consul_service_with_check { 'st2':
    tags => ['api', 'reactor', 'web', 'http'],
  }
}
