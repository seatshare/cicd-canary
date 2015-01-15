class role::cicd_frontend {
  include ::profile::st2_remote_admin
  include ::profile::consul_agent
  include ::profile::nodejs_dev
  include ::profile::postgres_client_dev
  include ::profile::cicd_repo

  class { '::profile::seatshare_frontend_consul':
    require => [
      Class['::profile::postgres_client_dev'],
      Class['::profile::nodejs_dev'],
    ],
  }
}
