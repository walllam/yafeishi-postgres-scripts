select 'alter table '||t.tablename||' DISTRIBUTE BY replication;'
from pg_tables t
where 1=1
and t.schemaname='public';

select 'drop table '||t.tablename||' ;'
from pg_tables t
where 1=1
and t.schemaname='public'
and t.tablename like 'bmsql_%';




select 'vacuum analyze '||schemaname||'.'||t.tablename||' ;'
from pg_tables t
where 1=1
and t.schemaname='channel'
and t.tablename like 'bmsql_%';
