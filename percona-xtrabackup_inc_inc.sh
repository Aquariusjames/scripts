#!/bin/bash
#percona-xtrabackup第二次以后增量脚本
################################################
source /etc/porfile

#备份路径（注意与全备份统一）
OUTPUT=/usr/local/mysql_bak

#mysql的用户名和密码
USER=root
PASSWD=rootroot

#sock锁路径
SOCK=/var/lib/mysql/mysql.sock

#最后一次增量备份名称
LAST_INC=`ls ${OUTPUT}/inc/|tail -n1`
################################################
innobackupex --user=${USER} --password=${PASSWD} --incremental --incremental-basedir=${OUTPUT}/inc/${LAST_INC}/  ${OUTPUT}/inc --slave-info --safe-slave-backup --parallel=4 --safe-slave-backup-timeout=7200 --socket=${SOCK}
