# ADB install 



创建 postgres 用户和组(root)：
groupadd postgres
useradd -g postgres -d /postgres -s /bin/bash -m postgres

chown -R postgres:postgres /postgres

passwd postgres



编辑hosts文件(root)
vi /etc/hosts

192.168.56.101 gtm
192.168.56.101 cd01
192.168.56.101 cd02
192.168.56.101 cd03

安装下面的依赖包:(root)
yum install -y perl-ExtUtils-Embed
yum install -y flex
yum install -y bison
yum install -y readline-devel
yum install -y zlib-devel
yum install -y openssl-devel
yum install -y pam-devel
yum install -y libxml2-devel
yum install -y libxslt-devel
yum install -y openldap-devel
yum install -y python-devel
yum install -y gcc-c++


编辑/etc/ssh/sshd_config文件，使下面三个参数生效：(root)

RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile      .ssh/authorized_keys

重启sshd服务：(root)
service sshd restart 


切换到 postgres 用户：
su - postgres

配置localhost 免密ssh：
1. ssh-keygen -t rsa
Press enter for each line 
2. cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
3. chmod og-wx ~/.ssh/authorized_keys 

编辑 .bashrc文件：
export ADB2_1_HOME=/postgres/adb2_1/pgsql_xc
export ADB2_1_DATA=/postgres/adb2_1/pgdata_xc
export PGHOME=$ADB2_1_HOME
#export PGDATA=/postgre/pgsql/data
export PATH=$PGHOME/bin:$PATH:$HOME/bin

vi adb2_1_install.sh:

sh ~/adb2_1_install.sh /postgres/soft_src/adb21/adb_devel
sh ~/adb2_1_install.sh /postgres/soft_src/adb/adb_devel/ADB2_1_STABLE

sh ~/adb2_1_install.sh /postgres/soft_src/adb21/adb21_20160811

#清理安装目录，保持干净：（由于在变量值不存在的情况下，shell命令会回到 ~ 下执行，为防止误删除，此步骤采取绝对路径，不使用变量）
rm -rf  /postgres/adb2_1

#创建主程序目录：
source ~/.bashrc
mkdir -p $ADB2_1_HOME

#创建数据主目录：
mkdir -p $ADB2_1_DATA

#export ADB2_1_SRC=/postgres/soft_src/adb/adb_devel/ADB2_1_STABLE
export ADB2_1_SRC=$1
cd $ADB2_1_SRC
./configure --prefix=$ADB2_1_HOME --with-segsize=8 --with-wal-segsize=64 --with-wal-blocksize=64 --with-perl --with-python --with-openssl --with-pam --without-ldap --with-libxml --with-libxslt --enable-thread-safety --enable-depend --enable-debug --enable-cassert CFLAGS='-O0 -ggdb3'
make -j4 all && make install
cd contrib && make  && make install



../adb_devel/configure --prefix=/home/xul/pgsql_xc --with-segsize=1 --with-wal-segsize=64 --with-wal-blocksize=64 --with-perl --with-python --with-openssl --with-pam --with-ldap --with-libxml --with-libxslt --enable-thread-safety  --enable-debug  --enable-cassert CFLAGS='-O0 -ggdb3 -DGTM_DEBUG' && make install-world-contrib-recurse >/dev/null &



cd ~
source ~/.bashrc
rm -rf pgxc_ctl
pgxc_ctl prepare
cd ~/pgxc_ctl
cp pgxc_ctl.conf pgxc_ctl.conf.bak

echo > pgxc_ctl.conf
cat >> pgxc_ctl.conf << "EOF"
# user and path 
pgxcOwner=postgres  ##pgxc系统管理用户
pgxcUser=$pgxcOwner
pgxcInstallDir=$ADB2_1_HOME ##pgxc安装目录

#gtm and gtmproxy
gtmMasterDir=$ADB2_1_DATA/gtm ##gtm节点数据文件目录
gtmMasterPort=6666  ##gtm监听端口（注意不要和其他端口冲突）
gtmMasterServer=localhost ##gtm部署机器名称
gtmSlave=n  ##控制是否启用gtm从机参数(y启用 n不启用)

