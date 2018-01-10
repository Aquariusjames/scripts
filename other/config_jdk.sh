#!/bin/bash

username='root'
prefixIP=192.168.9
postfixIP=`seq 21 24`
javaTarName='jdk-8u121-linux-x64.tar.gz'
javaFolderName="jdk1.8.0_121"
appsHome='/data/spark'
javaHome=$appsHome/$javaFolderName

tar -zxf $javaTarName -C $appsHome
for node in $postfixIP; do
    scp -r $javaHome $username@$prefixIP.$node:$appsHome >/dev/null 2>&1
    ssh -q $username@$prefixIP.$node "
        echo 'export JAVA_HOME=$javaHome' >> /etc/profile
        echo 'export PATH=\$PATH:\$JAVA_HOME/bin' >> /etc/profile
        #初始化环境变量
        export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
        source /etc/profile
    "
    echo "$prefixIP.$node copy jdk done."
done
