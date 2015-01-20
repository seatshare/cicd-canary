class profile::ruby_dev {
  class { '::rbenv': }
  rbenv::plugin { 'sstephenson/ruby-build': }
  rbenv::build { '2.0.0-p247': global => true }

  ## Horrible hack to get past intepreter problems between versions.
  ## The in-selector does not take into account a bareword false, only
  ## string. http://git.io/mK-Lcw
  ##
  ## Don't do this. Please. Think of the kittens.
  Rbenv::Gem<| tag == 'build' |> {
    skip_docs => 'false',
  }

  case $::osfamily {
    'Debian': {
      $_extra_packages = [
        'libxml2-dev',
      ]
    }
    default: { fail('Class[profile::ruby_dev]: Unsupported Operating System') }
  }
  ensure_resource('package', $_extra_packages, {
    'ensure' => 'present',
  })
}
