#!/bin/bash
############################
# description:系统优化脚本,当前脚本适用于CentOS/RedHat 6.X
# version：2.6.2
# author：赵金龙 <zhaojinlong898@qq.com>
# date:2017-12-26
############################

#set env
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Source function library.
. /etc/init.d/functions


# 检查是否为root用户，脚本必须在root权限下运行
[ $(id -u) -gt 0 ] && echo "请用root用户执行此脚本！" && exit 1


# Defined result function
function Msg(){
    if [ $? -eq 0 ];then
      action "$1" /bin/true
    else
      action "$1" /bin/false
    fi
}


function server_basic_configuration(){
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
	#echo " 当前内存个数：$(dmidecode|grep -P -A5 "Memory Device" |grep Size |grep MB |wc -l)"
	#echo "   内存插槽数: $(dmidecode|grep -P -A5 "Memory Device" |grep Size |wc -l)"
	#echo " 每个内存大小: $(dmidecode|grep -P -A5 "Memory Device" |grep Size)" 
	#echo " 每个内存速率: $(dmidecode|grep -A16 "Memory Device"|grep 'Speed')"
}
LANG="en_US.UTF-8"	


function backup_dir(){
	echo -e "\n########## 备份文件系统常用目录 ###########"
	#要备份到的分区：
	datadir=/data/tools

	if [ ! -d ${datadir}/systemfile_bak_$(date -I)/usr ]
          then  
	    mkdir -p ${datadir}/systemfile_bak_$(date -I)/usr/
	    cp -a /bin/ /boot/ /dev/ /etc/ /root/ /lib*/ /sbin/ /selinux/ /var ${datadir}/systemfile_bak_$(date -I)
            cp -a /usr/bin /usr/sbin/ ${datadir}/systemfile_bak_$(date -I)/usr/
	    cd ${datadir}
	    tar -zcf systemfile_bak_$(date -I).tar.gz systemfile_bak_$(date -I)
	fi
	
}


function iptables_selinux(){
	echo -e "\n########## 关闭iptables和SELINUX ##########"
	chkconfig  iptables off
	/etc/init.d/iptables stop 
	/etc/init.d/iptables status
	setenforce 0 
	[ -f /etc/selinux/config_$(date +%F) ] ||  cp -a /etc/selinux/config{,_$(date +%F)}
	sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config 
	grep SELINUX=disabled /etc/selinux/config
}


function boot_item(){
	echo -e "\n########## 优化开机启动项 ##########"
	#开机优化（sshd、network、crond、syslog、rsyslog、ntpdate）服务保持默认开机启动
	LANG=en_US.UTF-8
	chkconfig xinetd off
	chkconfig --list|egrep -v "crond|network|rsyslog|sshd|sysstat" | awk '{print"chkconfig "$1" off"}' | bash
	
	if [ $(chkconfig|grep 3:on|egrep "crond|network|rsyslog|sshd|sysstat"|wc -l) -eq 5 ]
	  then
	    action "boot_item" /bin/true
	else
	    action "boot_item" /bin/false
	fi
}


function set_swap(){
	echo -e "\n########## 优化内存 ##########"
	sysctl vm.swappiness=0
	[ -f /etc/sysctl.conf_$(date +%F) ] || cp -a /etc/sysctl.conf{,_$(date +%F)}
	echo "vm.swappiness=0" >>  /etc/sysctl.conf
	sysctl -p
	swapoff -a    && swapon  -a
	cat /proc/sys/vm/swappiness
}


function init_ssh(){
	echo -e "\n########## 优化sshd连接速度  ##########"
	[ -f /etc/ssh/sshd_config_$(date +%F) ] || cp -a /etc/ssh/sshd_config{,_$(date +%F)}
	sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
	sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config			
	sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
	/etc/init.d/sshd restart
	egrep --color "GSSAPIAuthentication|UseDNS|PermitEmptyPasswords" /etc/ssh/sshd_config 
}


function add_key(){
	echo -e "\n########## 添加密钥 ##########"
	if [ ! -f ~/.ssh/id_dsa ]
	  then
	    mkdir -m 700  ~/.ssh 
	    ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
	    cp  ~/.ssh/id_dsa.pub  ~/.ssh/authorized_keys
	    chmod 644 ~/.ssh/{authorized_keys,id_dsa.pub}
	fi
}


function configure_dns(){
	echo -e "\n########## 配置DNS ##########"
	[ -f /etc/resolv.conf_$(date +%F) ] || cp -a /etc/resolv.conf{,_$(date +%F)}
	echo -e  'nameserver 114.114.114.114\nnameserver 8.8.8.8' > /etc/resolv.conf
	cat /etc/resolv.conf
}


function time_update(){
	echo -e "\n########## 时间同步(外网ntp) ##########"
	
	[ -f /etc/sysconfig/clock_$(date +%F) ] || cp -a /etc/sysconfig/clock{,_$(date +%F)}
	echo -e 'ZONE="Asia/Shanghai"\nUTC=false\nARC=false' > /etc/sysconfig/clock
	cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

	/usr/sbin/ntpdate ntp1.aliyun.com
    [ -f /var/spool/cron/root ] || touch /var/spool/cron/root
	TIME_NTPDATE=$(grep -w ntpdate /var/spool/cron/root|wc -l)
	[ ${TIME_NTPDATE} -eq 0 ] && echo '*/10 * * * * /usr/sbin/ntpdate ntp1.aliyun.com > /dev/null 2>&1;/sbin/hwclock -w' >> /var/spool/cron/root
	/etc/init.d/crond restart
	crontab -l
}


