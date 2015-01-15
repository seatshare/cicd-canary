node default {
  hiera_include('classes')

  # Try to autoload role manifests
  if $::role {
    include "::role::${::role}"
  }

  stage { 'pre-install':
    before => Stage['main'],
  }
}
