class profile::nodejs_dev {
  class { '::nodejs':
    proxy        => false,
    manage_repo  => true,
  }

  $_dev_modules = [
    'bower',
  ]

  package { $_dev_modules:
    ensure   => present,
    provider => 'npm',
    require  => Class['::nodejs'],
  }
}
