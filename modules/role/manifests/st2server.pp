class role::st2server {
  include ::profile::consul_cluster
  include ::profile::st2_fullinstall_consul
}
