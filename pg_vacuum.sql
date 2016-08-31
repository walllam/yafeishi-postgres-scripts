把下面这些加到配置文件，然后重启数据库
# -- Query/Index Statistics Collector --
track_counts = on
track_activity_query_size = 2048

# -- Autovacuum --
autovacuum = on
autovacuum_max_workers = 5
autovacuum_naptime = 1d
autovacuum_vacuum_threshold = 500
autovacuum_analyze_threshold = 500
autovacuum_vacuum_scale_factor = 0.5
autovacuum_vacuum_cost_limit = -1
autovacuum_vacuum_cost_delay = 30ms

log_autovacuum_min_duration=0




show autovacuum_naptime;
drop table  if exists test_vac cascade;
create table test_vac (id int);
create index idx_vac_id on test_vac (id);
truncate table test_vac;
vacuum analyze test_vac;
insert into test_vac select generate_series(1,10000);
select pg_size_pretty(pg_relation_size('test_vac'));
select count(*) from test_vac;
update test_vac set id = 1000 where id > 999;
delete from test_vac where id=1000;
insert into test_vac select generate_series(1000,100000);
select count(*) from test_vac;
select pg_size_pretty(pg_relation_size('test_vac'));
select now();
\echo -----------------------before execute autovacuum 
select 
to_number(current_setting('autovacuum_analyze_threshold'),'9999')+to_number(current_setting('autovacuum_analyze_scale_factor'),'99.99')*reltuples as auto_analyze_threshold,
to_number(current_setting('autovacuum_vacuum_threshold'),'9999')+to_number(current_setting('autovacuum_vacuum_scale_factor'),'99.99')*reltuples as auto_vacuum_threshold,
relname,reltuples,c.relpages,
pg_stat_get_live_tuples(oid),
pg_stat_get_dead_tuples(oid),
pg_stat_get_last_autoanalyze_time(oid),
pg_stat_get_last_autovacuum_time(oid)
from pg_class c
where relname like '%vac%';
select pg_sleep(90);
select now();
\echo -----------------------alter execute autovacuum 
select 
to_number(current_setting('autovacuum_analyze_threshold'),'9999')+to_number(current_setting('autovacuum_analyze_scale_factor'),'99.99')*reltuples as auto_analyze_threshold,
to_number(current_setting('autovacuum_vacuum_threshold'),'9999')+to_number(current_setting('autovacuum_vacuum_scale_factor'),'99.99')*reltuples as auto_vacuum_threshold,
relname,reltuples,c.relpages,
pg_stat_get_live_tuples(oid),
pg_stat_get_dead_tuples(oid),
pg_stat_get_last_autoanalyze_time(oid),
pg_stat_get_last_autovacuum_time(oid)
from pg_class c
where relname like '%vac%';


select 
to_number(current_setting('autovacuum_analyze_threshold'),'9999')+to_number(current_setting('autovacuum_analyze_scale_factor'),'99.99')*reltuples as auto_analyze_threshold,
to_number(current_setting('autovacuum_vacuum_threshold'),'9999')+to_number(current_setting('autovacuum_vacuum_scale_factor'),'99.99')*reltuples as auto_vacuum_threshold,
relname,reltuples
from pg_class c
where relname like '%vac%';




select relname,last_autovacuum,autovacuum_count,
last_autoanalyze,autoanalyze_count
from pg_stat_all_tables where relname='test_vac';


select relname,last_vacuum,vacuum_count,
last_analyze,analyze_count
from pg_stat_all_tables where relname='test_vac';



select 
to_number(current_setting('autovacuum_analyze_threshold'),'9999')+to_number(current_setting('autovacuum_analyze_scale_factor'),'99.99')*reltuples as auto_analyze_threshold,
to_number(current_setting('autovacuum_vacuum_threshold'),'9999')+to_number(current_setting('autovacuum_vacuum_scale_factor'),'99.99')*reltuples as auto_vacuum_threshold,
relname,reltuples,c.relpages,
pg_stat_get_live_tuples(oid),
pg_stat_get_dead_tuples(oid),
pg_stat_get_last_autoanalyze_time(oid),
pg_stat_get_last_autovacuum_time(oid),
(pgstattuple(oid)).* 
from pg_class c
where relname='t_fenye';



SELECT
  current_database(), schemaname, tablename, /*reltuples::bigint, relpages::bigint, otta,*/
  ROUND((CASE WHEN otta=0 THEN 0.0 ELSE sml.relpages::FLOAT/otta END)::NUMERIC,1) AS tbloat,
  CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::BIGINT END AS wastedbytes,
  iname, /*ituples::bigint, ipages::bigint, iotta,*/
  ROUND((CASE WHEN iotta=0 OR ipages=0 THEN 0.0 ELSE ipages::FLOAT/iotta END)::NUMERIC,1) AS ibloat,
  CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta) END AS wastedibytes
FROM (
  SELECT
    schemaname, tablename, cc.reltuples, cc.relpages, bs,
    CEIL((cc.reltuples*((datahdr+ma-
      (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::FLOAT)) AS otta,
    COALESCE(c2.relname,'?') AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,
    COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::FLOAT)),0) AS iotta -- very rough approximation, assumes all cols
  FROM (
    SELECT
      ma,bs,schemaname,tablename,
      (datawidth+(hdr+ma-(CASE WHEN hdr%ma=0 THEN ma ELSE hdr%ma END)))::NUMERIC AS datahdr,
      (maxfracsum*(nullhdr+ma-(CASE WHEN nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
    FROM (
      SELECT
        schemaname, tablename, hdr, ma, bs,
        SUM((1-null_frac)*avg_width) AS datawidth,
        MAX(null_frac) AS maxfracsum,
        hdr+(
          SELECT 1+COUNT(*)/8
          FROM pg_stats s2
          WHERE null_frac<>0 AND s2.schemaname = s.schemaname AND s2.tablename = s.tablename
        ) AS nullhdr
      FROM pg_stats s, (
        SELECT
          (SELECT current_setting('block_size')::NUMERIC) AS bs,
          CASE WHEN SUBSTRING(v,12,3) IN ('8.0','8.1','8.2') THEN 27 ELSE 23 END AS hdr,
          CASE WHEN v ~ 'mingw32' THEN 8 ELSE 4 END AS ma
        FROM (SELECT version() AS v) AS foo
      ) AS constants
      GROUP BY 1,2,3,4,5
    ) AS foo
  ) AS rs
  JOIN pg_class cc ON cc.relname = rs.tablename
  JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname = rs.schemaname AND nn.nspname <> 'information_schema'
  LEFT JOIN pg_index i ON indrelid = cc.oid
  LEFT JOIN pg_class c2 ON c2.oid = i.indexrelid
) AS sml
ORDER BY wastedbytes DESC;







