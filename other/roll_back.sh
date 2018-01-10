#!/bin/bash
#按照备份前的文件回滚脚本
#By:wangyl
#DATE:2017-08-01
if [ $# -lt 1 ];then
  echo -e "\033[31;1mUsage: rollback.sh u.abc.com\033[0m"
  exit 11
fi

# Update directory
ROOT_DIR=/backup/update/

#Zip file directory
ZIP_TXT=/backup/scripts/log_file/

#Server_IP
SERVER_IP=192.168.1.250::site/

# the update site name
site_name=$1

# update site dirctory
BAK_DIR=$ROOT_DIR

# destnation directory
DEST_DIR=/site/

#Onl_test_backup
ONL_BAK=/backup/onl_backup/

# current version time
CURRENT_TIME=`ls -l $DEST_DIR/$site_name|awk -F "-" {'print $3'}`

echo -e "\033[31;1mCurrent Version time $CURRENT_TIME\033[0m"
echo ""
echo -e "\033[32;1mAll the past versioni\033[0m"
for line in `find $BAK_DIR -type f -name "*.zip"|awk -F "-" {'print $2'}|awk -F "." {'print $1'}|sort -n`;do
  echo $line
done
# choice unpack time
read -p "Please enter your choice:" last_time
# print last time
echo $last_time


#RollBackup_file
for line in $(cat $ZIP_TXT$site_name-$last_time.txt |tail -n +2)
do  
    rsync -azR --delete $ONL_BAK$site_name-$last_time/${line} ${SERVER_IP}
done
echo $site_name-$last_time- RollBackup Is OK! >> $ZIP_TXT/Roll_backup.log

echo -e "done"
