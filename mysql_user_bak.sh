#!/bin/bash    
#Function export user privileges    
  
pwd=rootroot  
  expgrants()    
  {  
    mysql -B -u'root' -p${pwd} -N $@ -e "SELECT CONCAT('SHOW GRANTS FOR ''', user, '''@''', host, ''';') AS query FROM mysql.user" | mysql -u'root' -p${pwd} $@ | sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/-- \1 /;/--/{x;p;x;}'  
	}  
expgrants > ./grants.sql