function character_set(){
	echo -e "\n########## 修改默认字体 ##########"
	[ -f /etc/sysconfig/i18n_$(date +%F) ] || cp -a /etc/sysconfig/i18n{,_$(date +%F)}
	echo 'LANG="zh_CN.UTF-8"' >  /etc/sysconfig/i18n
	LANG="zh_CN.UTF-8"
	cat /etc/sysconfig/i18n
}

function ldconfig_local(){
	echo -e "\n########## 把/usr/local/lib*添加到系统动态链接库 ##########"
	echo -e "/usr/local/lib/\n/usr/local/lib64/" > /etc/ld.so.conf.d/local-lib-x86_64.conf
	ldconfig
}

function alias_set(){
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
}


function vim_config(){
	echo -e "\n########## 优化vim的配置 ##########"
	[ -e ~/.vimrc ] && mv ~/.vimrc{,.$(date +%F)}
cat  >> ~/.vimrc << EOF
"""""""""""""""""""""""
" vimrc config file
" " E-mail: 898009427@qq.com
" " date  : 2018-01-3
"""""""""""""""""""""""
syntax enable
set cursorline
hi cursorline guibg=#00ff00
hi CursorColumn guibg=#00ff00
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab
set ai
set si
set nu
set hlsearch
set encoding=utf-8
set fileencodings=utf-8
set termencoding=utf-8

autocmd BufNewFile *.py,*.cc,*.sh,*.java exec ":call SetTitle()"
func SetTitle()
    if expand("%:e") == 'sh'
        call setline(1, "#!/bin/bash")
        call setline(2, "# Author:long")
        call setline(3, "# Blog:")
        call setline(4, "# Time:".strftime("%F %T"))
        call setline(5, "# Name:".expand("%"))
        call setline(6, "# Version:V1.0")
        call setline(7, "# Description:Thisis a testscript.")
    endif
endfunc
EOF
}


function open_file_set(){
	echo -e "\n########## 更改文件句柄数 ##########"
	#[ -f /etc/rc.local_$(date +%F) ] || cp -a /etc/rc.local{,_$(date +%F)}
	#sed -i "/^ulimit -SHn.*/d" /etc/rc.local
	#echo "ulimit -SHn 102400" >> /etc/rc.local
	#source /etc/profile

	if [ ! -f "/etc/security/limits.conf_$(date +%F)" ]; then
		cp /etc/security/limits.conf{,_$(date +%F)}
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
	[ -f /etc/security/limits.d/90-nproc.conf_$(date +%F) ] || cp -a /etc/security/limits.d/90-nproc.conf{,_$(date +%F)}
	sed -i 's#1024#20480#g' /etc/security/limits.d/90-nproc.conf
	ulimit -a
	limits=/etc/security/limits.conf
	if [ $(egrep "24000|65535" ${limits} | wc -l) -eq 4 ]
	  then
	    action "${limits}" /bin/true
	else
	    action "${limits}" /bin/false
	fi
}


function kernel_set(){
	echo -e "\n########## 优化内核 ##########"
	[ -f /etc/sysctl.conf_$(date +%F) ] || cp -a /etc/sysctl.conf{,_$(date +%F)}
	if [ $(grep -w kernel_flag /etc/sysctl.conf |wc -l)  -lt 1 ]
	  then
cat >>/etc/sysctl.conf<<EOF
#kernel_flag
net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.ip_local_port_rnge = 4000 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route_gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_orphans = 16384
net.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_tcp_timeout_established = 180
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
EOF
		sysctl -p
	fi
}


function add_user(){
	echo -e "\n########## 新建普通用户 ##########"
	if [ $(grep -w jado /etc/passwd |wc -l) -lt 1 ]
	  then
		useradd jado &>/dev/null &&\
		echo "rootroot"|passwd --stdin jado &>/dev/null &&\
		sed  -i '98a jado    ALL=(ALL)       NOPASSWD:ALL'  /etc/sudoers &&\
		visudo -c &>/dev/null
		Msg "AddUser jado"
	fi
}


function del_user_group(){
	echo -e "\n########## 删除特殊的的用户帐号和组帐号 ##########"
	userdel halt
	userdel uucp
	userdel operator
	userdel gopher

	#groupdel uucp
	groupdel video
	groupdel dip
}


function mod_yum(){
	echo -e "\n########## Yum源更换为阿里源 ##########"
	yum install wget telnet -y
	mv /etc/yum.repos.d/CentOS-Base.repo{,_$(date +%F)}
	wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

	echo -e "\n########## 添加阿里的epel源 ##########"
	wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
	#rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	#rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
}


function yum_install(){
	echo -e "\n########## 装基础yum包 ##########"
	yum clean all
	yum makecache
	yum install -y gcc gcc-c++ make cmake automake autoconf  
	yum install -y lrzsz tree dos2unix sysstat bash-completion 
	yum install -y nmap wget telnet
}


function main(){
	Msg
	server_basic_configuration
	backup_dir
	iptables_selinux
	boot_item
	#set_swap
	init_ssh
	add_key
	configure_dns
	time_update
	character_set
	ldconfig_local
	alias_set
	vim_config
	open_file_set
	#kernel_set
	#add_user
	#del_user_group
	mod_yum
	yum_install
}
main
[ $? -eq 0 ] && exit 0
