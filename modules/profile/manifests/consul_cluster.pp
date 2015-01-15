class profile::consul_cluster(
  $log_level        = 'INFO',
  $bootstrap_expect = '3',
) {
  ### Setup Consul Node ###
  $_config_hash = {
    'data_dir'         => '/opt/consul',
    'log_level'        => $log_level,
    'start_join'       => hiera_array('consul_cluster::join_cluster', []),
    'datacenter'       => $::datacenter,
    'ui_dir'           => '/opt/consul/ui',
    'server'           => true,
    'bootstrap_expect' => $bootstrap_expect,
  }

  class { '::consul':
    config_hash    => $_config_hash,
    service_enable => true,
    service_ensure => 'running',
  }
  ### END Setup Consul ###

  # Setup DNSMasq for automatic awesomeness
  class { '::dnsmasq': }
  dnsmasq::dnsserver { 'consul':
    ip     => '127.0.0.1#8600',
    domain => 'consul',
  }

  anchor { 'profile::consul_consul::end': }
  Class['consul'] -> Anchor['profile::consul_consul::end']
  Class['dnsmasq'] -> Anchor['profile::consul_consul::end']

  Anchor['profile::consul_consul::end'] -> Exec['apt_update']
  Anchor['profile::consul_consul::end'] -> Apt_key<||>
}

