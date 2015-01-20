node default {
  hiera_include('classes')
  include ::stdlib

  # Try to autoload role manifests
  if $::role {
    include "::role::${::role}"
  }
}
