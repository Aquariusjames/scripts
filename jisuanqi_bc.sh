#!/bin/bash
# author by alsww
# date : 2016.02.03
# mail : alsww@qq.com
# blog : alsww.blog.51cto.com
print_info(){
    printf "请输入数字:\n"
}
print_err_num(){
    printf "请输入正确的数字!\n"
}
print_err_fuhao(){
    printf "请输入正确的运算符号(+ - * /):\n"
}
 
 while :
 do
     read -p "请输入第一个数字:" num1
     echo $num1|grep -q '^[-]\?[0-9]\+$' && break || print_err_num
 done
  
 while :
 do
     read -p "请输入一个运算符（形如 ：+ - * /）:" ysf
     [ "$ysf" != "+" ]&&[ "$ysf" != "-" ]&&[ "$ysf" != "*" ]&&[ "$ysf" != "/" ] && print_err_fuhao || break
 done
 while :
 do
      read -p "请输入第二个数字:" num2
      echo $num2|grep -q '^[-]\?[0-9]\+$' && break || print_err_num
 done
 echo "运算结果为：${num1}${ysf}${num2}=$((${num1}${ysf}${num2})) "
