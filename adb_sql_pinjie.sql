select 'alter table '||t.tablename||' DISTRIBUTE BY replication;'
from pg_tables t
where 1=1
and t.schemaname='weian';

select 'alter table '||c.relname||' DISTRIBUTE BY replication;'
from pg_class c,pg_namespace n,pgxc_class xc
where 1=1
and c.relowner=n.nspowner
and c.oid=xc.pcrelid
and c.relkind='r'
and n.nspname='weian'
and xc.pclocatortype<>'R';

select 'truncate table '||t.tablename||' ;'
from pg_tables t
where 1=1
and t.schemaname='weian';


select 'drop table '||t.tablename||' ;'
from pg_tables t
where 1=1
and t.schemaname='weian'
and t.tablename like 'bmsql_%';




select 'vacuum analyze '||schemaname||'.'||t.tablename||' ;' as "vacuum sql"
from pg_tables t
where 1=1
and t.schemaname='bmsql1'
and t.tablename like 'bmsql_%';


select 'insert into   '||tablename||' select * from mysql_fdw_weian.'||tablename||' ;' as "insert sql"
from pg_tables t
where 1=1
and t.schemaname='mysql_weian'
and t.tablename like 'bmsql_%';


vi droptable

username=$1

psqlconn="psql -p 5432 -d hongpay -U $username"

select_sql="select count(*) 
from pg_tables
where schemaname='$username';"

$psqlconn -c "$select_sql"

$psqlconn << EOF > tmp.sql
select 'drop table '||t.tablename||' ;'
from pg_tables t
where 1=1
and t.schemaname='$username';
EOF

$psqlconn -f tmp.sql

rm -rf tmp.sql

$psqlconn -c "$select_sql"

sh droptable weian



vi t2r

username=$1

psqlconn="psql -p 5432 -d hongpay -U $username"

select_sql="select count(*) as no_r_cnt
from pg_class c,pg_namespace n,pgxc_class xc
where 1=1
and c.relowner=n.nspowner
and c.oid=xc.pcrelid
and c.relkind='r'
and n.nspname='$username'
and xc.pclocatortype<>'R';"

$psqlconn -c "$select_sql"

$psqlconn << EOF > tmp.sql
select 'alter table '||c.relname||' DISTRIBUTE BY replication;'
from pg_class c,pg_namespace n,pgxc_class xc
where 1=1
and c.relowner=n.nspowner
and c.oid=xc.pcrelid
and c.relkind='r'
and n.nspname='$username'
and xc.pclocatortype<>'R';
EOF

$psqlconn -f tmp.sql

rm -rf tmp.sql

$psqlconn -c "$select_sql"

sh t2r weian
