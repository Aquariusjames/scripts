#!/bin/bash
#检测mdpserver是否运行，若停止，立刻启动

d=`date '+%Y%m%d%H%M%S'`

# mdp6 eth0 
ps -ef|grep mdp6config_eth0 | grep -v grep > /dev/null

if [ $? -ne 0 ] ; then
  cd /opt/DPIAPP/mdpserver6
  cmd="mv nohup_eth0.out nohup_eth0.out_${d}"
  echo $cmd >> /opt/DPIAPP/mdpserver6/restart.log
  `$cmd`
  nohup /opt/DPIAPP/mdpserver6/bin/nc-mdp6 -c /opt/DPIAPP/mdpserver6/config/mdp6config_eth0 &> nohup_eth0.out &
fi

# mdp6 eth1 
ps -ef|grep mdp6config_eth1 | grep -v grep > /dev/null

if [ $? -ne 0 ] ; then
  cd /opt/DPIAPP/mdpserver6
  cmd="mv nohup_eth1.out nohup_eth1.out_${d}"
  echo $cmd >> /opt/DPIAPP/mdpserver6/restart.log
  `$cmd`
  nohup /opt/DPIAPP/mdpserver6/bin/nc-mdp6 -c /opt/DPIAPP/mdpserver6/config/mdp6config_eth1 &> nohup_eth1.out &
fi
