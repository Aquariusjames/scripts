#!/bin/bash
############################
# description:系统优化脚本,当前脚本适用于CentOS/RedHat 6.X
# version：1.3.2
# author：赵金龙 <zhaojinlong898@qq.com>
# date:2017-8-5
############################

#加载一下环境变量PATH
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
source /etc/profile

# 检查是否为root用户，脚本必须在root权限下运行
[ $(id -u) -gt 0 ] && echo "请用root用户执行此脚本！" && exit 1

echo "########## 服务器基本配置 ##########"
echo "         系统: $(uname -o)"
echo "     发行版本: $(cat /etc/redhat-release)"
echo "         内核: $(uname -r)"
echo "       主机名: $(uname -n)"
echo "      SELinux: $(/usr/sbin/sestatus | grep "SELinux status: " | awk '{print $3}')"
echo "    语言/编码: $(grep "LANG=" /etc/sysconfig/i18n | grep -v "^#" | awk -F '"' '{print $2}')"
echo "       IP地址：$(ifconfig |grep -Po  '(?<=addr:).*(?= B)'|xargs)"
echo "     当前时间: $(date +'%F %T')"
echo "     运行时间: $(uptime |awk '{print $3,$4,$5}')"
echo "     系统负荷：$(uptime |awk '{print $10,$11,$12}')"

echo "  物理CPU个数: $(grep "physical id" /proc/cpuinfo| sort | uniq | wc -l)"
echo "  每CPU核心数: $(grep "cores" /proc/cpuinfo|uniq| awk -F ': ' '{print $2}')"
echo "  逻辑CPU个数: $(grep "processor" /proc/cpuinfo | wc -l)"
echo "      CPU型号: $(grep "model name" /proc/cpuinfo | awk -F ': ' '{print $2}' | sort | uniq)"
echo "      CPU架构: $(uname -m)"
echo "         硬盘：$(fdisk -l|grep GB|awk '{print $2,$3,$4}'|xargs)"
# echo "         硬盘：$(parted -l | grep 'Disk /dev/sd')"
echo " 最大支持内存: $(dmidecode -t memory| grep "Maximum Capacity"| awk '{print $3,$4}')"
echo " 物理内存总数：$(dmidecode|grep -P -A5 "Memory Device" |grep MB|awk '{sum += $2};END {print sum}'|awk '{print "expr "$1" / 1024"}'|bash) GB"
echo "     系统内存: $(free -g|grep Mem|awk '{print ""$2" GB"}')"
echo " 当前内存个数：$(dmidecode|grep -P -A5 "Memory Device" |grep Size |grep MB |wc -l)"
echo "   内存插槽数: $(dmidecode|grep -P -A5 "Memory Device" |grep Size |wc -l)"
echo " 每个内存大小: $(dmidecode|grep -P -A5 "Memory Device" |grep Size)" 
echo " 每个内存速率: $(dmidecode|grep -A16 "Memory Device"|grep 'Speed')"

LANG="en_US.UTF-8"	

echo -e "\n########## 备份文件系统常用目录 ###########"
#要备份到的分区：
datadir=/data/tools

mkdir -p ${datadir}/systemfile_bak_$(date -I)/usr/
cp -a /bin/ /boot/ /dev/ /etc/ /root/ /lib*/ /sbin/ /selinux/ /var ${datadir}/systemfile_bak_$(date -I)/
cp -a /usr/bin /usr/sbin/ ${datadir}/systemfile_bak_$(date -I)/usr/
cd ${datadir}
tar -zcf systemfile_bak_$(date -I).tar.gz systemfile_bak_$(date -I)

echo -e "\n########## 关闭iptables和SELINUX ##########"
/etc/init.d/iptables stop 
setenforce 0 
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config 
grep SELINUX=disabled /etc/selinux/config
/etc/init.d/iptables status

echo -e "\n########## 优化开机启动项 ##########"
#开机优化（sshd、network、crond、syslog、rsyslog、ntpdate）服务保持默认开机启动
LANG=en_US.UTF-8
chkconfig --list|egrep -v "crond|network|rsyslog|sshd|sysstat" | awk '{print"chkconfig "$1" off"}' | bash
chkconfig --list

