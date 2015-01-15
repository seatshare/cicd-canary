class role::cicd_loadbalancer {
  include ::profile::cicd_repo
  include ::profile::st2_remote_admin
  include ::profile::consul_agent
  include ::profile::seatshare_loadbalancer_consul
}
