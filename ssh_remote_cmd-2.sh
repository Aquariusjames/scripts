#!/bin/bash

# 此脚本调用脚本函数； 

#DIR="/server/scripts"
DIR=$1			#要分发文件的目录（后不带‘/‘）
. /etc/init.d/functions
[ ! -f ${DIR}/iplists.txt ] && echo "iplists.txt is not exist." && exit 1

for IP in `cat ${DIR}/iplists.txt`
do
  scp  ${DIR}/Y_Time root@$IP:/opt/DPIAPP/mdpserver6/resource/ &>/dev/null 		#Y_Time为要分发的文件；IP：后为要分发到的地址
  scp  ${DIR}/kill——mdp.sh root@$IP:/opt/ &>/dev/null 	#killa.sh为
  ssh root@$IP "/bin/sh /opt/killa.sh"
  if [ $? -eq 0 ];then
   action "$IP" /bin/true
  else
   action "$IP" /bin/false
  fi
done
