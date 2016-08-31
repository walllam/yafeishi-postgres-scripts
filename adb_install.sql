# ADB install 

groupadd postgres
useradd -g postgres -d /postgres -s /bin/bash -m postgres

chown -R postgres:postgres /postgres

passwd postgres

/opt/pgsql_xc/
/data/pgsql_xc/


rm -rf /postgres/vhost

创建虚拟主机：
mkdir -p /postgres/vhost/gtm/ 
mkdir -p /postgres/vhost/cd01
mkdir -p /postgres/vhost/cd02
mkdir -p /postgres/vhost/cd03

创建主程序目录：
mkdir -p /postgres/vhost/pgsql_xc/gtm
mkdir -p /postgres/vhost/pgsql_xc/cd01
mkdir -p /postgres/vhost/pgsql_xc/cd02
mkdir -p /postgres/vhost/pgsql_xc/cd03

创建数据目录：
mkdir -p /postgres/vhost/pgdata_xc/gtm 

mkdir -p /postgres/vhost/pgdata_xc/gtmproxy1
mkdir -p /postgres/vhost/pgdata_xc/coord1
mkdir -p /postgres/vhost/pgdata_xc/datanode1

mkdir -p /postgres/vhost/pgdata_xc/gtmproxy2
mkdir -p /postgres/vhost/pgdata_xc/coord2
mkdir -p /postgres/vhost/pgdata_xc/datanode2

mkdir -p /postgres/vhost/pgdata_xc/gtmproxy3
mkdir -p /postgres/vhost/pgdata_xc/coord3
mkdir -p /postgres/vhost/pgdata_xc/datanode3


编辑hosts文件
vi /etc/hosts

192.168.56.101 gtm
192.168.56.101 cd01
192.168.56.101 cd02
192.168.56.101 cd03



ssh-keygen
ssh-copy-id -i .ssh/id_rsa.pub gtm
ssh-copy-id -i .ssh/id_rsa.pub gtm_standby
ssh-copy-id -i .ssh/id_rsa.pub cd01
ssh-copy-id -i .ssh/id_rsa.pub cd02
ssh-copy-id -i .ssh/id_rsa.pub cd03

cat /etc/ssh/sshd_config | grep Authentication



1. ssh-keygen -t rsa
Press enter for each line 
2. cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
3. chmod og-wx ~/.ssh/authorized_keys 


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

yum -qa 


./configure --prefix=/postgres/vhost/pgsql_xc/$1 --with-pgport=$2 --with-segsize=8 --with-wal-segsize=64 --with-wal-blocksize=64 --with-perl --with-python --with-openssl --with-pam --without-ldap --with-libxml --with-libxslt --enable-thread-safety --enable-depend --enable-debug --enable-cassert CFLAGS='-O0 -ggdb3'
make -j4 all && make install
cd contrib && make  && make install
cd ..

sh adb_install.sh gtm  6666
sh adb_install.sh cd01 5432
sh adb_install.sh cd02 5433
sh adb_install.sh cd03 5434

echo > .gtm
cat >> .gtm << "EOF"
# adb for gtm
#export HOME=/postgres/vhost/gtm
export PGHOME=/postgres/vhost/pgsql_xc/gtm
export PATH=$PGHOME/bin:$PATH:
EOF

echo > .cd01
cat >> .cd01 << "EOF"
# adb for cd01
#export HOME=/postgres/vhost/cd01
export PGHOME=/postgres/vhost/pgsql_xc/cd01
export PATH=$PGHOME/bin:$PATH:
EOF

echo > .cd02
cat >> .cd02 << "EOF"
# adb for cd02
#export HOME=/postgres/vhost/cd02
export PGHOME=/postgres/vhost/pgsql_xc/cd02
export PATH=$PGHOME/bin:$PATH:
EOF

echo > .cd03
cat >> .cd03 << "EOF"
# adb for cd03
#export HOME=/postgres/vhost/cd03
export PGHOME=/postgres/vhost/pgsql_xc/cd03
export PATH=$PGHOME/bin:$PATH:
EOF


目前的问题点：
1.即使是在同一台主机，也是需要做ssh互信的。
2.是否能够判断ssh过来的host参数，如果能识别，根据该参数加载不同的环境变量
3.


pgxc_ctl prepare

# user and path 
pgxcOwner=postgres  ##pgxc系统管理用户
pgxcUser=$pgxcOwner
pgxcInstallDir=/postgres/vhost/pgsql_xc/gtm ##pgxc安装目录

