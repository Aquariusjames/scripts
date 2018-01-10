#!/bin/sh
#该脚本为Linux下启动java程序的通用脚本。即可以作为开机自启动service脚本被调用，
#也可以作为启动java程序的独立脚本来使用。
#
#Author: mervin, Date: 2012/12/19
#
#警告!!!：该脚本stop部分使用系统kill命令来强制终止指定的java程序进程。
#在杀死进程前，未作任何条件检查。在某些情况下，如程序正在进行文件或数据库写操作，
#可能会造成数据丢失或数据不完整。如果必须要考虑到这类情况，则需要改写此脚本，
#增加在执行kill命令前的一系列检查。
#
###################################
#环境变量及程序执行参数
#需要根据实际环境以及Java程序名称来修改这些参数
###################################
#JDK所在路径,bin目录所在的要目录
JAVA_HOME=${JAVA_HOME}

#执行程序启动所使用的系统用户，考虑到安全，推荐不使用root帐号
#RUNNING_USER=dpfamily

#Java程序所在的目录（classes的上一级目录）
#APP_HOME=/home/dpfamily/mervin/DBCEsb
APP_HOME=`pwd`

#需要启动的Java主程序（main方法类）
APP_MAINCLASS="cn.jado.logsender.boot.LogSenderStartUp"

#SH_NAME=$0

#最小内存限制
MIN_MEM=512M

#最大内存限制
MAX_MEM=2048M

# get String before '.'
#SH_NAME_NEW=`echo $SH_NAME |awk -F '/' '{print $2}' |awk -F '.' '{print $1}'`

#JMX监控IP
#JMX_HOST=`hostname -i`
#JMX监控端口
#JMX_PORT=4692

#进程ID
#APP_PID=${SH_NAME_NEW}
APP_PID="logsender_1"


#拼凑完整的classpath参数，包括指定lib目录下所有的jar
#CLASSPATH="classes"

#bin目录下的jar
for i in bin/*.jar; do
   CLASSPATH="$CLASSPATH":"$i"
done

#lib目录下的jar
for i in lib/*.jar; do
   CLASSPATH="$CLASSPATH":"$i"
done

#java虚拟机启动参数
#JAVA_OPTS="-Djava.rmi.server.hostname=${JMX_HOST} -Dcom.sun.management.jmxremote.port=${JMX_PORT} -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Xms${MIN_MEM} -Xmx${MAX_MEM}"
JAVA_OPTS="-Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Xms${MIN_MEM} -Xmx${MAX_MEM}"

###################################
#(函数)判断程序是否已启动
#
#说明：
#使用JDK自带的JPS命令及grep命令组合，准确查找pid
#jps 加 l 参数，表示显示java的完整包路径
#使用awk，分割出pid ($1部分)，及Java程序名称($2部分)
###################################
#初始化psid变量（全局）
psid=0

#重写的新方法
checkpid() {
   javaps=`ps -ef | grep "$APP_PID" | grep -v grep`
   if [ -n "$javaps" ]; then
      psid=`echo $javaps | awk '{print $2}'`
   else
      psid=0
   fi
}

###################################
#(函数)启动程序
#
#说明：
#1. 首先调用checkpid函数，刷新$psid全局变量
#2. 如果程序已经启动（$psid不等于0），则提示程序已启动
#3. 如果程序没有被启动，则执行启动命令行
#4. 启动命令执行后，再次调用checkpid函数
#5. 如果步骤4的结果能够确认程序的pid,则打印[OK]，否则打印[Failed]
#注意：echo -n 表示打印字符后，不换行
#注意: "nohup 某命令 >/dev/null 2>&1 &" 的用法
###################################
start() {

   checkpid

   if [ $psid -ne 0 ]; then
      echo "================================"
      echo "warn: $APP_PID already started! (pid=$psid)"
      echo "================================"
   else
      echo "Starting $APP_PID ..."
      JAVA_CMD="$JAVA_HOME/bin/java -Dpid=${APP_PID} -Dhome=${APP_HOME} $JAVA_OPTS -cp $CLASSPATH $APP_MAINCLASS"
      #su - $RUNNING_USER -c "$JAVA_CMD"

      #nohup $JAVA_CMD >/dev/null 2>&1 &
      nohup $JAVA_CMD &

      checkpid

      if [ $psid -ne 0 ]; then
         echo " [OK] (pid=$psid) "
      else
         echo " [Failed]"
      fi
   fi
}

###################################
#(函数)停止程序
#
#说明：
#1. 首先调用checkpid函数，刷新$psid全局变量
#2. 如果程序已经启动（$psid不等于0），则开始执行停止，否则，提示程序未运行
#3. 使用kill -9 pid命令进行强制杀死进程
#4. 执行kill命令行紧接其后，马上查看上一句命令的返回值: $?
#5. 如果步骤4的结果$?等于0,则打印[OK]，否则打印[Failed]
#6. 为了防止java程序被启动多次，这里增加反复检查进程，反复杀死的处理（递归调用stop）。
#注意：echo -n 表示打印字符后，不换行
#注意: 在shell编程中，"$?" 表示上一句命令或者一个函数的返回值
###################################
stop() {
   checkpid

   if [ $psid -ne 0 ]; then
      echo "Stopping $APP_PID ...(pid=$psid) "
      #su - $RUNNING_USER -c "kill -9 $psid"
      kill -9 ${psid}
      if [ $? -eq 0 ]; then
         echo " [OK]"
      else
         echo " [Failed]"
      fi
 
      checkpid
      if [ $psid -ne 0 ]; then
         stop
      fi
   else
      echo "================================"
      echo "warn: $APP_PID is not running"
      echo "================================"
   fi
}

###################################
#(函数)检查程序运行状态
#
#说明：
#1. 首先调用checkpid函数，刷新$psid全局变量
#2. 如果程序已经启动（$psid不等于0），则提示正在运行并表示出pid
#3. 否则，提示程序未运行
###################################
status() {
   checkpid

   if [ $psid -ne 0 ];  then
      echo "================================"
      echo "$APP_PID is running! (pid=$psid)"
      echo "================================"
   else
      echo "================================"
      echo "$APP_PID is not running"
      echo "================================"
   fi
}

###################################
#(函数)打印系统环境参数
###################################
info() {
   echo "System Information:"
   echo "****************************"
   echo `head -n 1 /etc/issue`
   echo `uname -a`
   echo
   echo "JAVA_HOME=$JAVA_HOME"
   echo `$JAVA_HOME/bin/java -version`
   echo
   echo "APP_HOME=${APP_HOME}"
   #echo "SH_NAME=${SH_NAME}"
   echo "APP_PID=${APP_PID}"
   echo "JMX_HOST=${JMX_HOST}"
   echo "JMX_PORT=${JMX_PORT}"
   echo "****************************"
}

###################################
#读取脚本的第一个参数($1)，进行判断
#参数取值范围：{start|stop|restart|status|info}
#如参数不在指定范围之内，则打印帮助信息
###################################
case "$1" in
   'start')
      start
      ;;
   'stop')
     stop
     ;;
   'restart')
     stop
     start
     ;;
   'status')
     status
     ;;
   'info')
     info
     ;;
  *)
     echo "Usage: $0 {start|stop|restart|status|info}"
     exit 1
     ;;
esac
