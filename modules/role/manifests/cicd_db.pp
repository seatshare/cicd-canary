class role::cicd_db {
  include ::profile::cicd_repo
  include ::profile::consul_agent
  include ::profile::st2_remote_admin
  include ::profile::seatshare_db_consul
}