echo -e "\n########## 删除特殊的的用户帐号和组帐号 ##########"
userdel halt
userdel uucp
userdel operator
userdel gopher

groupdel uucp
groupdel video
groupdel dip

#echo -e "\n########## 优化内存 ##########"
#sysctl vm.swappiness=0
#echo "vm.swappiness=0" >>  /etc/sysctl.conf
#sysctl -p
#swapoff -a    && swapon  -a
#cat /proc/sys/vm/swappiness

echo -e "\n########## 添加密钥 ##########"
mkdir -m 700  ~/.ssh 
ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
cp  ~/.ssh/id_dsa.pub  ~/.ssh/authorized_keys
chmod 644 ~/.ssh/{authorized_keys,id_dsa.pub}

echo -e "\n########## 配置DNS ##########"
echo -e  'nameserver 114.114.114.114\nnameserver 8.8.8.8' > /etc/resolv.conf
cat /etc/resolv.conf



echo -e "\n########## 时间同步(外网ntp) ##########"

echo -e 'ZONE="Asia/Shanghai"\nUTC=false\nARC=false' > /etc/sysconfig/clock
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

/usr/sbin/ntpdate ntp1.aliyun.com

TIME_NTPDATE=$(grep ntpdate /var/spool/cron/root|wc -l)
[ ${TIME_NTPDATE} -eq 1 ] || echo '*/10 * * * * /usr/sbin/ntpdate ntp1.aliyun.com > /dev/null 2>&1;/sbin/hwclock -w' >> /var/spool/cron/root
/etc/init.d/crond restart
crontab -l

echo -e "\n########## Yum源更换为阿里源 ##########"
yum install wget telnet -y
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

echo -e "\n########## 添加阿里的epel源 ##########"
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
#rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
#rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm


echo -e "\n########## 更改文件句柄数 ##########"
#sed -i "/^ulimit -SHn.*/d" /etc/rc.local
#echo "ulimit -SHn 102400" >> /etc/rc.local
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
#
#---------custom-----------------------
#
*           soft   nofile       24000
*           hard   nofile       65535
*           soft   nproc        24000
*           hard   nproc        65535
#-----------end-----------------------
EOF
grep -v ^# /etc/security/limits.conf
source /etc/security/limits.conf
#普通用户的线程数由1024改为20480
sed -i 's#1024#20480#g' /etc/security/limits.d/90-nproc.conf
ulimit -a

echo -e "\n########## 优化sshd连接速度  ##########"
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config			
sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
/etc/init.d/sshd restart
egrep --color "GSSAPIAuthentication|UseDNS|PermitEmptyPasswords" /etc/ssh/sshd_config 
sleep 1

echo -e "\n########## 修改默认字体 ##########"
echo 'LANG="zh_CN.UTF-8"' >  /etc/sysconfig/i18n
LANG="zh_CN.UTF-8"
cat /etc/sysconfig/i18n

echo -e "\n########## 把/usr/local/lib*添加到系统动态链接库 ##########"
echo -e "/usr/local/lib/\n/usr/local/lib64/" > /etc/ld.so.conf.d/local-lib-x86_64.conf	&& ldconfig


echo -e "\n########## 添加别名 ##########"
cat  >> /etc/profile.d/java_pwdx_grep.sh << EOF
alias vi='vim'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
#pp=java_pwdx
alias pp='ps -ef| grep java | grep -v grep |cut -b10-15 |xargs pwdx' 2>/dev/null
# alias pp='jps -q |xargs pwdx' 2>/dev/null
EOF
source /etc/profile
alias

echo -e "\n########## 优化vim的配置 ##########"
cp ~/.vimrc ~/.vimrc_bak
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
set hlsearch
set tabstop=4
set softtabstop=4
set shiftwidth=4 
set noautoindent		" <== 关闭自动对齐
EOF



echo -e "\n########## 装基础yum包 ##########"
yum clean all
yum makecache
yum install -y gcc gcc-c++ make cmake automake autoconf  lrzsz tree dos2unix unix2dos sysstat nmap bash-completion  wget telnet
exit 1
