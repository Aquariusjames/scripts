#!/bin/bash

##环境变量##
src_path=/home/svn
bak_path=/home/svn/log
bak_name=$bak_path/`date +%Y%m%d%H%M%S`
touch $bak_name

mkdir -p $bak_path

##检查svn版本库是否完整##
echo "verify VPG/VPG3" | tee -a $bak_name
svnadmin verify ${src_path}/VPG/VPG3 2>$bak_name
echo "verify VPG/VPG4" | tee -a $bak_name
svnadmin verify ${src_path}/VPG/VPG4 2>$bak_name
echo "verify VPG/VPG5" | tee -a $bak_name
svnadmin verify ${src_path}/VPG/VPG5 2>$bak_name
echo "verify VPG/VPGCSOURCE" | tee -a $bak_name
svnadmin verify ${src_path}/VPG/VPGCSOURCE 2>$bak_name

echo "verify ASG/ASG3" | tee -a $bak_name
svnadmin verify ${src_path}/ASG/ASG3 2>$bak_name
echo "verify ASG/ASG4" | tee -a $bak_name
svnadmin verify ${src_path}/ASG/ASG4 2>$bak_name
echo "verify ASG/ASG5" | tee -a $bak_name
svnadmin verify ${src_path}/ASG/ASG5 2>$bak_name
echo "verify ASG/ASGBYPASS" | tee -a $bak_name
svnadmin verify ${src_path}/ASG/ASGBYPASS 2>$bak_name
echo "verify ASG/CSOURCE" | tee -a $bak_name
svnadmin verify ${src_path}/ASG/CSOURCE 2>$bak_name
echo "verify ASG/netcommander" | tee -a $bak_name
svnadmin verify ${src_path}/ASG/netcommander 2>$bak_name

echo "verify MDP/MDP3" | tee -a $bak_name
svnadmin verify ${src_path}/MDP/MDP3 2>$bak_name

##验证是否完整，如果不完整则执行第二次同步，
##第二次同步同样不完整则报错。需要人工检查错误并进行备份
y_n=`cat $bak_name | grep -n svnadmin`
if [[ ! -z $y_n ]]
then
    echo "################erro begin print##################"
    echo "$y_n"
    echo "#################erro end print###################"
else
    echo "verify success"
fi

echo "The Detailed Verify Info is located at 192.168.0.156:/home/svn/log/"

exit 0

