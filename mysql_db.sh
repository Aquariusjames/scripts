#!/bin/bash
#mysql数据库单个库还原脚本

source /etc/profile
DATE=`date -I`
###########################################
#mysql的用户名和密码
USER=root					
PASSWD=rootroot

#要还原的库名
DB=$1

#备份的数据地址及日志路径
ADDR=/usr/local/mysql_bak/2016-11-25/
LOGS=${ADDR}/logs
############################################

#mysql和mysqldump命令的绝对路径，用which查看；
MYSQL=`which mysql`
MYCMD="`which mysql` -u${USER} -p${PASSWD}"
MYDUMP="`which mysqldump` -u${USER} -p${PASSWD} --default-character-set=utf8"

if [ ! -d "${LOGS}" ]; then
  mkdir -p  "${LOGS}"
fi

echo  -e "\nstart:`date +%Y%m%d_%H:%M:%S` ${DB}"   >>   ${LOGS}/mysql_reduction_time.txt
for table in `ls ${ADDR}/${DB}`
do
	echo   `date +%Y%m%d_%H:%M:%S`  ${DB}  ${table} >>   ${LOGS}/mysql_reduction_time.txt
	${MYCMD}  ${DB} < ${ADDR}/${DB}/${table}  && sleep 1
done
echo  -e "stop :`date +%Y%m%d_%H:%M:%S` ${DB}\n"    >>   ${LOGS}/mysql_reduction_time.txt