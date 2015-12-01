# == Class: manila::db
#
#  Configure the Manila database
#
# === Parameters
#
# [*database_connection*]
#   Url used to connect to database.
#   (Optional) Defaults to 'sqlite:////var/lib/manila/manila.sqlite'.
#
# [*database_idle_timeout*]
#   Timeout when db connections should be reaped.
#   (Optional) Defaults to $::os_service_default
#
# [*database_min_pool_size*]
#   Minimum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to $::os_service_default
#
# [*database_max_pool_size*]
#   Maximum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to $::os_service_default
#
# [*database_max_retries*]
#   Maximum db connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   (Optional) Defaults to $::os_service_default
#
# [*database_retry_interval*]
#   Interval between retries of opening a sql connection.
#   (Optional) Defaults to $::os_service_default
#
# [*database_max_overflow*]
#   If set, use this value for max_overflow with sqlalchemy.
#   (Optional) Defaults to $::os_service_default
#
class manila::db (
  $database_connection     = 'sqlite:////var/lib/manila/manila.sqlite',
  $database_idle_timeout   = $::os_service_default,
  $database_min_pool_size  = $::os_service_default,
  $database_max_pool_size  = $::os_service_default,
  $database_max_retries    = $::os_service_default,
  $database_retry_interval = $::os_service_default,
  $database_max_overflow   = $::os_service_default,
) {

  # NOTE(spredzy): In order to keep backward compatibility we rely on the pick function
  # to use manila::<myparam> if manila::db::<myparam> isn't specified.
  $database_connection_real = pick($::manila::sql_connection, $database_connection)
  $database_idle_timeout_real = pick($::manila::sql_idle_timeout, $database_idle_timeout)
  $database_min_pool_size_real = pick($::manila::database_min_pool_size, $database_min_pool_size)
  $database_max_pool_size_real = pick($::manila::database_max_pool_size, $database_max_pool_size)
  $database_max_retries_real = pick($::manila::database_max_retries, $database_max_retries)
  $database_retry_interval_real = pick($::manila::database_retry_interval, $database_retry_interval)
  $database_max_overflow_real = pick($::manila::database_max_overflow, $database_max_overflow)

  validate_re($database_connection_real,
    '(sqlite|mysql|postgresql):\/\/(\S+:\S+@\S+\/\S+)?')

  case $database_connection_real {
    /^mysql:\/\//: {
      $backend_package = false
      require 'mysql::bindings'
      require 'mysql::bindings::python'
    }
    /^postgresql:\/\//: {
      $backend_package = false
      require 'postgresql::lib::python'
    }
    /^sqlite:\/\//: {
      $backend_package = $::manila::params::sqlite_package_name
    }
    default: {
      fail('Unsupported backend configured')
    }
  }

  if $backend_package and !defined(Package[$backend_package]) {
    package {'manila-backend-package':
      ensure => present,
      name   => $backend_package,
      tag    => 'openstack',
    }
  }

  manila_config {
    'database/connection':     value => $database_connection_real, secret => true;
    'database/idle_timeout':   value => $database_idle_timeout_real;
    'database/min_pool_size':  value => $database_min_pool_size_real;
    'database/max_retries':    value => $database_max_retries_real;
    'database/retry_interval': value => $database_retry_interval_real;
    'database/max_pool_size':  value => $database_max_pool_size_real;
    'database/max_overflow':   value => $database_max_overflow_real;
  }

}
