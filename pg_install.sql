/postgre/pgsql/9.5.3

/postgre/postgresql-9.5.3/.configure --prefix=/postgre/pgsql/9.5.3 --with-perl --with-python 


./configure --prefix=/postgre/pgsql/9.5.3 --with-pgport=5532 --with-perl --with-python 
make  && make install
cd contrib && make  && make install

/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data
/usr/local/pgsql/bin/postgres -D /usr/local/pgsql/data >logfile 2>&1 &


Client-only installation: If you want to install only the client applications and interface libraries, 
then you can use these commands:

make -C src/bin install 
make -C src/include install 
make -C src/interfaces install
make -C doc install

src/bin has a few binaries for server-only use, but they are small.



groupadd -g 701 postgre  
useradd  -g postgre -u 701 postgre -d /postgre

userdel postgre
groupdel postgre



# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

export PS1=[\u@\h\W]\$

# User specific environment and startup programs
export PGHOME=/postgre/pgsql/9.5.3
export PGDATA=/postgre/pgsql/data
export PATH=$PGHOME/bin:$PATH:$HOME/bin
export LD_LIBRARY_PATH==$PGHOME/lib:$LD_LIBRARY_PATH



initdb -E UTF8 -D $PGDATA  --locale=C -U postgre
postgres -D $PGDATA

postgres -D /usr/local/pgsql/data >logfile 2>&1 &





 


