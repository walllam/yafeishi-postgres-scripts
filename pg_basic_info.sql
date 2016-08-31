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
	