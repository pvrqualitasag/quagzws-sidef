Installation of TheSNPpit on Singularity
================

## Strategy

From the documenatation given in the user guide, it is clear that
TheSNPpit as it comes out of the box is a program that is targetted
towards running on a single machine. This means that there is one
instance of the database-server and one installation of the client
programs that accesses the data in the database. Different users on the
same machine can use the client programs which can all interact with the
given instance of the database on the same machine.

It gets more complicated if we want to be able work with the same data
from different machines. This requires to get access to the database
from different clients running on different machines. This requires a
distributed setup over different machines.

## Installation Resources

### User Guide

We are currently checking the user guide on
<https://tsp-repo.thesnppit.net/resources/TheSNPpit-user-guide-latest.pdf>
for hints on how to install. Chapter 6 of the user guide describes the
installation. The proposed way to install TheSNPpit is to download the
tar-ball from the website, to unpack the tarball and to run the script
`bin/install`. Since this requires root priviledges, this cannot be used
in a singularity container.

### Manual Installation

In section 6.3 of the user guide, a manual installation is described. In
Listing 57, the software required by TheSNPpit is described. The
installation procedure given there is based on system-wide
installations.

## Experiments

This section describes the trials and experiments with a local
installation.

### Local pgsql

In a first attempt, we try to compile our own pgsql database.

``` bash
mkdir -p /home/zws/postgresql/9.5/main
cd source/postgres
wget https://ftp.postgresql.org/pub/source/v9.5.19/postgresql-9.5.19.tar.gz
tar -xvzf postgresql-9.5.19.tar.gz 
cd postgresql-9.5.19/
./configure --prefix=/home/zws/postgresql/9.5/main
make
make install
```

According to
<https://stackoverflow.com/questions/40644400/create-postgresql-database-without-root-privilege>,
we try to start a local db-cluster using the following
commands.

``` bash
./postgresql/9.5/main/bin/initdb -D /home/zws/postgresql/9.5/main/data -A trust -U zws
```

The above resulted in the following
    output

    The files belonging to this database system will be owned by user "zws".
    This user must also own the server process.
    
    The database cluster will be initialized with locale "en_US.UTF-8".
    The default database encoding has accordingly been set to "UTF8".
    The default text search configuration will be set to "english".
    
    Data page checksums are disabled.
    
    fixing permissions on existing directory /home/zws/postgresql/9.5/main/data ... ok
    creating subdirectories ... ok
    selecting default max_connections ... 100
    selecting default shared_buffers ... 128MB
    selecting default timezone ... Europe/Berlin
    selecting dynamic shared memory implementation ... posix
    creating configuration files ... ok
    creating template1 database in /home/zws/postgresql/9.5/main/data/base/1 ... ok
    initializing pg_authid ... ok
    initializing dependencies ... ok
    creating system views ... ok
    loading system objects' descriptions ... ok
    creating collations ... ok
    creating conversions ... ok
    creating dictionaries ... ok
    setting privileges on built-in objects ... ok
    creating information schema ... ok
    loading PL/pgSQL server-side language ... ok
    vacuuming database template1 ... ok
    copying template1 to template0 ... ok
    copying template1 to postgres ... ok
    syncing data to disk ... ok
    
    Success. You can now start the database server using:
    
        ./postgresql/9.5/main/bin/pg_ctl -D /home/zws/postgresql/9.5/main/data -l logfile start

The question about where the configuration is stored is answered by
<https://serverfault.com/questions/152942/location-of-postgresql-conf-and-pg-hba-conf-on-an-ubuntu-server>

The above start command requires an empty `data` directory. The
configuration files will all be placed into the data directory. In
`postgresql.conf` the port was changed to 5434 to not get in conflict
with any other running postgresql instances.

Connecting with the client to the running database required the
following steps according to
<https://stackoverflow.com/questions/16973018/createuser-could-not-connect-to-database-postgres-fatal-role-tom-does-not-e/16974197#16974197>

where the `createuser` statement threw an error at me, but the database
creation worked. Afterwards I was able to connect with the client to the
database.

``` bash
./postgresql/9.5/main/bin/createuser -h localhost -p 5434 zws
./postgresql/9.5/main/bin/createdb -h localhost -p 5434 -O zws zws
./postgresql/9.5/main/bin/psql -h localhost -p 5434
```
