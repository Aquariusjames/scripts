#!/bin/bash

# SVN BAKUP
date=$(date +%F)
input=/data/svn
output=/data/svn_bak
svn_log=/root/scripts/log_svn.log

echo -e '\n'  >>  ${svn_log}


for list in $(ls /data/svn)
do
    [ -e ${output}/$date/${list} ] && mv  ${output}/$date/${list} ${output}/backup/ 
	mkdir -p ${output}/$date/${list}
    /usr/bin/svnadmin hotcopy ${input}/$list  ${output}/$date/${list} --clean-logs \
    &&  echo  $(date +"%F %T")  $list  OK >> ${svn_log}
#    mkdir -p ${output}/tar/$date/${list}
#    tar -zcf ${output}/tar/$date/${list}_${date}.tar.gz ${output}/$date/${list} 
done


# config
cd /${output}/$date/ && tar zcf etc.tar.gz /etc
cd /${output}/$date/ && tar zcf scripts.tar.gz /root/script*

# scp  192.168.1.17
# scp -rp  ${output}/$date  192.168.5.11:/data/svn_bak/
/usr/bin/ssh -t  root@192.168.5.17 "[ ! -d ${output}/$date ] && mkdir -p ${output}/$date"

for name in `ls ${output}/$date`;
do
/usr/bin/scp -rp ${output}/$date/$name 192.168.5.17:${output}/$date/ && echo $(date +"%F %T") $name scp_16 OK! >> ${svn_log}
sleep 10
done

# delect 
find /data/svn_bak  -maxdepth 2 -name "????-??-??" -type d -mtime +10 |xargs rm -rf
