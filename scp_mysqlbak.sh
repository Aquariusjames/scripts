#!/bin/bash
#把mysqlu主库的每天备份文件往从库服务器传一份
#####################################
MYSQL_BAK=/data/mysql_bak
[ ! -d $MYSQL_BAK ] && mkdir -p $MYSQL_BAK

LOGS=$MYSQL_BAK/log
[ ! -d $LOGS ] && mkdir -p $LOGS

IP=192.168.20.69
######################################
#记录当天备份文件大小，写到$LOGS/mysql_size.txt文件中
echo -e "\n`date -I`" >> $LOGS/mysql_size.txt
du -sh `date -I`  >> $LOGS/mysql_size.txt
du -sh $MYSQL_BAK/`date -I`/*|awk -F / '{print $1,$5}' >> $LOGS/mysql_size.txt

#进入备份目录；打包压缩当天备份的数据库
cd $MYSQL_BAK &&  tar -zcf `date -I`.tar.gz `date -I`

#传到从库的$MYSQL_BAK目录下
scp -rp `date -I`.tar.gz root@$IP:$MYSQL_BAK

#删除6天前的原备份文件，保留压缩文件
#cd $MYSQL_BAK &&  rm -rf  `date -I`
find $MYSQL_BAK -type d  -name "201*-??-??" -mtime +7|xargs rm -rf
