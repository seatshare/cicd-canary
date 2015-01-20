class profile::apt_package_server_consul {
  ### fpm installation ###
  package { 'fpm':
    ensure => present,
    provider => gem,
  }
  ### End fpm installation ###

  ### Freight Installation ###
  include '::freight::repo'
  class { '::freight':
    ensure   => present,
    # TODO: Freight config needs to be configurable
    gpg        => 'demo@gpg.key',
    gpgpubring => 'puppet:///modules/profile/apt_package_server_consul/pubring.gpg',
    gpgsecring => 'puppet:///modules/profile/apt_package_server_consul/secring.gpg',
  }

  ## Install a package to freight to seed the repo
  wget::fetch { 'https://ops.stackstorm.net/releases/st2/0.6.0/debs/2/st2common_0.6.0-2_amd64.deb':
    destination        => '/tmp/st2common_0.6.0-2_amd64.deb',
    nocheckcertificate => true,
    notify             => Exec['freight-add-seed-package'],
  }
  exec { 'freight-add-seed-package':
    command => 'freight add /tmp/st2common_0.6.0-2_amd64.deb apt/trusty apt/precise',
    path    => [
      '/usr/sbin',
      '/usr/bin',
      '/sbin',
      '/bin',
    ],
    notify      => Exec['freight-update-cache'],
    require     => Class['freight'],
    refreshonly => true,
  }

  exec { 'freight-update-cache':
    command => 'freight cache',
    path    => [
      '/usr/sbin',
      '/usr/bin',
      '/sbin',
      '/bin',
    ],
    refreshonly => true,
    require     => Class['freight'],
  }

  include '::nginx'
  nginx::resource::vhost { "apt.${::domain}":
    ensure      => present,
    www_root    => '/var/cache/freight',
    autoindex   => 'on',
    server_name => [
      $::fqdn,
      "${::hostname}.local",
      "apt.${::domain}",
      "apt.service.consul",
      "repo.apt.service.consul",
    ],
  }

  adapter::consul_service_with_check { 'apt':
    port => '80',
    tags => ['build', 'repo'],
  }
  ### END Freight Installation ###
}
