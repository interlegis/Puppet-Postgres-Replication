#init.pp
class postgresreplication (
  $slave                = false,
  $user                 = 'rep',
  $master_IP_address,
  $slave_IP_address,
  $port                 = 5432,
  $password,
  $trigger_file         = "/etc/postgresql/this.is.master",
)
{
  validate_bool($slave)
  #validate_integer($port)
  validate_bool(is_ip_address($master_IP_address))
  validate_bool(is_ip_address($slave_IP_address))
  ##postgresql.conf
  postgresql::server::config_entry { 'wal_level':
    value => 'hot_standby',
  }
  postgresql::server::config_entry { 'archive_mode':
    value => 'on',
  }
  postgresql::server::config_entry { 'archive_command':
    value => 'cd .',
  }
  postgresql::server::config_entry { 'max_wal_senders':
    value => '1',
  }
  postgresql::server::config_entry { 'hot_standby':
    value => 'on',
  }

  ## SLAVE CONFIGURATION
  ##if $slave == true {
  if $::ipaddress == $slave_IP_address {
    class { 'postgresql::server':
      ipv4acls       => ["host replication $user $master_IP_address/32 md5"],                    ##pg_hba.conf
      listen_addresses => "localhost,$slave_IP_address",                                         ##postgresql.conf
      manage_recovery_conf => true,
    }
    file { '/etc/postgresql/this.is.master':
      ensure => 'absent',
    }
    postgresql::server::recovery { 'postgresrecovery':
      standby_mode => 'on',
      primary_conninfo => "host=$master_IP_address port=$port user=$user password=$password",
      trigger_file => "$trigger_file",
    }
  }

  ## MASTER CONFIGURATION
  else {
    class { 'postgresql::server':
      ipv4acls        => ["host replication $user $slave_IP_address/32 md5"],                    ##pg_hba.conf
      listen_addresses  => "localhost,$master_IP_address",                                       ##postgresql.conf
      manage_recovery_conf => true,
    }
    file { '/etc/postgresql/this.is.master':
      ensure => 'present',
    }
    postgresql::server::role { "$user":
      password_hash      => postgresql_password("$user", "$password"),
        replication      => true,
        connection_limit => 1,
    }
    postgresql::server::recovery { 'postgresrecovery':
      standby_mode => 'on',
      primary_conninfo => "host=$slave_IP_address port=$port user=$user password=$password",
      trigger_file => "$trigger_file",
    }
  }
}
