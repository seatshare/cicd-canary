class profile::seatshare_frontend_consul(
  $version = hiera('seatshare::version', 'present'),
  $canary_version = hiera('seatshare::canary_version', 'present'),
) {

  $_canary = hiera('seatshare::canary', false)

  if $_canary {
    $_tags = ['fe', 'canary_fe']
    $_package_version = $canary_version
  }
  else {
    $_tags = ['fe']
    $_package_version = $version
  }

  package { 'seatshare':
    ensure => $_package_version,
  }

  user { 'seatshare':
    ensure     => present,
    shell      => '/bin/bash',
    gid        => 'seatshare',
    managehome => true,
  }
  group { 'seatshare':
    ensure => present,
  }

  ### App Configuration ###
  unicorn::app { 'seatshare':
    approot         => '/opt/seatshare',
    export_home     => '/home/seatshare',
    pidfile         => '/opt/seatshare/tmp/seatshare-unicorn.pid',
    socket          => '/opt/seatshare/tmp/seatshare-unicorn.sock',
    user            => 'seatshare',
    group           => 'seatshare',
    preload_app     => true,
    source          => 'bundler',
    rack_env        => 'development',
    require         => [
      Class['ruby::dev'],
      File['/usr/local/bin/bundle'],
    ],
  }

  file { '/opt/seatshare/config/database.yml':
    ensure  => file,
    owner   => 'seatshare',
    group   => 'seatshare',
    mode    => '0440',
    source  => 'puppet:///modules/seatshare/database.yml',
    require => Package['seatshare'],
    before  => Unicorn::App['seatshare'],
  }

  file { '/opt/seatshare/.env':
    ensure => file,
    owner   => 'seatshare',
    group   => 'seatshare',
    mode    => '0440',
    source  => 'puppet:///modules/seatshare/_env',
    require => Package['seatshare'],
    before  => Unicorn::App['seatshare'],
  }

  ## This is why we cannot have nice things.
  ## Hardcoded assumptions make kittens sad
  ## This is hidden deep in the ploperations/unicorn
  ## module, and could use some tweaking.
  ## TODO: Fix this bundle link
  file { '/usr/local/bin/bundle':
    ensure => symlink,
    target => '/usr/bin/bundle',
  }

  # Rub some webserver on it
  include '::nginx'
  nginx::resource::vhost { 'seatshare':
    ensure => present,
    proxy  => 'http://seatshare-unicorn',
  }
  nginx::resource::upstream { 'seatshare-unicorn':
    members => [ 'unix:/opt/seatshare/tmp/seatshare-unicorn.sock' ],
  }

  ## Consul Service Advertisment ##
  # Canary Setup
  adapter::consul_service_with_check { 'seatshare':
    tags => $_tags,
    port => '80',
  }
  ## END Conlus Service Advertisment ##
}
