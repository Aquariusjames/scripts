#!/bin/bash
#percona-xtrabackup第一次增量备份mysql脚本
#############################################
source /etc/porfile

#备份路径（注意与全备份统一）
OUTPUT=/usr/local/mysql_bak

#mysql的用户名和密码
USER=root
PASSWD=rootroot

#sock锁路径
SOCK=/var/lib/mysql/mysql.sock
############################################
LAST_FULL=`ls ${OUTPUT}/full/|tail -n1`

innobackupex --user=${USER} --password=${PASSWD} --incremental --incremental-basedir=${OUTPUT}/full/${LAST_FULL}/  ${OUTPUT}/inc --slave-info --safe-slave-backup --parallel=4 --safe-slave-backup-timeout=7200 --socket=${SOCK} 
