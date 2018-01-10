#!/bin/bash
############################
# description:系统优化脚本,当前脚本适用于CentOS 7.X
# version：1.1.2
# author：赵金龙 <zhaojinlong898@qq.com>
# date:2017-6-5
############################

#加载一下环境变量PATH
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/root/bin
source /etc/profile

# 检查是否为root用户，脚本必须在root权限下运行
[ $(id -u) -gt 0 ] && echo "请用root用户执行此脚本！" && exit 1

#检查是否为x86_64处理器
platform=`uname -i`
if [ $platform != "x86_64" ];then 
echo "this script is only for 64bit Operating System !"
exit 1
fi
echo "the platform is ok"
cat << EOF
+---------------------------------------+
|   your system is CentOS 7 x86_64      |
|      start optimizing.......          |
+---------------------------------------
EOF


echo "########## 服务器基本配置 ##########"
    echo "       系统: `uname -o`"
    echo "   发行版本: `cat /etc/redhat-release`"
    echo "       内核: `uname -r`"
    echo "     主机名: `uname -n`"
    echo "    SELinux: `/usr/sbin/sestatus | grep "SELinux status: " | awk '{print $3}'`"
    echo "  语言/编码: `grep "LANG=" /etc/locale.conf | grep -v "^#" | awk -F '"' '{print $2}' `"
    echo "   当前时间: `date +'%F %T'`"
    echo "   最后启动: `who -b | awk '{print $3,$4}'`"
    echo "   运行时间: `uptime | sed 's/.*up \([^,]*\), .*/\1/'`"

    echo "物理CPU个数: `grep "physical id" /proc/cpuinfo| sort | uniq | wc -l`"
    echo "每CPU核心数: `grep "cores" /proc/cpuinfo|uniq| awk -F ': ' '{print $2}'`"
    echo "逻辑CPU个数: `grep "processor" /proc/cpuinfo | wc -l`"
    echo "    CPU型号: `grep "model name" /proc/cpuinfo | awk -F ': ' '{print $2}' | sort | uniq`"
    echo "    CPU架构: `uname -m`"
	echo "       内存: $(free -g|grep Mem|awk '{print $2}')G"
    echo "       硬盘：$(fdisk -l|grep GB|awk '{print ""$3" +"}'|xargs )"

LANG="en_US.UTF-8"	

echo -e "\n########## 备份文件系统常用目录 ###########"
#要备份到的分区：
datadir=/data

mkdir -p ${datadir}/systemfile_bak_$(date -I)
cp -a /bin/ /boot/ /dev/ /etc/ /root/ /lib*/ /sbin/ /selinux/ /var ${datadir}/systemfile_bak_$(date -I)
cd ${datadir}
tar -zcf systemfile_bak_$(date -I).tar.gz systemfile_bak_$(date -I)

echo -e "\n########## 关闭firewalld和SELINUX ##########"
setenforce 0 
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config 
grep SELINUX=disabled /etc/selinux/config

systemctl disable firewalld.service 
systemctl stop firewalld.service 
systemctl status firewalld.service

#echo -e "\n########## 安装iptables防火墙 ##########"
#yum install iptables-services -y
#systemctl restart iptables.service #最后重启防火墙使配置生效
#systemctl enable iptables.service  #设置防火墙开机启动

#echo -e "\n########## 添加普通用户netcommander ##########"
#useradd netcommander
#echo rootroot |passwd --stdin netcommander
#usermod -G wheel netcommander
#sed -i '6s/^#//g'  /etc/pam.d/su
#grep wheel  /etc/pam.d/su           #只有WHEEL组的可以su

echo -e "\n########## 添加密钥 ##########"
mkdir -m 700  ~/.ssh 
ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
cp  ~/.ssh/id_dsa.pub  ~/.ssh/authorized_keys
chmod 600 ~/.ssh/{authorized_keys,id_dsa.pub}

echo -e "\n########## 配置DNS ##########"
echo -e  'nameserver 114.114.114.114\nnameserver 223.5.5.5' > /etc/resolv.conf
cat /etc/resolv.conf

echo -e "\n########## 优化sshd设置  ##########"
#sed -n 's/#PermitRootLogin yes/PermitRootLogin no/gp'  /etc/ssh/sshd_config
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
systemctl restart sshd.service
egrep --color "GSSAPIAuthentication|UseDNS|PermitEmptyPasswords" /etc/ssh/sshd_config 
sleep 1

echo -e "\n########## 添加java路径别名 ##########"
cat  >> /etc/profile.d/java_pwdx.sh << EOF
#pp=java_pwdx
# alias pp='ps -ef| grep java | grep -v grep |cut -b10-15 |xargs pwdx' 2>/dev/null
alias pp='jps -q |xargs pwdx' 2>/dev/null
EOF
source /etc/profile
alias

