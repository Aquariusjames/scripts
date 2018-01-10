#!/bin/bash

# SVN BAKUP

date=$(date +%F)
input=
output=/data/svn_bak
svn_log=/root/scripts/log_svn.log

echo -e '\n'  >>  ${svn_log}


for list in $(cat /root/scripts/list_svn.txt)
do
    /bin/mkdir -p ${output}/$date/${list}  && rm -rf ${output}/$date/${list}/*
    /usr/bin/svnadmin hotcopy ${input}/$list  ${output}/$date/${list} --clean-logs \
    &&  echo  $(date +"%F %T")  $list  OK >> ${svn_log}
    cp -a  ${input}/`dirname ${list}`/*.conf ${output}/$date/`dirname ${list}`/
#    mkdir -p ${output}/tar/$date/${list}
#    tar -zcf ${output}/tar/$date/${list}_${date}.tar.gz ${output}/$date/${list} 
done


# config
cp -a /etc  /${output}/$date/
cp -a /root/script* /${output}/$date/
# cp -a  /ASG/*.conf   ${output}/$date/ASG/
# cp -a  /DPI/*.conf  ${output}/$date/DPI/
# cp -a  /MDP/mdp3accessfile.conf  ${output}/$date/MDP/
# cp -a  /IDP/idpaccessfile.conf  ${output}/$date/IDP/
# cp -a  /LDP/ldpaccessfile.conf  ${output}/$date/LDP/
# cp -a  /NEW/newaccessfile.conf   ${output}/$date/NEW/
# cp -a  /SDP/sdpaccessfile.conf   ${output}/$date/SDP/
# cp -a  /testdb/abcaccessfile.conf   ${output}/$date/testdb/
# cp -a  /VPG/*.conf   ${output}/$date/VPG/
# cp -a  /WDP/wdp3accessfile.conf   ${output}/$date/WDP/

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
