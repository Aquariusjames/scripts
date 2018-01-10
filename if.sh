#!/bin/bash

read -p "Enter your score（0-100）：" GRADE

if [ $GRADE -ge 101 ] || [ $GRADE -le -1 ] ; then

echo "成绩数据错误" && exit 1

elif [ $GRADE -ge 85 ] && [ $GRADE -le 100 ] ; then

echo "$GRADE is 优秀"

elif [ $GRADE -ge 70 ] && [ $GRADE -le 84 ] ; then

echo "$GRADE is 合格"

else

echo "$GRADE is 不及格" 

fi
