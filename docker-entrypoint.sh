#!/bin/bash
set -e
PG_PORTS=(5432 5423)

if [ "$POSTGRES_DB" ]; then
    DB=$POSTGRES_DB
else
    DB="foehn"
fi

if [ "$POSTGRES_USER" ]; then
    USER=$POSTGRES_USER
else
    USER="foehn"
fi

#Start the servers

#/usr/lib/postgresql/9.4/bin/postgres -D /opt/databases/nodea/ &

/usr/lib/postgresql/9.4/bin/pg_ctl -D /opt/databases/nodea/ -w start
/usr/lib/postgresql/9.4/bin/pg_ctl -D /opt/databases/nodeb/ -w start
#/usr/lib/postgresql/9.4/bin/postgres -D /opt/databases/nodeb/ &
# /lib/postgresql/9.4/bin/pg_ctl -D /opt/databases/nodea/ -w start
# /usr/lib/postgresql/9.4/bin/pg_ctl -D /opt/databases/nodeb/ -w start


for port in "${PG_PORTS[@]}"
do
    psql --username postgres -p $port <<-EOSQL
        create database $DB;
EOSQL

    psql --username postgres -p $port <<-EOSQL
        CREATE USER "$USER" WITH SUPERUSER;
EOSQL

done


#Create group
psql --username postgres -p 5432 $DB <<-EOSQL
    CREATE EXTENSION btree_gist;
    CREATE EXTENSION bdr;
    SELECT bdr.bdr_group_create(
        local_node_name := 'nodea',
        node_external_dsn := 'host=127.0.0.1 port=5432 dbname=$DB'
    );
EOSQL

# Join the group
psql --username postgres -p 5423 $DB <<-EOSQL
    CREATE EXTENSION btree_gist;
    CREATE EXTENSION bdr;
    SELECT bdr.bdr_group_join(
        local_node_name := 'nodeb',
        node_external_dsn := 'host=127.0.0.1 port=5423 dbname=$DB',
        join_using_dsn := 'host=127.0.0.1 port=5432 dbname=$DB'
      );
EOSQL


/usr/lib/postgresql/9.4/bin/pg_ctl -D /opt/databases/nodea/ -w stop
/usr/lib/postgresql/9.4/bin/postgres -D /opt/databases/nodea/

