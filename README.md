# Puppet Module to manage Master and Slave servers using Postgresql.

Uses Puppetlabs-Postgresql module https://github.com/puppetlabs/puppetlabs-postgresql/

*This module is ready to be used with The Foreman tool http://theforeman.org/*

## Requirements

* puppetlabs-Postgresql: https://github.com/puppetlabs/puppetlabs-postgresql
* puppetlabs-stdlib:     https://github.com/puppetlabs/puppetlabs-stdlib
* puppetlabs-limits:     https://github.com/puppetlabs/puppetlabs-limits

## Overview

This module works by sending every logged modification on the Master to the Slave, replicating the database immediately. The files modified by the module are:

```
/etc/postgresql/9.3/main/pg_hba.conf
/etc/postgresql/9.3/main/postgresql.conf
/var/lib/postgresql/9.3/main/recovery.conf
```

## Setup

```
class { 'postgresreplication' :
  $user                = 'rep',
  $password,
  $master_IP_address,
  $slave_IP_address,
  $port                = 5432,
  $trigger_file        = undef,
}
```
##### `$user`
Replication user that will run on both servers. This user can only be used for replication.
##### `$password`
Replication user password.
##### `$master_IP_address`
IP address of Master.
##### `$slave_IP_address`
IP address of Slave. 
##### `$port`
Port used for the replication.
##### `$trigger_file`
If this file is present on the Slave, it will act as a Master.



## Usage

Run puppet on both Master and Slave.

Allow both servers to communicate with each other by exchanging ssh keys. 

#### On both, with postgres user, run

```
# ssh-keygen
# ssh-copy-id IP_address_of_the_opposite_server
```

Then, on Slave
```$ sudo service postgresql stop```

Finally, on Master, replicate the initial database
```
# psql -c "select pg_start_backup('initial_backup');"
# rsync -cva --inplace --exclude=*pg_xlog* /var/lib/postgresql/9.3/main/ slave_IP_address:/var/lib/postgresql/9.3/main/
# psql -c "select pg_stop_backup();"
```

Start postgresql service on Slave and everything must be up and running. 

------
Adapted from: https://www.digitalocean.com/community/tutorials/how-to-set-up-master-slave-replication-on-postgresql-on-an-ubuntu-12-04-vps
