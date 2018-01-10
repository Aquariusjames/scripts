#!/bin/bash

# java 进程监控
####################################
curTime=`date +%Y%m%d-%H:%M`
count=1
java_start_path=/root/tomcat_test/bin
java_start_pro=./startup.sh
java_process=/root/tomcat_test/conf/logging.properties

log_path=/root/script/monitor.log
nums=$(ps -ef | grep -E ${java_process} | grep -v grep | awk '{print $2}'|wc -l);

###################################
if [ $nums -lt $count ]; then
   #  cd ${java_start_path} &&  nohup ${java_start_pro} &  
    cd ${java_start_path} &&  bash /root/tomcat_test/bin/startup.sh
    
    echo $curTime "重启服务" ${java_process}  >> ${log_path}
fi
