@echo off
rem 9.2, 9.3...ñì. ïîðòû...!!!!!!
rem set PATH=%PATH%;C:\Program Files\PostgreSQL\9.2\bin
rem set PG=D:\Program Files\PostgreSQL\9.3\bin;
set PG=C:\PostgreSQL\pg11\bin
set PATH=%PATH%;%PG%
rem ÝÒÎ ÇÀÊÀ×ÊÀ 
psql -p 5432 -U postgres -d YL -f YL_empty.dmp.sql -o xIotput.txt -L xIlog.txt >Iout_log.txt
pause