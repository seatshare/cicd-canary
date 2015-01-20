class role::cicd_jenkins {
  ## General Management
  include ::profile::st2_remote_admin
  include ::profile::consul_cluster

  ## CI Build
  include ::profile::ruby_dev
  include ::profile::nodejs_dev

  include ::profile::jenkins_master_consul
  class { '::profile::postgres_server_consul':
    tags => ['jenkins'],
  }
  include ::profile::postgres_client_dev
  postgresql::server::role { 'jenkins':
    superuser => true,
  }
}
