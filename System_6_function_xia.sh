#!/bin/bash
. /etc/init.d/functions


# Defined result function
function Msg(){
        if [ $? -eq 0 ];then
          action "$1" /bin/true
        else
          action "$1" /bin/false
        fi
}

# Defined IP function
function ConfigIP(){
	Suffix1="$1"
	Suffix2="$2"
        sed -ri "s#(IPADDR=)(.*)#\1$Suffix1#" /etc/sysconfig/network-scripts/ifcfg-eth0
        ifdown eth0 && ifup eth0
	Msg "config eth0"
        sed -ri "s#(IPADDR=)(.*)#\1$Suffix2#" /etc/sysconfig/network-scripts/ifcfg-eth1
        ifdown eth1 && ifup eth1
        Msg "config eth1"
}

# Defined Yum source Functions
function yum(){
	YumDir=/etc/yum.repos.d
        wget -O $YumDir/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
	Msg "YUM source"
}

# Defined Close selinux Functions
function selinux(){
	[ -f "/etc/selinux/config" ] && {
	sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
        setenforce 0
	Msg "Close selinux"
	} || Msg "Close selinux"
}

# Defined Close iptables Functions
function iptablesOff(){
        /etc/init.d/iptables stop
        chkconfig iptables off
}

# Defined add Ordinary users Functions
function AddUser(){
	useradd oldboy &>/dev/null &&\
	echo "123456"|passwd --stdin oldboy &>/dev/null &&\
	sed  -i '98a oldboy    ALL=(ALL)       NOPASSWD:ALL'  /etc/sudoers &&\
	visudo -c &>/dev/null
	Msg "AddUser oldboy"
}

# Defined Hide the system version number Functions
function HideVersion(){
	[ -f "/etc/issue" ] && >/etc/issue
        Msg "Hide issue"
	[ -f "/etc/issue.net" ] && > /etc/issue.net
        Msg "Hide issue.net"
}


# Defined SSHD config Functions
function sshd(){
	SshdDir=/etc/ssh
	[ -f "$SshdDir/sshd_config" ] && \
        sed -i.bak 's#GSSAPIAuthentication yes#GSSAPIAuthentication no#g;s@#UseDNS yes@UseDNS no@g' $SshdDir/sshd_config
        Msg "sshd config"
}

# Defined OPEN FILES Functions
function openfiles(){
	[ -f "/etc/security/limits.conf" ] && {
	echo '*  -  nofile  65535' >> /etc/security/limits.conf
        Msg "open files"
	}
}



# Defined System Startup Services Functions
function boot(){
	for i in `chkconfig --list|grep "3:on"|awk '{print $1}'|egrep -v "crond|network|rsyslog|sshd|sysstat"`
	  do 
	   chkconfig $i off
	done
	Msg "BOOT config"
}

# Defined Time Synchronization Functions
function Time(){
	echo "#time sync by $(whoami) at $(date +%F)" >>/var/spool/cron/root
	echo '*/5 * * * * /usr/sbin/ntpdate ntp1.aliyun.com &>/dev/null' >>/var/spool/cron/root
        Msg "Time Synchronization"
}

# Defined main Functions
function main(){
        iptablesOff
        selinux
        [ ! -z "$1" -a ! -z "$2" ] && ConfigIP "$1" "$2"
	AddUser
	HideVersion
	sshd
	openfiles
	boot
	Time		
        yum
}
main "$1" "$2"