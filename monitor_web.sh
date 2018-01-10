#!/bin/bash
# LANG=zh_CN.UTF-8
# 检查web网址是否正常访问
# 关于邮箱设置:http://blog.51cto.com/moerjinrong/1966812
########################################################### 
DATE=$(date +'%F %T')
URL="172.16.172.112/RAS_NMG"
MAIL="jinlong.zhao@jado.cn"
# 主题
THEME="内蒙web异常"
# 正文
TEST="${DATE} ${URL} 页面已停止工作，请查看"
#TEST="${URL} interface has stopped running, please check"
LOGS=$(pwd)/log_monitor_web.log
############################################################
export PATH=/bin:/sbin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin
#curl  -s -o /dev/null  ${URL}
/usr/bin/wget --spider --timeout=10 --tries=2 -q ${URL} &> /dev/null

RETURN_VALUE=$?
if [ ${RETURN_VALUE} -gt 0 ]
  then
    echo -e  "${DATE} web stop" >> ${LOGS}
    echo ${TEST} |mail -s ${THEME} ${MAIL} 
else
    echo -e "${DATE} web runing" >> ${LOGS}
fi
