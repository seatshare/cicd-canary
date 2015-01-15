class profile::postgres_server_consul (
  $tags = ['master'],
  $port = '5432',
) {
  class { 'postgresql::globals':
    encoding => 'UTF8',
  }
  class { '::postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/32',
    ip_mask_allow_all_users    => '0.0.0.0/0',
    listen_addresses           => '*',
    require                    => Class['postgresql::globals'],
  }
  # workaround for http://projects.puppetlabs.com/issues/4695
  # when PostgreSQL is installed with SQL_ASCII encoding instead of UTF8
  exec { 'utf8 postgres':
    command => 'pg_dropcluster --stop 9.1 main ; pg_createcluster --start --locale en_US.UTF-8 9.1 main',
    unless  => 'sudo -u postgres psql -t -c "\l" | grep template1 | grep -q UTF',
    require => Class['postgresql::server'],
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
  }
  # Ensure that the UTF-8 fix happens before any users are created
  Exec['utf8 postgres'] -> Postgresql::Server::Role<||>

  ### Consul Service Advertisment ###
  adapter::consul_service_with_check { 'postgres':
    port => $port,
    tags => $tags,
  }
  ### END Consul Service Advertisment ###
}
