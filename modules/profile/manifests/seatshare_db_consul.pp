class profile::seatshare_db_consul {
  include '::profile::postgres_server_consul'

  postgresql::server::role { 'seatshare':
    password_hash => postgresql_password('seatshare', 'seatshare'),
    superuser => true,
  }
}
