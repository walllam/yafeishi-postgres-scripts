../adb21_20160826/configure --prefix=/postgres/adb2_1/pgsql_xc --with-segsize=1 --with-wal-segsize=64 --with-wal-blocksize=64 --with-perl --with-python --with-openssl --with-pam  --with-libxml --with-libxslt --enable-thread-safety  --enable-debug  --enable-cassert CFLAGS='-O0 -ggdb3 -DGTM_DEBUG' && make install-world-contrib-recurse >/dev/null &


../adb21_20160826/configure --prefix=/postgres/adb2_1/pgsql_xc --with-segsize=8 --with-wal-segsize=64 --with-wal-blocksize=64 --with-perl --with-python --with-openssl --with-pam --without-ldap --with-libxml --with-libxslt --enable-thread-safety --enable-depend --enable-debug --enable-cassert CFLAGS='-O0 -ggdb3 -DGTM_DEBUG'


make -j4 all && make install
cd contrib && make  && make install

#pormpt
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


##psql select
select pgxc_pool_reload();
select pg_database_size('dangdb');   
select pg_database.datname, 
pg_database_size(pg_database.datname) AS size 
from pg_database; 
select pg_size_pretty(pg_database_size('dangdb')); 
select pg_relation_size('test');  # table size
select pg_size_pretty(pg_relation_size('test'));
select pg_size_pretty(pg_total_relation_size('test')); 
select spcname from pg_tablespace;  
select pg_size_pretty(pg_tablespace_size('pg_default'));
SELECT current_database();
select current_date;
select current_time;
select current_schemas(true);
SELECT pg_ls_dir('pg_log');
SELECT txid_current();

select * from pg_proc; 

select pg_get_function_arguments('bt_page_stats'::regproc);


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


# pg_dump


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
	
	