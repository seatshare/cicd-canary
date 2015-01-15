class profile::consul_cluster(
  $log_level        = 'INFO',
  $bootstrap_expect = '1',
) {
  ### Setup Consul Node ###
  $_config_hash = {
    'data_dir'         => '/opt/consul',
    'log_level'        => $log_level,
    'start_join'       => hiera_array('consul_cluster::join_cluster', []),
    'datacenter'       => $::datacenter,
    'bootstrap_expect' => $bootstrap_expect,
    'ui_dir'           => '/opt/consul/ui',
    'server'           => true,
  }

  class { '::consul':
    config_hash  => $_config_hash,
    join_cluster => $join_cluster,
  }
  ### END Setup Consul ###

  # Setup DNSMasq for automatic awesomeness
  include '::dnsmasq'
  dnsmasq::dnsserver { 'consul':
    ip     => '127.0.0.1#8600',
    domain => 'consul',
  }
}
