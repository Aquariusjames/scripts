#!/bin/bash 
#统计上一个小时某一段时间http（103）的回填率
min=3           #取30-39分钟的数据
outpath=/root/shell/103_htl.csv

#######################################
riqi=`date +"%F-%H" -d -1hour`
date=`date +"%Y%m%d%H" -d -1hour`
newdate=$date$min
host=`ifconfig|grep Bcast|awk '{print $2}'|awk -F ':' '{print $2}'| head -1`
#echo 通用业务_100,DNS_101,mms_102,http_103,ftp_104,email_105,voip_106,rtsp_107,即时通信_108,P2P_109 >> $(outpath)
#echo Time,IMSI,IMEI,MSISDN,CELLID,TOTAL,TYPE >>  $(outpath)
#echo TIME,IP,IMSI,IMEI,MSISDN,CELLID,TOTAL,IMSI_PER,IMEI_PER,MSISDN_PER,CELLID_PER,TYPE >> $(outpath)
cd /usr/local/DPIDATA/logbak/$date/103_
total=`cat *$newdate*.csv|wc -l`
imsi=`cat *$newdate*.csv|awk -F '|' '{if($6!="") print}'|wc -l`
imei=`cat *$newdate*.csv|awk -F '|' '{if($7!="") print}'|wc -l`
msisdn=`cat *$newdate*.csv|awk -F '|' '{if($8!="") print}'|wc -l`
tac=`cat *$newdate*.csv|awk -F '|' '{if($16!="") print}'|wc -l`
cellid=`cat *$newdate*.csv|awk -F '|' '{if($17!="") print}'|wc -l`

imsi_per=`awk 'BEGIN{printf "%.2f%%\n",('$imsi'/'$total*100')}'`
imei_per=`awk 'BEGIN{printf "%.2f%%\n",('$imei'/'$total*100')}'`
msisdn_per=`awk 'BEGIN{printf "%.2f%%\n",('$msisdn'/'$total*100')}'`
tac_per=`awk 'BEGIN{printf "%.2f%%\n",('$tac'/'$total*100')}'`
cellid_per=`awk 'BEGIN{printf "%.2f%%\n",('$cellid'/'$total*100')}'`

#echo $date,$host,$imsi,$imei,$msisdn,$cellid,$total,$imsi_per,$imei_per,$msisdn_per,$tac_per,$cellid_per,'HTTP_103' >>$(outpath)
echo $riqi $host '$6:'$imsi_per '$7:'$imei_per '$8:'$msisdn_per '$16:'$tac_per '$17:'$cellid_per 'HTTP_103' '总条数:'$total '$6:'$imsi '$7:'$imei '$8:'$msisdn '$16:'$tac '$17:'$cellid >>$(outpath)
