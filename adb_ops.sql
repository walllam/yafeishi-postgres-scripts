
--------- 2.1 install start ------------------
rm -rf * && ../adb_devel/configure --prefix=/postgres/adb2_1/pgsql_xc --with-blocksize=8 --with-segsize=8 --with-wal-segsize=64 --with-wal-blocksize=64 --with-perl --with-python --with-openssl --with-pam   --with-libxml --with-libxslt --enable-thread-safety  --enable-debug  --enable-cassert CFLAGS='-DADB -O0 -ggdb3 -DGTM_DEBUG' && make install-world-contrib-recurse >/dev/null   



rm -rf * && ../adb_devel/configure --prefix=/home/danghb/adb21/pgsql_xc --with-blocksize=8 --with-segsize=8 --with-wal-segsize=64 --with-wal-blocksize=64 --with-perl --with-python --with-openssl --with-pam  --with-ldap --with-libxml --with-libxslt --enable-thread-safety  --enable-debug  --enable-cassert CFLAGS='-DADB -O0 -ggdb3 -DGTM_DEBUG' && make install-world-contrib-recurse >/dev/null   
make -j4 all && make install
cd contrib && make  && make install



ssh-keygen
ssh-copy-id -i .ssh/id_rsa.pub localhost2
ssh-copy-id -i .ssh/id_rsa.pub localhost3
ssh-copy-id -i .ssh/id_rsa.pub localhost4


vi /etc/security/limits.conf
danghb soft core unlimited
danghb soft nofile 65536
danghb hard nofile 65536
danghb soft nproc 131072
danghb hard nproc 131072
danghb soft stack unlimited

--------- 2.1 install end------------------

--------- 2.2 install start ------------------
yum -y install libssh2-devel
rm -rf * && ../adb_devel/configure --prefix=/home/danghb/adb22/pgsql_xc --with-blocksize=8  --with-wal-segsize=64 --with-wal-blocksize=64 --with-perl --with-python --with-openssl --with-pam  --with-ldap --with-libxml --with-libxslt --enable-thread-safety  --enable-debug  --enable-cassert CFLAGS='-DADB -O0 -ggdb3 -DGTM_DEBUG' && make install-world-contrib-recurse >/dev/null   
make -j4 all && make install
cd contrib && make  && make install


rm -rf * && ../adb_devel/configure --prefix=/home/danghb/adb22/adbmgr --with-blocksize=8  --with-wal-segsize=64 --with-wal-blocksize=64 --with-perl --with-python --with-openssl --with-pam  --with-ldap --with-libxml --with-libxslt --enable-thread-safety  --enable-debug  --enable-cassert CFLAGS='-DADB -O0 -ggdb3 -DGTM_DEBUG' && make install-world-contrib-recurse >/dev/null   
make -j4 all && make install
cd contrib && make  && make install


 path=/home/wln/gitmaster
  #make clean
  chmod 755 $path/configure
  echo 'configure'
  $path/configure --prefix=/home/wln/install --with-perl --with-python --with-openssl --with-pam --with-ldap --with-libxml --with-libxslt --enable-thread-safety --enable-debug --enable-cassert --enable-depend CFLAGS='-DADB -O0 -DWAL_DEBUG'
  echo 'make install'
make install-world-contrib-recurse  > /dev/null


export ADB2_1_HOME=/home/danghb/adb21/pgsql_xc
export ADB2_1_DATA=/home/danghb/adb21/pgsql_data
export PGHOME=$ADB2_1_HOME
#export PGDATA=/postgre/pgsql/data
export PATH=$PGHOME/bin:$PATH:$HOME/bin:/home/danghb/databus/gradle-3.0/bin


export ADB2_2_HOME=/home/danghb/adb22/pgsql_xc
export ADB2_2_DATA=/home/danghb/adb22/pgsql_data
export PGHOME=$ADB2_2_HOME
#export PGDATA=/postgre/pgsql/data
export PATH=$PGHOME/bin:$PATH:$HOME/bin:/home/danghb/databus/gradle-3.0/bin


## adbmgr
initmgr -D /home/danghb/adb22/adbmgr
mgr_ctl start -D /home/danghb/adb22/adbmgr &
mgr_ctl stop -D /home/danghb/adb22/adbmgr 
adbmgrd -D /home/danghb/adb22/adbmgr &

