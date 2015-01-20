class profile::postgres_client_dev {
  class { 'postgresql::lib::devel':
    link_pg_config => false,
  }
}