echo -e "\n########## 优化vim的配置 ##########"
> ~/.vimrc
cat  >> ~/.vimrc << EOF
"""""""""""""""""""""""
" vimrc config file
" E-mail: zhaojinlong898@qq.com
" date  : 2017-03-15
""""""""""""""""""""""""
syntax on
set nu
set sm
set ai
set expandtab
set hlsearch
set tabstop=4
set softtabstop=4
set shiftwidth=4 
EOF


#echo -e "\n########## 优化内存 ##########"
#sysctl vm.swappiness=0
#echo "vm.swappiness=0" >>  /etc/sysctl.conf
#sysctl -p
#swapoff -a    && swapon  -a
#cat /proc/sys/vm/swappiness

echo -e "\n########## 更改文件句柄数 ##########"
#sed -i "/^ulimit -SHn.*/d" /etc/rc.local
#echo "ulimit -SHn 1024000" >> /etc/rc.local

#sed -i "/^ulimit -s.*/d" /etc/profile
#sed -i "/^ulimit -c.*/d" /etc/profile
#sed -i "/^ulimit -SHn.*/d" /etc/profile
 
#cat >> /etc/profile << EOF
##ulimit
#ulimit -c unlimited
#ulimit -s unlimited
#ulimit -SHn 102400
#EOF
#source /etc/profile

if [ ! -f "/etc/security/limits.conf.bak" ]; then
    cp /etc/security/limits.conf /etc/security/limits.conf.bak
fi
sed -i "/^*.*soft.*nofile/d" /etc/security/limits.conf
sed -i "/^*.*hard.*nofile/d" /etc/security/limits.conf
sed -i "/^*.*soft.*nproc/d" /etc/security/limits.conf
sed -i "/^*.*hard.*nproc/d" /etc/security/limits.conf

cat >> /etc/security/limits.conf << EOF
#
#---------custom-----------------------
#
*           soft   nofile       240000
*           hard   nofile       655350
*           soft   nproc        240000
*           hard   nproc        655350
#-----------end-----------------------
EOF
grep -v ^# /etc/security/limits.conf
source /etc/security/limits.conf
#普通用户的线程数4096改为36000
sed -i 's#4096#36000#g' /etc/security/limits.d/20-nproc.conf
ulimit -a

echo -e "\n########## 内核参数优化  ##########"
cat >> /etc/sysctl.d/long-sysctl.conf << EOF
#CTCDN系统优化参数
#关闭ipv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

#决定检查过期多久邻居条目
net.ipv4.neigh.default.gc_stale_time=120

#使用arp_announce / arp_ignore解决ARP映射问题
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.all.arp_announce=2
net.ipv4.conf.lo.arp_announce=2

#避免放大攻击
net.ipv4.icmp_echo_ignore_broadcasts = 1

#开启恶意icmp错误消息保护
net.ipv4.icmp_ignore_bogus_error_responses = 1

#关闭路由转发
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

#开启反向路径过滤
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

#处理无源路由的包
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

#关闭sysrq功能
kernel.sysrq = 0

#core文件名中添加pid作为扩展名
kernel.core_uses_pid = 1

# 开启SYN洪水攻击保护
net.ipv4.tcp_syncookies = 1

#修改消息队列长度
kernel.msgmnb = 65536
kernel.msgmax = 65536

#设置最大内存共享段大小bytes
kernel.shmmax = 68719476736
kernel.shmall = 4294967296

#timewait的数量，默认180000
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096        87380   4194304
net.ipv4.tcp_wmem = 4096        16384   4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216

#每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目
net.core.netdev_max_backlog = 262144

#限制仅仅是为了防止简单的DoS 攻击
net.ipv4.tcp_max_orphans = 3276800

#未收到客户端确认信息的连接请求的最大值
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0

#内核放弃建立连接之前发送SYNACK 包的数量
net.ipv4.tcp_synack_retries = 1

#内核放弃建立连接之前发送SYN 包的数量
net.ipv4.tcp_syn_retries = 1

#启用timewait 快速回收
net.ipv4.tcp_tw_recycle = 1

#开启重用。允许将TIME-WAIT sockets 重新用于新的TCP 连接
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1

#当keepalive 起用的时候，TCP 发送keepalive 消息的频度。缺省是2 小时
net.ipv4.tcp_keepalive_time = 1800
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl = 15

#允许系统打开的端口范围
net.ipv4.ip_local_port_range = 1024    65000

#修改防火墙表大小，默认65536
net.netfilter.nf_conntrack_max=655350
net.netfilter.nf_conntrack_tcp_timeout_established=1200

#确保无人能修改路由表
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
vm.swappiness = 10
kernel.panic = 5
fs.file-max = 165535

#for high-latency network
net.ipv4.tcp_congestion_control = hybla
maximize the available memory
vm.overcommit_memory = 1
vm.dirty_ratio = 1
vm.swappiness = 10
vm.vfs_cache_pressure = 110
#vm.zone_reclaim_mode = 0

#keep the IO performance steady
vm.dirty_background_ratio = 1
vm.dirty_writeback_centisecs = 100
vm.dirty_expire_centisecs = 100
EOF
/sbin/sysctl -p

echo -e "\n########## Yum源更换为阿里源 ##########"
yum install wget telnet -y
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

echo -e "\n########## 添加阿里的epel源 ##########"
yum install wget telnet -y
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
#rpm -ivh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
#rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

echo -e "\n########## yum重新建立缓存 ##########"
yum clean all
yum makecache

echo -e "\n########## 时间同步(外网ntp) ##########"

#timedatectl set-local-rtc 1
timedatectl set-timezone Asia/Shanghai
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

yum install -y ntp
#/usr/sbin/ntpdate cn.pool.ntp.org
/usr/sbin/ntpdate ntp1.aliyun.com
echo '*/10 * * * * /usr/sbin/ntpdate ntp1.aliyun.com > /dev/null 2>&1;/sbin/hwclock -w' >> /var/spool/cron/root
systemctl  restart crond.service
crontab -l

echo -e "\n######## 设置字符集 #########"
echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf 
source  /etc/locale.conf
echo $LANG

echo -e "\n########## 装基础yum包 ##########"
yum install -y vim lrzsz tree dos2unix unix2dos sysstat nmap lsof wget telnet perl perl-devel
yum install -y gcc gcc-c++ automake autoconf camke net-tools kernel-devel bash-completion

cat << EOF
+-------------------------------------------------+
|               optimizer is done                 |
|   it's recommond to restart this server !       |
+-------------------------------------------------+
EOF
exit 1