#gtm and gtmproxy
gtmMasterDir=/postgres/vhost/pgdata_xc/gtm ##gtm节点数据文件目录
gtmMasterPort=6666  ##gtm监听端口（注意不要和其他端口冲突）
gtmMasterServer=localhost ##gtm部署机器名称
gtmSlave=n  ##控制是否启用gtm从机参数(y启用 n不启用)

#gtm proxy 
gtmProxy=n  ##控制是否启用gtmproxy的参数(y启用 n不启用)
gtmProxyDir=/postgres/vhost/pgdata_xc  ##gtmproxy数据文件目录
gtmProxyNames=(gtm_pxy1 gtm_pxy2 gtm_pxy3)  ##gtmproxy不同节点名称
gtmProxyServers=(cd01 cd02 cd03)  ##部署gtmproxy的机器名称
gtmProxyPorts=(20001 20001 20001) ##gtmproxy节点监听端口（注意不要和其他端口冲突）
gtmProxyDirs=($gtmProxyDir/gtmproxy1 $gtmProxyDir/gtmproxy2 $gtmProxyDir/gtmproxy3)  ##gtmproxy文件目录
gtmPxyExtraConfig=none  ##gtmproxy参数文件配置
gtmPxySpecificExtraConfig=(none none none)  ##gtmproxy其他特殊参数配置

#coordinator 
coordMasterDir=/postgres/vhost/pgdata_xc  ##coordinator节点数据文件目录
coordNames=(coord1 coord2 coord3)  ##coordinator不同节点名称
coordPorts=(5432 5433 5434)  ##coordinator监听端口（注意不要和其他端口冲突）
poolerPorts=(20011 20012 20013)  ##coordinator连接池监听端口（注意不要和其他端口冲突）
coordPgHbaEntries=(192.168.56.0/24)  ##配置允许客户端连接的IP地址范围根据实际IP修改
coordMasterServers=(localhost localhost localhost)  ##部署coordinator不同节点的机器名称
coordMasterDirs=($coordMasterDir/coord1 $coordMasterDir/coord2 $coordMasterDir/coord3)  ##coordinator节点数据目录路径
coordMaxWALsernder=5  ##coordinator节点wal日志最大发送进程数（启用coordinator slave）
coordMaxWALSenders=($coordMaxWALsernder $coordMaxWALsernder $coordMaxWALsernder) 
coordSlave=n  ##配置是否启用coordinator slave(y启用 n不启用)
coordSpecificExtraConfig=(none none none)  ##coordinator节点数据库参数配置
coordSpecificExtraPgHba=(none none none)  ##coordinator节点客户端连接参数配置

#datanode
datanodeMasterDir=/postgres/vhost/pgdata_xc  ##datanode数据文件目录
datanodeMasterDirs=($datanodeMasterDir/datanode1 $datanodeMasterDir/datanode2 $datanodeMasterDir/datanode3)  ##datanode节点数据目录
datanodeNames=(datanode1 datanode2 datanode3)  ##datanode不同节点名称
datanodeMasterServers=(localhost localhost localhost)  ##部署datanode不同节点的机器名称
datanodePorts=(15432 15433 15434)  ##datanode节点监听端口号（注意不要和其他端口冲突）
datanodePoolerPorts=(20001 20002 20003) ##datanode连接池监听端口号（注意不要和其他端口冲突）
datanodePgHbaEntries=(192.168.56.0/24 192.168.56.0/24 192.168.56.0/24)  ##配置允许客户端连接的IP地址范围根据实际IP修改
datanodeMaxWalSender=0  ## datanode节点wal日志最大发送进程数（启用coordinator slave）
datanodeMaxWALSenders=($datanodeMaxWalSender $datanodeMaxWalSender $datanodeMaxWalSender) 
datanodeSlave=n  ##配置是否启用datanode slave(y 启用 n不启用)
primaryDatanode=datanode1  ##配置datanode主节点名称（集群中datanode节点必须有一个主节点）
datanodeSpecificExtraConfig=(none none none)  ##coordinator节点数据库参数配置
datanodeSpecificExtraPgHba=(none none none)  ##coordinator节点客户端连接参数配置

添加了最后两行配置，否则报错：
ERROR: Number of elements in datanode master definitions are different datanodeNames and datanodeSpecificExtraConfig.  Check your configuration
ERROR: Number of elements in datanode master definitions are different datanodeNames and datanodeSpecificExtraPgHba.  Check your configuration

