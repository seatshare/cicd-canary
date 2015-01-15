class role::cicd_infrastructure {
  ## General Management
  include ::profile::st2_remote_admin
  include ::profile::consul_cluster

  ## Apt Repository
  include ::profile::apt_package_server_consul

  # PostgreSQL
  include ::profile::seatshare_db_consul

  # Loadbalancer
  include ::profile::seatshare_loadbalancer_consul
}
