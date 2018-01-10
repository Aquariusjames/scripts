#!/bin/sh
DATE=`date -d -1hour '+%Y%m%d%H'`

sftp traffic_sftp@10.207.128.228 <<EOF
lcd /usr/local/NC-CR/data/min
cd /home/traffic/data-processing/traffic_sftp/output_hdfs/hour/
get *${DATE}*.dat
rm *${DATE}*.dat
exit
EOF
