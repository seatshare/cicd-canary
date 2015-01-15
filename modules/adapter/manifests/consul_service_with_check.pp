define adapter::consul_service_with_check (
  $service        = $name,
  $tags           = undef,
  $port           = undef,
  $check_name     = "check_${name}",
  $check_script   = "puppet:///modules/adapter/consul_service_with_check/check_${name}.sh",
  $check_interval = '10s',
) {

  file { "/usr/local/bin/${check_name}.sh":
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => [
      $check_script,
      'puppet:///modules/adapter/consul_service_with_check/check.default.sh',
    ],
  }

  consul::service { $service:
    tags           => $tags,
    port           => $port,
    check_script   => "/usr/local/bin/${check_name}.sh",
    check_interval => $check_interval,
  }
}