#gtm proxy 
gtmProxy=n  ##控制是否启用gtmproxy的参数(y启用 n不启用)
gtmProxyDir=$ADB2_1_DATA  ##gtmproxy数据文件目录
gtmProxyNames=(gtm_pxy1 gtm_pxy2 gtm_pxy3)  ##gtmproxy不同节点名称
gtmProxyServers=(cd01 cd02 cd03)  ##部署gtmproxy的机器名称
gtmProxyPorts=(20001 20001 20001) ##gtmproxy节点监听端口（注意不要和其他端口冲突）
gtmProxyDirs=($gtmProxyDir/gtmproxy1 $gtmProxyDir/gtmproxy2 $gtmProxyDir/gtmproxy3)  ##gtmproxy文件目录
gtmPxyExtraConfig=none  ##gtmproxy参数文件配置
gtmPxySpecificExtraConfig=(none none none)  ##gtmproxy其他特殊参数配置

#coordinator 
coordMasterDir=$ADB2_1_DATA  ##coordinator节点数据文件目录
coordNames=(coord1 coord2 coord3)  ##coordinator不同节点名称
coordPorts=(5432 5433 5434)  ##coordinator监听端口（注意不要和其他端口冲突）
poolerPorts=(20011 20012 20013)  ##coordinator连接池监听端口（注意不要和其他端口冲突）
coordPgHbaEntries=(192.168.56.0/24)  ##配置允许客户端连接的IP地址范围根据实际IP修改
coordMasterServers=(cd01 cd02 cd03)  ##部署coordinator不同节点的机器名称
coordMasterDirs=($coordMasterDir/coord1 $coordMasterDir/coord2 $coordMasterDir/coord3)  ##coordinator节点数据目录路径
coordMaxWALsernder=5  ##coordinator节点wal日志最大发送进程数（启用coordinator slave）
coordMaxWALSenders=($coordMaxWALsernder $coordMaxWALsernder $coordMaxWALsernder) 
coordSlave=n  ##配置是否启用coordinator slave(y启用 n不启用)
coordSpecificExtraConfig=(none none none)  ##coordinator节点数据库参数配置
coordSpecificExtraPgHba=(none none none)  ##coordinator节点客户端连接参数配置

#datanode
datanodeMasterDir=$ADB2_1_DATA  ##datanode数据文件目录
datanodeMasterDirs=($datanodeMasterDir/datanode1 $datanodeMasterDir/datanode2 $datanodeMasterDir/datanode3)  ##datanode节点数据目录
datanodeNames=(datanode1 datanode2 datanode3)  ##datanode不同节点名称
datanodeMasterServers=(cd01 cd02 cd03)  ##部署datanode不同节点的机器名称
datanodePorts=(15432 15433 15434)  ##datanode节点监听端口号（注意不要和其他端口冲突）
datanodePoolerPorts=(20001 20002 20003) ##datanode连接池监听端口号（注意不要和其他端口冲突）
datanodePgHbaEntries=(192.168.56.0/24)  ##配置允许客户端连接的IP地址范围根据实际IP修改
datanodeMaxWalSender=0  ## datanode节点wal日志最大发送进程数（启用coordinator slave）
datanodeMaxWALSenders=($datanodeMaxWalSender $datanodeMaxWalSender $datanodeMaxWalSender) 
datanodeSlave=n  ##配置是否启用datanode slave(y 启用 n不启用)
primaryDatanode=datanode1  ##配置datanode主节点名称（集群中datanode节点必须有一个主节点）
datanodeSpecificExtraConfig=(none none none)  ##datanode节点数据库参数配置
datanodeSpecificExtraPgHba=(none none none)  ##datanode节点客户端连接参数配置
EOF

# pgxc_ctl
pgxc_ctl kill all
pgxc_ctl clean all
pgxc_ctl init all
pgxc_ctl monitor all

pgxc_ctl.conf 添加了最后两行配置，否则报错：
ERROR: Number of elements in datanode master definitions are different datanodeNames and datanodeSpecificExtraConfig.  Check your configuration
ERROR: Number of elements in datanode master definitions are different datanodeNames and datanodeSpecificExtraPgHba.  Check your configuration