add host host201(port=22,protocol='ssh',pghome='/home/danghb/adb22/pgsql_xc',address="10.20.16.201",agentport=7632,user='danghb');
add host host200(port=22,protocol='ssh',pghome='/home/danghb/adb22/pgsql_xc',address="10.20.16.200",agentport=7632,user='danghb');

deploy all
start agent all

# add
1、	添加coordinator信息：
add coordinator coord1(path = '/home/danghb/adb22/pgsql_data/cn01', host='host200', port=7642);
add coordinator coord2(path = '/home/danghb/adb22/pgsql_data/cn01', host='host201', port=7642);

2、	添加datanode master信息：
add datanode master db1(path = '/home/danghb/adb22/pgsql_data/dn01', host='host200', port=7652);
add datanode master db2(path = '/home/danghb/adb22/pgsql_data/dn01', host='host201', port=7652);

3、	添加datanode slave信息，添加slave的时候，由于slave与master同名，所以在master关键字后面写上刚才添加的master名字即可。
add datanode slave  db2(host='host200',port=7653,path = '/home/danghb/adb22/pgsql_data/dn02');
4、	添加gtm信息
add gtm master gtm(host='host200',port=7766, path='/home/danghb/adb22/pgsql_data/gtm');
add gtm slave gtm(host='host201',port=7766, path='/home/danghb/adb22/pgsql_data/gtm');


ssh danghb@host201 "echo host all all 0.0.0.0/0 trust >> /home/danghb/adb22/pgsql_data/dn01/pg_hba.conf "

# alter
alter datanode master db2(path = '/home/danghb/adb22/pgsql_data/dn02');

# drop
drop datanode master db2;

# stop
stop datanode master db2;

--------- 2.2 install end------------------

#prompt
\set PROMPT1 '%n@%m %~%R%# %> > ' 

username@dbname:port>
\set PROMPT1 '%n@%/:%> %# ' 

%m database server name
%n database session user name
%> port
%/ current database name


# connect
psql -h localhost -p 15433 -d postgres -U postgres 

\c dangdb postgres  localhost 15432
\conninfo
\c dangdb;

\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}

# objects

create user user01;
create schema user01 AUTHORIZATION user01;

create database testdb;
create database testdb with owner=user01 encoding='utf8' tablespace=tbs_test;

create table danghb.test(id int, name text) distribute by replication;
create table danghb.test(id int, name text) distribute by hash(id)  ;
create table test(id int, name text) distribute by ROUNDROBIN;
create table test(id int, name text) distribute by hash(id) to node (datanode1,datanode2);


alter table test distribute by hash(id);

insert into test values (1,'dang'),(2,'dang'),(3,'dang'),(4,'dang');
INSERT INTO numbers (num) VALUES ( generate_series(1,1000));

create tablespace tbs_test owner user01 location '/postgres/adb2_1/tbs/tbs_test';


CREATE OR REPLACE FUNCTION add(a numeric, b integer)
 RETURNS numeric
 LANGUAGE sql
AS $function$
SELECT a+b;
$function$;

create or replace function test_delete_trigger()
returns trigger as $$
begin 
	insert into  test_delete values (old.id,old.name);
	return old;
end;
$$ language plpgsql;



do language plpgsql $$  
declare  
  v_sql text;  
begin  
  for i in 1..1000 loop  
    v_sql := 'create table test_'||i||'(id int, info text)';  
    execute v_sql;  
    v_sql := 'insert into test_'||i||'(id,info) select generate_series(1,1000),''test''';  
    execute v_sql;  
  end loop;  
end;  
$$;

create trigger  delete_test_trigger
before delete on  test
for each row execute procedure  test_delete_trigger();



# pgxc_ctl

stop all 顺序：
coordinator
datanode
gtm proxy
GTM master

start all 顺序：
GTM master
gtm_proxy
coordinator
datanode

deploy all
deploy localhost3


add gtm slave gtm_s host201 7666 /home/danghb/adb21/pgsql_data/gtm
add gtm_proxy gtm_proxy2 host201 6677 /home/danghb/adb21/pgsql_data/gtm_proxy


cat > $datanode1SpecificExtraConfig <<EOF
archive_command = 'cp -i %p /home/danghb/adb21/pgsql_data/archive/dn01/%f'
EOF

