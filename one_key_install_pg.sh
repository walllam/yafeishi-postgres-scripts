#!/bin/sh

# pg_install.sh
# usage: sh pg_install.sh PG_SRC PGHOME PGDATA PGPORT
# sh pg_install.sh /postgres/soft_src/postgresql-9.5.3 /postgres/pgsql/9.5.3 /postgres/pgsql/pgdata 5532

PG_SRC=$1
PGHOME=$2
PGDATA=$3
PGPORT=$4

rm -rf $PGHOME
rm -rf $PGDATA

cd $PG_SRC
./configure --prefix=$PGHOME --with-pgport=$PGPORT --with-perl --with-python 
make  && make install
cd contrib && make  && make install

$PGHOME/bin/initdb -D $PGDATA
$PGHOME/bin/postgres -D $PGDATA >logfile 2>&1 &
$PGHOME/bin/psql -p $PGPORT -l



sh pg_install.sh /postgres/soft_src/postgresql-9.5.3 /postgres/pgsql/9.5.3 /postgres/pgsql/pgdata 5532


/postgres/pgsql/9.5.3/bin/psql -p 5532 -l
/postgres/pgsql/9.5.3/bin/initdb --help


cat > .953 << EOF
export PGHOME=/postgres/pgsql/9.5.3/
export PGDATA=/postgres/pgsql/pgdata/
export PGPORT=5532
export PATH=$PGHOME/bin:$PATH:
EOF

#######################################################

sampledb.sh


export PGHOME=/postgres/pgsql/9.5.3/
export PGDATA=/postgres/pgsql/pgdata/
export PGPORT=5532

rm -rf /postgres/pgsql/tbs/tbs_test
mkdir -p /postgres/pgsql/tbs/tbs_test

cat > sampledb.sql << EOF
\echo ---------------------------drop  objects----------------------
drop user  if exists user01;
drop database  if exists testdb;
drop tablespace  if exists tbs_test;

\echo ---------------------------create  objects----------------------
create user user01;
create tablespace tbs_test owner user01 location '/postgres/pgsql/tbs/tbs_test';
create database testdb with owner=user01 encoding='utf8' tablespace=tbs_test;
\c testdb
grant all privileges on database testdb to user01;
drop schema  if exists user01 CASCADE;
create schema user01 AUTHORIZATION user01;
\c testdb user01
create table test(id int primary key, name text);

insert into test (id,name) select generate_series(1,1000000),'dang';
select * from test;

create or replace function select_test_cnt(a integer)
return NUMERIC 
AS $$
select count(*) from test where id > a;
$$ 
LANGUAGE SQL;


CREATE OR REPLACE FUNCTION add(a INTEGER, b NUMERIC)
RETURNS NUMERIC
AS $$
	SELECT a+b;
$$ LANGUAGE SQL;



EOF

$PGHOME/bin/psql -f sampledb.sql

$PGHOME/bin/postgres >logfile 2>&1 &
