#!/bin/bash
#注意shell和expect脚本都需要执行权限
username='root'
password='rootroot'
prefixIP=192.168.9
postfixIP=`seq 21 24`
# 获取脚本绝对路径
readonly PROGDIR=$(readlink -m $(dirname $0))

# Config ssh nopassword login
echo "Config ssh on master"
# If the directory "~/.ssh" is not exist, then execute mkdir and chmod
[ ! -d ~/.ssh ] && ( mkdir ~/.ssh ) && ( chmod 700 ~/.ssh )
# If the file "~/.ssh/id_rsa.pub" is not exist, then execute ssh-keygen and chmod
[ ! -f ~/.ssh/id_rsa.pub ] && ( yes|ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa ) && ( chmod 600 ~/.ssh/id_rsa.pub )

checkExpect=`rpm -qa | grep expect`
#检查是否安装expect,并安装
if [ -z "$checkExpect" ]; then
    yum -y install expect >/dev/null 2>&1
fi
# For all node, including master and slaves
for node in $postfixIP; do
    # execute bin/ssh_nopassword.expect
    $PROGDIR/ssh_nopassword.expect $prefixIP.$node $username $password /$username/.ssh/id_rsa.pub >/dev/null 2>&1
    echo "$prefixIP.$node done."
done
echo "Config ssh successful."