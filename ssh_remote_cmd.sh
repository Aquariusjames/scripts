#!/bin/bash
source /etc/profile
# 本地通过ssh批量分发/执行脚本

####################################
user=root
port=22

ip_list=$(cat /root/script/ip.txt)
input=/root/script/remote_cmd.sh
output=$(dirname ${input})

script_name=${input##*/}

[ ! -f ${ip_list} ] && echo "ip file is not exist." && exit 1
[ ! -f ${input} ] && echo "input script is not exist." && exit 1
#####################################
for ip in ${ip_list[*]}
do
	# 自动新建远程output的目录
	ssh -t  -p ${port} $user@$ip "[ ! -d ${output} ] && mkdir -p ${output}"
	
	# 分发脚本，远程执行脚本
	scp -P ${port} -rp  ${input} $user@$ip:${output} 
	ssh -t  -p ${port} $user@$ip "bash ${output}/${script_name}" 
done
