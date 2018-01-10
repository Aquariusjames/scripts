#!/bin/bash
# 查看网卡流量速率
# 作者：Mervin 李东全
# 时间：2014-02-12

# 使用以下命令实现自动刷新
# watch -n 0 ./nw_flow.sh
# watch -n 0 ./linuxidc.sh em1

eth="eth4"
if [ -n "$1" ]; then
        eth=$1
        echo "ifcfg is [ $eth ] "
        echo "-------------------"
else
        echo "ifcfg is default. [ $eth ] "
        echo "---------------------------"
fi

RXpre=$(ifconfig ${eth} | grep bytes | awk  '{print $2}'| awk -F":" '{print $2}')
TXpre=$(ifconfig ${eth} | grep bytes | awk '{print $6}' | awk -F":" '{print $2}')
sleep 1
RXnext=$(ifconfig ${eth} | grep bytes | awk  '{print $2}'| awk -F":" '{print $2}')
TXnext=$(ifconfig ${eth} | grep bytes | awk '{print $6}' | awk -F":" '{print $2}')

#echo RX ----- TX
#echo "$(((${RXnext}-${RXpre})/1024))KB/s   $(((${TXnext}-${TXpre})/1024))KB/s"



# 1 byte = 8 bit 
# 1 KB = 1024 bytes =210 bytes 
# 1 MB = 1024 KB = 220 bytes 
# 1 GB = 1024 MB = 230 bytes
((rx=(${RXnext}-${RXpre})*8))
#echo $rx
((tx=(${TXnext}-${TXpre})*8))
#echo $tx
if (( 1024*1024 <= "$rx" )); then
        echo "RX = $((${rx}/1024/1024)) Mb/s"
elif (( 1024 <= "$rx" )); then
        echo "RX = $((${rx}/1024)) Kb/s"
else
        echo "RX = $((${rx}/1)) bit/s"
fi

if (( 1024*1024 <= "$tx" )); then
        echo "TX = $((${tx}/1024/1024)) Mb/s"
elif (( 1024 <= "$tx" )); then
        echo "TX = $((${tx}/1024)) Kb/s"
else
        echo "TX = $((${tx}/1)) bit/s"
fi
