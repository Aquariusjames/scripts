#!/bin/bash
ftp -i -n -v <<!
open 210.51.180.216 
user hbuser jado_1301
binary

lcd /usr/local/DPIDATA/20170406zip
cd /home/hbuser/
mput 2017040605.zip

colse
bye
!
