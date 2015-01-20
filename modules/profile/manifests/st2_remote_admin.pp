# This class exists because `stanley` already exists in this codebase,
# so, going to just clean up here a bit for the demo purposes. In a
# greenfield, there is a class for this to be handled by the Puppet module
#
# worker could be the origin of a job in need of the keys
# endpoint is any target for stanley to need to access
class profile::st2_remote_admin(
  $client = true,
  $server = false,
) {
  class { '::st2::stanley':
    client => $client,
    server => $server,
  }
}
