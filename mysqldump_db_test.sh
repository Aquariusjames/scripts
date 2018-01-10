#!/bin/bash
#mysql数据库单个库备份脚本
source /etc/profile
#################################################
DATE=`date -I`

#mysql用于备份的用户名和密码
USER=root
PASSWD=rootroot

#要备份的库名称及路径
DB=$1
OUTPUT=/usr/local/mysql_bak
LOGS=${OUTPUT}/logs
##################################################
ADDR="${OUTPUT}/${DATE}/${DB}"
[ ! -d "${ADDR}" ] && mkdir -p "${ADDR}"
[ ! -d "${LOGS}" ] && mkdir -p "${LOGS}"

echo  -e "\nstart:`date +%Y%m%d_%H:%M:%S` ${DB}"    >>   ${LOGS}/mysql_Backup_time.txt
#mysql和mysqldump命令的绝对路径，用which查看；
MYDUMP="`which mysqldump` --user=${USER} --password=${PASSWD} --default-character-set=utf8 --set-gtid-purged=OFF"

for table in `$MYCMD -e "show tables from ${DB};" | sed '1d'`
do
	echo   `date +%Y%m%d_%H:%M:%S`  ${DB}  ${table} >>   ${LOGS}/mysql_Backup_time.txt
    $MYDUMP ${DB} ${table} --routines --lock-all-tables > ${ADDR}/${table}.sql 	&& sleep 1		#备份表和函数
   #$MYDUMP ${DB} ${table} -d > ${ADDR}/${table}.sql 			&& sleep 1      #备份表结构
   #$MYDUMP ${DB} ${table} --where 'time>=20170101' > ${ADDR}/${table}.sql && sleep 1  #备份表2017年以后的数据，前提是有time字段
done
echo  -e "stop :`date +%Y%m%d_%H:%M:%S` ${DB}\n"    >>   ${LOGS}/mysql_Backup_time.txt
