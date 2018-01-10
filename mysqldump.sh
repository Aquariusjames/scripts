#!/bin/bash
# author:long
# mail:898009427@qq.com
# mysql数据库指定库备份脚本

source /etc/profile

############## mysql变量 ##################
DATE=$(date -I)
USER=root
PASSWORD=rootroot
HOST=localhost
PORT=3306
DUMP_PATH=/data/mysql_bak
LOGS=${DUMP_PATH}/log

############## mysqldump备份 ###############
[ -d $LOGS ] ||  mkdir -p $LOGS

#mysql和mysqldump命令的绝对路径，用which查看；
MYSQL_LOGIN="$(which mysql) -P ${PORT} -h ${HOST} -u ${USER} -p${PASSWORD}"
MYSQLDUMP_LOGIN="$(which mysqldump) -P ${PORT} -h ${HOST} -u ${USER} -p${PASSWORD} --default-character-set=utf8 --set-gtid-purged=OFF"

#要备份的库名称;库名用空格分隔；
#DUNP_DATABASE_LIST=(nc_wf nc_wh nc_yd)
#不备份的库
DUNP_DATABASE_LIST=$(${MYSQL_LOGIN} -e "show databases" | egrep -v "Database|information_schema|mysql|nc_cr_app_source|nc_cr_content_meta|performance_schema")

# for DB in ${DUNP_DATABASE_LIST[*]}
for DB in ${DUNP_DATABASE_LIST}
do
  ADDR="${DUMP_PATH}/${DATE}/${DB}" && mkdir -p ${ADDR}
  echo  -e "\nstart:$(date +%Y%m%d_%H:%M:%S) ${DB}"    >>   ${LOGS}/mysql_Backup_time.log

     for table in `$MYSQL_LOGIN -e "show tables from ${DB};" | sed '1d'`
       do
           ${MYSQLDUMP_LOGIN} ${DB} ${table} -R > ${ADDR}/${table}.sql && sleep 1
		   [ "$?" -eq 0 ] &&  echo   $(date +%Y%m%d_%H:%M:%S)  ${DB}  ${table} >>   ${LOGS}/mysql_Backup_time.log
		   [ "$?" -gt 0 ] &&  echo   $(date +%Y%m%d_%H:%M:%S)  ${DB}  ${table} >>   ${LOGS}/mysql_Backup_error.log
       done
  echo  -e "stop :$(date +%Y%m%d_%H:%M:%S) ${DB}\n"    >>   ${LOGS}/mysql_Backup_time.log
done

############# scp ############################
sleep 10  
#把mysql主库每天备份文件往从库传一份
bash /root/script/scp_mysqlbak.sh
exit 0
