#!/bin/bash

# 从/data/police/data 往 hdfs 上传数据

day_dir=/data/police/data_bak/$(date +%F)
[ ! -d ${day_dir} ] && mkdir -p ${day_dir}

from=/data/police/data
file_list=`ls /data/police/data`
sleep  10

# 把数据移到中转目录
cd $from
mv ${file_list} /data/police/data_puthdfs/

# 自动判断创建 hdfs 上 /input/police/policedata 目录
/data/spark/hadoop-2.7.2/bin/hadoop fs -ls /input/police/policedata > /dev/null
hdfs_dir=`echo $?`
[ $hdfs_dir -gt 0 ] && /data/spark/hadoop-2.7.2/bin/hadoop fs -mkdir /input/police/policedata/

# 上传到hdfs
/data/spark/hadoop-2.7.2/bin/hadoop fs -put /data/police/data_puthdfs/*.dat  /input/police/policedata/    && echo hdfs OK !
mv /data/police/data_puthdfs/*.dat  ${day_dir}

find /data/police/data_bak/ -name "????-??-??"  -type d -atime +30 |xargs rm -rf  
exit 0