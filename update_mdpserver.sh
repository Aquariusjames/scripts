#!/bin/bash
#更新mdp规则库和程序版本

#网卡名称
wangka_1=eth0
wangka_2=eth1

#新旧规则库名称
old_gz=Y_utf-8_V6.0_2_6_20160726173958_policyapp.data
new_gz=Y_utf-8_V6.0_2_8_20160803110700_policyapp.data

#程序版本
version=mdpserver6_13.25_r6.zip
##########################################
#备份mdpserver配置文件(注意网卡名称)
cp -p /opt/DPIAPP/mdpserver6/config/mdp6config_$(wangka_1) /opt/DPIAPP/mdpserver6/config/mdp6config_$(wangka_1)_`date -I`
cp -p /opt/DPIAPP/mdpserver6/config/mdp6config_$(wangka_2) /opt/DPIAPP/mdpserver6/config/mdp6config_$(wangka_2)_`date -I`

#修改规则库
sed -i 's#$(old_gz)#$(new_gz)#g' /opt/DPIAPP/mdpserver6/config/mdp6config_$(wangka_1)
sed -i 's#$(old_gz)#$(new_gz)#g' /opt/DPIAPP/mdpserver6/config/mdp6config_$(wangka_2)

#升级程序（mdpserver6_13.25_r6.zip只更新bin和lib）
mv /opt/DPIAPP/mdpserver6/bin /opt/DPIAPP/mdpserver6/bin_bak`date -I`
mv /opt/DPIAPP/mdpserver6/lib /opt/DPIAPP/mdpserver6/lib_bak`date -I`
unzip /opt/DPIAPP/$(version) -d /opt/DPIAPP/ &
bash /opt/DPIAPP/mdpserver6/stop.sh &

exit 1