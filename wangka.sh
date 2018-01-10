#!/bin/bash
#统计一段时间内mdp网卡接收的平均流量（此脚本默认双网卡)
#依据为ifconfig上指定网卡上接收总流量的差值
#*/10 * * * * /bin/bash /root/shell/wangka.sh > /dev/null
##########################################################
source /etc/profile
riqi=`date +%Y-%m-%d`		#日期
shijian=`date +%H:%M:%S`	#时间
duration=120			    #时间段(秒)
path=/root/shell/		    #保存路径
##########################################################

[ ! -d "${path}" ] && mkdir -p ${path}
ip=`ifconfig|grep Bcast|awk '{print $2}'|awk -F ':' '{print $2}'|xargs`
mdp_eth1=`ip addr|grep PROMISC|awk -F  ':' '{print $2}'|xargs |awk '{print $1}'`
mdp_eth2=`ip addr|grep PROMISC|awk -F  ':' '{print $2}'|xargs |awk '{print $2}'`

#echo  -e "\nstart:flow_`date +%Y%m%d_%H:%M:%S`"
RXpre1=$(ifconfig ${mdp_eth1} | grep bytes | awk  '{print $2}'| awk -F":" '{print $2}')
TXpre1=$(ifconfig ${mdp_eth1} | grep bytes | awk '{print $6}' | awk -F":" '{print $2}')

RXpre2=$(ifconfig ${mdp_eth2} | grep bytes | awk  '{print $2}'| awk -F":" '{print $2}')
TXpre2=$(ifconfig ${mdp_eth2} | grep bytes | awk '{print $6}' | awk -F":" '{print $2}')

sleep ${duration}
RXnext1=$(ifconfig ${mdp_eth1} | grep bytes | awk  '{print $2}'| awk -F":" '{print $2}')
TXnext1=$(ifconfig ${mdp_eth1} | grep bytes | awk '{print $6}' | awk -F":" '{print $2}')

RXnext2=$(ifconfig ${mdp_eth2} | grep bytes | awk  '{print $2}'| awk -F":" '{print $2}')
TXnext2=$(ifconfig ${mdp_eth2} | grep bytes | awk '{print $6}' | awk -F":" '{print $2}')

# 1 byte = 8 bit 
# 1 KB = 1024 bytes =210 bytes 
# 1 MB = 1024 KB = 220 bytes 
# 1 GB = 1024 MB = 230 bytes
((rx1=(${RXnext1}-${RXpre1})*8/${duration}))
((tx1=(${TXnext1}-${TXpre1})*8/${duration}))

((rx2=(${RXnext2}-${RXpre2})*8/${duration}))
((tx2=(${TXnext2}-${TXpre2})*8/${duration}))

echo  -e "${riqi} ${shijian}   ${ip} ${mdp_eth1}   RX = $((${rx1}/1024/1024)) Mb/s "  >> ${path}/flow_${mdp_eth1}.txt
echo  -e "${riqi} ${shijian}   ${ip} ${mdp_eth2}   RX = $((${rx2}/1024/1024)) Mb/s "  >> ${path}/flow_${mdp_eth2}.txt
#echo  -e "\nstop :flow_`date +%Y%m%d_%H:%M:%S`"
