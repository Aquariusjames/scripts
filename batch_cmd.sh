#!/bin/bash

# 在所有服务器批量执行命令；

#################################
# 网段
NETW_SE=192.168.20
IP_LAST=$(seq 60 69)
PORT=36928
# 命令:多个命令之间用分号.
COMMAND="w;free -g;ls -ld /tmp/"
#################################

for IP in ${IP_LAST}
do
   echo -e "\n \033[36m ${NETW_SE}.$IP \033[0m"
#  ssh -p ${PORT} ${NETW_SE}.$IP "chmod 1777 /tmp/"
   ssh -p ${PORT} ${NETW_SE}.$IP ${COMMAND}
done
[ $? -eq 0 ] && exit 0