检查端口：
[root@dang-db ~]# netstat -apn | grep postgres
tcp        0      0 0.0.0.0:15432               0.0.0.0:*                   LISTEN      5651/postgres
tcp        0      0 0.0.0.0:15433               0.0.0.0:*                   LISTEN      5652/postgres
tcp        0      0 0.0.0.0:15434               0.0.0.0:*                   LISTEN      5656/postgres
tcp        0      0 0.0.0.0:5432                0.0.0.0:*                   LISTEN      4978/postgres
tcp        0      0 0.0.0.0:5433                0.0.0.0:*                   LISTEN      4980/postgres
tcp        0      0 0.0.0.0:5434                0.0.0.0:*                   LISTEN      4982/postgres
tcp        0      0 :::15432                    :::*                        LISTEN      5651/postgres
tcp        0      0 :::15433                    :::*                        LISTEN      5652/postgres
tcp        0      0 :::15434                    :::*                        LISTEN      5656/postgres
tcp        0      0 :::5432                     :::*                        LISTEN      4978/postgres
tcp        0      0 :::5433                     :::*                        LISTEN      4980/postgres
tcp        0      0 :::5434                     :::*                        LISTEN      4982/postgres
tcp        0      0 ::1:64798                   ::1:6666                    ESTABLISHED 5656/postgres
tcp        0      0 ::1:64794                   ::1:6666                    ESTABLISHED 5651/postgres
tcp        0      0 ::1:64796                   ::1:6666                    ESTABLISHED 5652/postgres
udp        0      0 ::1:11278                   ::1:11278                   ESTABLISHED 4982/postgres
udp        0      0 ::1:60311                   ::1:60311                   ESTABLISHED 5656/postgres
udp        0      0 ::1:55074                   ::1:55074                   ESTABLISHED 5651/postgres
udp        0      0 ::1:35887                   ::1:35887                   ESTABLISHED 4980/postgres
udp        0      0 ::1:52931                   ::1:52931                   ESTABLISHED 4978/postgres
udp        0      0 ::1:21749                   ::1:21749                   ESTABLISHED 5652/postgres
unix  2      [ ACC ]     STREAM     LISTENING     294922 4980/postgres       /tmp/.s.PGSQL.5433
unix  2      [ ACC ]     STREAM     LISTENING     294967 4985/postgres       .s.PGPOOL
unix  2      [ ACC ]     STREAM     LISTENING     294993 4988/postgres       .s.PGPOOL
unix  2      [ ACC ]     STREAM     LISTENING     307165 5651/postgres       /tmp/.s.PGSQL.15432
unix  2      [ ACC ]     STREAM     LISTENING     307170 5652/postgres       /tmp/.s.PGSQL.15433
unix  2      [ ACC ]     STREAM     LISTENING     307172 5656/postgres       /tmp/.s.PGSQL.15434
unix  2      [ ACC ]     STREAM     LISTENING     295002 4995/postgres       .s.PGPOOL
unix  2      [ ACC ]     STREAM     LISTENING     294915 4978/postgres       /tmp/.s.PGSQL.5432
unix  2      [ ACC ]     STREAM     LISTENING     294921 4982/postgres       /tmp/.s.PGSQL.5434
[root@dang-db ~]# netstat -apn | grep 6666
tcp        0      0 0.0.0.0:6666                0.0.0.0:*                   LISTEN      4484/gtm
tcp        0      0 :::6666                     :::*                        LISTEN      4484/gtm
tcp        0      0 ::1:6666                    ::1:64798                   ESTABLISHED 4484/gtm
tcp        0      0 ::1:6666                    ::1:64796                   ESTABLISHED 4484/gtm
tcp        0      0 ::1:6666                    ::1:64810                   TIME_WAIT   -
tcp        0      0 ::1:64798                   ::1:6666                    ESTABLISHED 5656/postgres
tcp        0      0 ::1:64794                   ::1:6666                    ESTABLISHED 5651/postgres
tcp        0      0 ::1:64811                   ::1:6666                    TIME_WAIT   -
tcp        0      0 ::1:64796                   ::1:6666                    ESTABLISHED 5652/postgres
tcp        0      0 ::1:6666                    ::1:64794                   ESTABLISHED 4484/gtm
tcp        0      0 ::1:64812                   ::1:6666                    TIME_WAIT   -

