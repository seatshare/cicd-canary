class profile::consul_agent(
  $log_level  = 'INFO',
) {
  ### Setup Consul Node ###
  $_config_hash = {
    'data_dir'         => '/opt/consul',
    'log_level'        => $log_level,
    'start_join'       => hiera_array('consul_agent::join_cluster', []),
    'datacenter'       => $::datacenter,
  }

  class { '::consul':
    config_hash    => $_config_hash,
    service_enable => true,
    service_ensure => 'running',
  }

  # Setup DNSMasq for automatic awesomeness
  class { '::dnsmasq':
    require => Class['::consul'],
  }
  dnsmasq::dnsserver { 'consul':
    ip     => '127.0.0.1#8600',
    domain => 'consul',
  }

  ### END Setup Consul ###
  anchor { 'profile::consul_consul::end': }
  Class['consul'] -> Anchor['profile::consul_consul::end']
  Class['dnsmasq'] -> Anchor['profile::consul_consul::end']
}
