#Puppet Module to manage Master and Slave servers using Postgresql.

Uses Puppetlabs-Postgresql module https://github.com/puppetlabs/puppetlabs-postgresql/

*This module is ready to be used with The Foreman tool http://theforeman.org/*

##Usage

Run puppet on both Master and Slave.

Allow both servers to communicate with each other by exchanging ssh keys. 

#### On both, with postgres user, run

```
# ssh-keygen
# ssh-copy-id IP_address_of_the_opposite_server
```

Then, on slave
```$ sudo service postgresql stop```

Finally, on master, replicate the initial database
```
# psql -c "select pg_start_backup('initial_backup');"
# rsync -cva --inplace --exclude=*pg_xlog* /var/lib/postgresql/9.1/main/ slave_IP_address:/var/lib/postgresql/9.1/main/
# psql -c "select pg_stop_backup();"
```

*Adapted from: https://www.digitalocean.com/community/tutorials/how-to-set-up-master-slave-replication-on-postgresql-on-an-ubuntu-12-04-vps*
