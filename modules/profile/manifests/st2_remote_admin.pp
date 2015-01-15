# This class exists because `stanley` already exists in this codebase,
# so, going to just clean up here a bit for the demo purposes. In a
# greenfield, there is a class for this to be handled by the Puppet module
#
# worker could be the origin of a job in need of the keys
# endpoint is any target for stanley to need to access
class profile::st2_remote_admin(
  $worker = false,
  $endpoint = true,
) {
  if $worker {
    file { '/home/stanley/.ssh/st2_stanley_key':
      ensure  => file,
      owner   => 'stanley',
      group   => 'stanley',
      mode    => '0400',
      content => hiera('st2::stanley::key', ''),
    }
  }
  if $endpoint {
    ssh_authorized_key { 'st2-stanley':
      user    => 'stanley',
      type    => 'ssh-rsa',
      key     => hiera('st2::stanley::pubkey', ''),
      require => File['/home/stanley/.ssh'],
    }
  }
}
