class profile::haproxy_loadbalancer_consul {

  ## Install and manage the HAProxy service, but we'll manage the template
  ## externally with consul-haproxy so we get service registration.
  class { '::haproxy': }

  # Cheat a little bit and move the file to a place where
  # consul-template can pick it up and run with it.
  Concat<| title == '/etc/haproxy/haproxy.cfg'|> {
    path => '/etc/haproxy/haproxy.cfg.tpl',
  }


}
