#!/bin/bash
#percona-xtrabackup全量备份mysql脚本
#############################################
source /etc/porfile

#备份路径
OUTPUT=/usr/local/mysql_bak

#mysql的用户名和密码
USER=root
PASSWD=rootroot

#sock锁路径
SOCK=/var/lib/mysql/mysql.sock

############################################
innobackupex --user=${USER} --password=${PASSWD} ${OUTPUT}/full --slave-info --safe-slave-backup --parallel=4 --safe-slave-backup-timeout=7200 --socket=${SOCK}
