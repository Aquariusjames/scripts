#!/bin/bash
DATE=`date -d -30min '+%Y%m%d%H%M'`

ftp -i -n -v <<!
open 10.101.235.151
user evercdata Ev\$IpM9D
binary 
lcd /data/NC-IDT/mdp6log/028/100
cd /data/glassfish/output/EVERCDATA/028/COMMON
mget LTE_SC_*_100000*_${DATE}*.txt
lcd /data/NC-IDT/mdp6log/028/103
cd /data/glassfish/output/EVERCDATA/028/HTTP
mget LTE_SC_*_103000*_${DATE}*.txt

lcd /data/NC-IDT/mdp6log/0816/100
cd /data/glassfish/output/EVERCDATA/0816/COMMON
mget LTE_SC_*_100000*_${DATE}*.txt
lcd /data/NC-IDT/mdp6log/0816/103
cd /data/glassfish/output/EVERCDATA/0816/HTTP
mget LTE_SC_*_103000*_${DATE}*.txt

lcd /data/NC-IDT/mdp6log/0817/100
cd /data/glassfish/output/EVERCDATA/0817/COMMON
mget LTE_SC_*_100000*_${DATE}*.txt
lcd /data/NC-IDT/mdp6log/0817/103
cd /data/glassfish/output/EVERCDATA/0817/HTTP
mget LTE_SC_*_103000*_${DATE}*.txt

lcd /data/NC-IDT/mdp6log/0818/100
cd /data/glassfish/output/EVERCDATA/0818/COMMON
mget LTE_SC_*_100000*_${DATE}*.txt
lcd /data/NC-IDT/mdp6log/0818/103
cd /data/glassfish/output/EVERCDATA/0818/HTTP
mget LTE_SC_*_103000*_${DATE}*.txt

lcd /data/NC-IDT/mdp6log/0831/100
cd /data/glassfish/output/EVERCDATA/0831/COMMON
mget LTE_SC_*_100000*_${DATE}*.txt
lcd /data/NC-IDT/mdp6log/0831/103
cd /data/glassfish/output/EVERCDATA/0831/HTTP
mget LTE_SC_*_103000*_${DATE}*.txt

lcd /data/NC-IDT/mdp6log/0836/100
cd /data/glassfish/output/EVERCDATA/0836/COMMON
mget LTE_SC_*_100000*_${DATE}*.txt
lcd /data/NC-IDT/mdp6log/0836/103
cd /data/glassfish/output/EVERCDATA/0836/HTTP
mget LTE_SC_*_103000*_${DATE}*.txt

colse
bye
!