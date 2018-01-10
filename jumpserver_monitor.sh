#!/bin/bash
# */10 * * * * /root/scripts/jumpserver_monitor.sh > /dev/null 2>&1
echo "redis monitor" > /dev/null
ss -tnl | grep 6379
[ $? -gt 0 ] && service redis restart

echo "mysqld monitor" > /dev/null
ss -tnl | grep 3306
[ $? -gt 0 ] && service mysqld status


source /opt/py3/bin/activate

echo "jumpserver monitor" > /dev/null
ss -tnl|grep 8080 
[ $? -gt 0 ] && cd /opt/jumpserver && nohup python /opt/jumpserver/run_server.py &>> nohup.out &

echo "luna monitor" > /dev/null
ss -tnl|grep 5000 
[ $? -gt 0 ] && cd /opt/luna/ && nohup python /opt/luna/run_server.py &>> nohup.out &

echo "coco monitor" > /dev/null
ss -tnl|grep 2222
[ $? -gt 0 ] && cd /opt/coco/ && nohup python /opt/coco/run_server.py &>> nohup.out & 

exit