archive_command = 'cp -i %p /home/danghb/adb21/pgsql_data/archive/dn01/%f'
add datanode slave datanode1 host201 /home/danghb/adb21/pgsql_data/dn01 /home/danghb/adb21/pgsql_data/archive/dn01
add datanode slave datanode2 host201 /home/danghb/adb21/pgsql_data/dn02 /home/danghb/adb21/pgsql_data/archive/dn02

add coordinator slave coord1 localhost3 /home/danghb/adb21/pgsql_data/cn01 /home/danghb/adb21/pgsql_data/archive/cn01
add coordinator slave coord2 localhost3 /home/danghb/adb21/pgsql_data/cn02 /home/danghb/adb21/pgsql_data/archive/cn02


add coordinator master coord3 localhost4 7434 20073  /home/danghb/adb21/pgsql_data/cn03
add datanode master datanode3 localhost4 17434 /home/danghb/adb21/pgsql_data/dn03 

remove gtm slave
remove datanode slave datanode1
remove datanode master datanode3
remove coordinator master coord3 
remove coordinator slave coord3 

start datanode slave datanode1

show configure all
show configure datanode


## failover 之后都需要add相应的slave

failover gtm
failover coordinator nodename |
failover datanode datanode1 


##psql select
select pgxc_pool_reload();
select pg_relation_filepath('root.tabletest');
select pg_database_size('bmsql');   
select pg_database.datname, 
pg_database_size(pg_database.datname) AS size 
from pg_database; 
select pg_size_pretty(pg_database_size('hongpay')); 
select pg_relation_size('test');  # table size
select pg_size_pretty(pg_relation_size('test'));
select pg_size_pretty(pg_total_relation_size('test')); 
select spcname from pg_tablespace;  
select pg_size_pretty(pg_tablespace_size('pg_default'));
SELECT pg_size_pretty(SUM(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::BIGINT) 
FROM pg_tables WHERE schemaname = 'weian';
SELECT schema_name, 
       pg_size_pretty(sum(table_size)),
       trunc((sum(table_size) / database_size) * 100,2)||'%'
FROM (
  SELECT pg_catalog.pg_namespace.nspname as schema_name,
         pg_relation_size(pg_catalog.pg_class.oid) as table_size,
         sum(pg_relation_size(pg_catalog.pg_class.oid)) over () as database_size
  FROM   pg_catalog.pg_class
     JOIN pg_catalog.pg_namespace ON relnamespace = pg_catalog.pg_namespace.oid
) t
GROUP BY schema_name, database_size
order by  schema_name
;

SELECT current_database();
SELECT current_user;
select current_schema;
select current_date;
select current_time;
select current_schemas(true);
SELECT pg_ls_dir('pg_log');
SELECT txid_current();
select txid_current_snapshot();
select pg_current_xlog_location();
select pg_last_xlog_replay_location();
select pg_last_xact_replay_timestamp();
select pg_xlogfile_name('1/58AA17B0');
select * from pg_xlogfile_name_offset('1/F8002B70');
select * from pg_xlogfile_name_offset(pg_current_xlog_location());

select  pg_xlogfile_name_offset(pg_current_xlog_location())
union all
select pg_xlogfile_name_offset(replay_location)
from pg_stat_replication;

./check_postgres_hot_standby_delay --dbhost=host201,host200 --dbport=17433,17433  --dbuser=danghb --dbname=bmsql --warning='1'


select pg_xlog_location_diff(pg_stat_replication.sent_location, pg_stat_replication.replay_location)
from pg_stat_replication;


SELECT CASE WHEN pg_last_xlog_receive_location() = pg_last_xlog_replay_location()
              THEN 0
            ELSE EXTRACT (EPOCH FROM now() - pg_last_xact_replay_timestamp())
       END AS log_delay;
       
select * from pg_proc; 
select * from pg_proc where proname like '%loca%';

select * from pg_stat_replication ;

select pg_get_function_arguments('bt_page_stats'::regproc);
select pg_get_function_identity_arguments('bt_page_stats'::regproc);

SELECT proargnames from pg_proc where proname ='bt_page_stats';

select datname,datfrozenxid,age(datfrozenxid) from pg_database;
select b.nspname,a.relname,a.relfrozenxid,age(a.relfrozenxid) 
from pg_class a, pg_namespace b 
where a.relnamespace=b.oid and a.relkind='r' 
order by a.relfrozenxid::text::int8 limit 10;

select extract(epoch FROM (date2 - date1)) from test_time;


# parameter 
PostgreSQL的不同配置参数在修改后有不同生效方式和类别，各种分类如下：
    Postmaster: 需要PostgreSQL服务器重启。
    Sighup：需要操作系统发出挂起信号类，这可以通过执行 kill -HUP，pg_ctl reload 或是select pg_reload_conf()来实现。
    User：可以根据不同的用户会话进行设置，仅在当前会话中生效。
    Internal: 在PostgreSQL自身编译时设置，以后不可以修改。
    Backend: 仅可以在用户会话启动前设置。
    Superuser: 可以由超级用户在运行时设置。
    
set para_name to value;
RESET max_connections;


share buffer host_mem*0.25

select distinct category from pg_settings order by 1;
select name,setting,unit,context,short_desc,category
from pg_settings 
where category like 'Query Tuning%'
order by 6,1;



set session authorization user01;

#  grant
grant all on schema user01 to user01;
grant all privileges on all tables in schema user01 to user01;  


#pg_ctl
pg_ctl reload -D /postgres/adb2_1/pgdata_xc/coord1  
pg_ctl restart -D /postgres/adb2_1/pgdata_xc/coord1  
pg_ctl restart -Z coordinator -D /postgres/adb2_1/pgdata_xc/coord1  



# statistics
analyze test;
analyze verbose test;
analyze test (id);
analyze verbose test (name);

select relpages,reltuples 
from pg_class where relname = 'test'; 

SELECT relname, relkind, reltuples, relpages 
FROM pg_class WHERE relname LIKE '%test%';

SELECT tablename,attname, inherited, n_distinct,
array_to_string(most_common_vals, E'\n') as most_common_vals 
FROM pg_stats WHERE tablename like '%test%';


SELECT histogram_bounds FROM pg_stats
WHERE tablename='test' AND attname='unique1';

SELECT null_frac, n_distinct, most_common_vals, most_common_freqs FROM pg_stats
WHERE tablename='tenk1' AND attname='stringu1';


seq scan cost = relpages * seq_page_cost + reltuples * cpu_tuple_cost


ALTER TABLE <table> ALTER COLUMN <column> SET STATISTICS <number>;


# execute plan
user01@testdb:5532 > explain select * from test where id=1;
                              QUERY PLAN                              
----------------------------------------------------------------------
 Index Scan using test_pkey on test  (cost=0.42..8.44 rows=1 width=9)
   Index Cond: (id = 1)
(2 rows)

explain select * from test where id=1;
explain analyze select * from test where id=1;
explain (analyze,buffers) select * from test where id=1;
explain (analyze,verbose,timing,buffers,costs) select * from test where id<1001;


explain (verbose,costs false)  

# pg_dump/pg_dumpall


pg_dump -Fc hongpay --verbose -f hongpay.dump
pg_dump -Fp hongpay --verbose -f hongpay.sql

pg_dumpall -s -f hongpay_metadata.sql 


#!/bin/bash

date "+%Y-%m-%d %H:%M:%S" 



# pg_restore

# view object
-- all objects
select 
	n.nspname,
	c.relname as "Name",
	CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special'	WHEN 'f' THEN 'foreign table' 
		END as "Type",
	c.relpages
from 
	pg_class c,
	pg_namespace n
where 1=1
	and c.relnamespace = n.oid
	and n.nspname like '%user%'
	and c.relname like '%%';
 
-- table
select * 
from pg_tables
where schemaname like '%user%';

-- table column
select 
  c.relname,
	a.attname,
	t.typname,
	a.attlen,
	a.attnum,
case a.attnotnull when 't' then 'NOT NULL' when 'f' then 'NULLABLE' end as "IsNotNull"
from 
	pg_class c,
	pg_attribute a,
	pg_type t,
	pg_namespace n
where 1=1
and a.atttypid=t.oid
and c.oid=a.attrelid
and c.relkind = 'r'
and c.relname like 'test%'
and a.attnum > 0
and c.relnamespace = n.oid
and n.nspname like '%user%'
order by 
	c.relname,
	a.attnum


-- index
select *
from pg_indexes 
where 1=1
and schemaname like '%user%'
and tablename like '%test%';

--- index column 
select
    t.relname as table_name,
    i.relname as index_name,
    ix.indisunique,
    array_to_string(array_agg(a.attname), ', ') as column_names    
from
    pg_class t,
    pg_class i,
    pg_index ix,
    pg_attribute a
where 1=1
    and t.oid = ix.indrelid
    and i.oid = ix.indexrelid
    and a.attrelid = t.oid
    and a.attnum = ANY(ix.indkey)
    and t.relkind = 'r'
    and t.relname like 'test%'
group by
    t.relname,
    i.relname,
    ix.indisunique
order by
    t.relname,
    i.relname;
    
    
select
    t.relname as table_name,
    i.relname as index_name,
    a.attname as column_names,
    a.attname
from
    pg_class t,
    pg_class i,
    pg_index ix,
    pg_attribute a
where 1=1
    and t.oid = ix.indrelid
    and i.oid = ix.indexrelid
    and a.attrelid = t.oid
    and a.attnum = ANY(ix.indkey)
    and t.relkind = 'r'
    and t.relname like 'test%'
group by
    t.relname,
    i.relname,
    a.attname
order by
    t.relname,
    i.relname;    


-- view
select *
from pg_views 
where 1=1
and schemaname like '%user%'
and viewname like '%test%'

-- trigger
select * 
from pg_trigger
where 1=1
and tgname like '%t%'; 

-- function
select 
	n.nspname,
	p.proname,
	pg_get_functiondef(p.oid)
from 
	pg_proc p,
	pg_namespace n
where 1=1
	and p.proowner =n.nspowner
	and p.proname like '%test%'
	and n.nspname like 'user%';


select 
	proname,p.pronamespace,p.proowner,
	pg_get_functiondef(p.oid)
from 
	pg_proc p
where 1=1
	and p.proname like '%test%';
	
-- constraints

--- using index constraint
select
	t.relname as "TableName",
	c.conname as "ConName",
	case c.contype when 'p' then 'primary key' when 'c' then 'check' when 'f' then 'foreign key' when 'u' then 'unique key' when 't' then 'constraint trigger'when 'x' then 'exclusion'
	end as "ConType",
	idx.relname as "UsingIndex"
from 
	pg_constraint c,
	pg_class t,
	pg_class idx
where 1=1
	and c.conrelid=t.oid
	and t.relkind='r'
	and c.conindid=idx.oid
	and idx.relkind='i'
	--and c.conname like '%test%'
	and t.relname like '%test%';
	
	
--- normal constraint	
select
	t.relname as "TableName",
	c.conname as "ConName",
	case c.contype when 'p' then 'primary key' when 'c' then 'check' when 'f' then 'foreign key' when 'u' then 'unique key' when 't' then 'constraint trigger'when 'x' then 'exclusion'
	end as "ConType"
from 
	pg_constraint c,
	pg_class t 
where 1=1
	and c.conrelid=t.oid
	and t.relkind='r' 
	--and c.conname like '%test%'
	and t.relname like '%test%';	
	

-- tablespace
select * from pg_tablespace;

-- datafile


## db basic information
\echo PostgreSQL 版本:
select version();
\echo 集群节点信息
select * from pgxc_node;
\echo cluster中有哪些数据库
select datname from pg_database;
\l
\echo 数据库启动时间
select pg_postmaster_start_time() as db_start_time;
\echo 数据库运行时间
select date_trunc('second',current_timestamp-pg_postmaster_start_time()) as up_time;
\echo 数据库服务的数据文件
show data_directory ;
\echo 数据库服务的日志文件
show log_directory ;
\echo 列出扩展模块
select * from pg_extension;
\echo 数据库中的schema
\dn 
\echo 每个schema中的 size Top 10 object
\echo Top 10 size table
select 
	tablename,
	pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as size
from pg_tables
where 1=1
	and schemaname not in ('pg_catalog','information_schema')
	order by size desc
	limit 10;
\echo Top 10 size index	
select 
	tablename,
	indexname,
	pg_size_pretty(pg_relation_size(schemaname||'.'||indexname)) as size
from pg_indexes
where 1=1
	and schemaname not in ('pg_catalog','information_schema')
	order by size desc
	limit 10
	;	
\echo Top 10 size object		
select 
	n.nspname,c.relname as "Name",
	CASE c.relkind WHEN 'r' THEN 'table' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' END as "type",
	pg_size_pretty(pg_relation_size(n.nspname||'.'||c.relname)) as size
from 
	pg_class c,
	pg_namespace n
where 1=1
	and c.relnamespace = n.oid
	and c.relkind in ('r','i','m')
	and n.nspowner<>10
	order by size desc
	limit 10
	;		
\echo schema中的对象类别和数量
select a.nspname,a.type,count(*)
from
(
select 
	n.nspname,
	c.relname as "Name",
	CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special'	WHEN 'f' THEN 'foreign table' END as "type"
from 
	pg_class c,
	pg_namespace n
where 1=1
	and c.relnamespace = n.oid
	and n.nspowner<>10
union
select 
	n.nspname,
	p.proname,
	'function'
from 
	pg_proc p,
	pg_namespace n
where 1=1
	and p.proowner =n.nspowner
	and n.nspowner<>10
) a
group by 
	nspname,
	a.type
order by 
	nspname,
	a.type;
	


-- Oracle兼容 jdbc配置：
jdbc:postgresql://10.78.187.108:5432/postgres?binaryTransfer=False&forceBinary=False&grammar=oracle
set grammar = postgres    or   set grammar = oracle	



# benchmarksql
# v4.1.1
conn=jdbc:postgresql://host200:7432/bmsql?binaryTransfer=False&forceBinary=False&assumeMinServerVersion=9.0
create database bmsql;
\c bmsql
create user bmsql1 superuser;
create schema bmsql1 authorization bmsql1;

./runSQL.sh props.adb2 sqlTableDrops
./runSQL.sh props.adb2 sqlTableCreates
./runSQL.sh props.adb2 sqlTableCopies_100w
./runSQL.sh props.adb2 sqlIndexCreates

./runSQL.sh props.adb sqlTableCreates
./runSQL.sh props.adb sqlTableCopies
./runSQL.sh props.adb sqlIndexCreates
./runSQL.sh props.adb sqlIndexDrops
./runSQL.sh props.adb sqlTableTruncates
./runSQL.sh props.adb sqlTableDrops

./runLoader.sh props.adb numWarehouses 100 fileLocation /tmp/adb/
./runBenchmark.sh  props.adb

2016-10-14 07:21:18,817  INFO - Term-00, 
2016-10-14 07:21:18,817  INFO - Term-00, 
2016-10-14 07:21:18,817  INFO - Term-00, Measured tpmC (NewOrders) = 110.39
2016-10-14 07:21:18,817  INFO - Term-00, Measured tpmTOTAL = 247.19
2016-10-14 07:21:18,817  INFO - Term-00, Session Start     = 2016-10-13 19:06:29
2016-10-14 07:21:18,817  INFO - Term-00, Session End       = 2016-10-14 07:21:18
2016-10-14 07:21:18,817  INFO - Term-00, Transaction Count = 181648

grep "ERROR: current transaction is aborted" 12h.log |wc -l
grep "ERROR: Abort transaction for gxid" 12h.log |wc -l


## lock
SELECT blocked_locks.pid     AS blocked_pid,
         blocked_activity.usename  AS blocked_user,
         blocking_locks.pid     AS blocking_pid,
         blocking_activity.usename AS blocking_user,
         blocked_activity.query    AS blocked_statement,
         blocking_activity.query   AS current_statement_in_blocking_process,
         blocked_activity.application_name AS blocked_application,
         blocking_activity.application_name AS blocking_application
   FROM  pg_catalog.pg_locks         blocked_locks
    JOIN pg_catalog.pg_stat_activity blocked_activity  ON blocked_activity.pid = blocked_locks.pid
    JOIN pg_catalog.pg_locks         blocking_locks 
        ON blocking_locks.locktype = blocked_locks.locktype
        AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE
        AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
        AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
        AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
        AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
        AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
        AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
        AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
        AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
        AND blocking_locks.pid != blocked_locks.pid
 
    JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
   WHERE NOT blocked_locks.GRANTED;