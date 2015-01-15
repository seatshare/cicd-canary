# Canary is managed based on HTTP Header, or in regular RR with the other friends
class profile::seatshare_loadbalancer_consul {
  class { '::haproxy':
    custom_fragment => template('profile/seatshare_loadbalancer_consul/canary_consul.erb'),
  }

  ## SYN Reload Hack
  file { '/usr/local/sbin/safe-reload-haproxy':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/seatshare_loadbalancer_consul/safe-reload-haproxy',
  }
  ## This bit of hackery allows us to leverage the PL module to model
  ## all the parts of our config, in addition to our custom
  ## injected consul_template block and feed it to consul_template
  ## for file management.
  Concat<| title == '/etc/haproxy/haproxy.cfg' |> {
    path   => '/etc/haproxy/haproxy.tpl',
    notify => Class['::consul_template::service'],
  }

  ## Manage the actual generation of the HAProxy config to consul_haproxy
  class { '::consul_template':
    consul => '127.0.0.1:8500',
  }
  consul_template::template { '/etc/haproxy/haproxy.cfg':
    source  => '/etc/haproxy/haproxy.tpl',
    command => '/usr/local/sbin/safe-reload-haproxy',
    require => File['/usr/local/sbin/safe-reload-haproxy'],
  }

  ## Advertise via consul
  adapter::consul_service_with_check { 'loadbalancer':
    tags => ['haproxy'],
  }
}
