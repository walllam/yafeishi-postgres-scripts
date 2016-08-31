

# pg_ctl
pg_ctl start -D $PGDATA
pg_ctl restart -D $PGDATA
pg_ctl reload



#PGDATA/pg_hba.conf  

host    all             all            192.168.0.0/16            trust