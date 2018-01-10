#!/bin/bash

# 从/data/police/data 往 10.201.250.6：/data/police/data 上传数据

from=/data/police/data/
put=/data/police/data/

cd $from
for i in `ls /data/police/data && sleep  20`
do 
/usr/bin/scp -rp  $i root@10.201.250.6:$put
mv $from/$i  `dirname $from`/data_bak
done

find /data/police/data_bak/  -type f  -atime +10 |xargs rm -f
