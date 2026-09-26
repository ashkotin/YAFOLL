@echo off
rem 9.2, 9.3...סל. ןמנעû...!!!!!!
rem set PATH=%PATH%;C:\Program Files\PostgreSQL\9.2\bin
set PATH=%PATH%;C:\Program Files (x86)\PostgreSQL\9.3\bin
set PGPASSWORD=yu1
rem ÝÒÎ ÂÛÃÐÓÇÊÀ ÈÇ 9.2 pg_dump.exe -U postgres -n public -f YL.dmp.txt YL
rem ?ÃÄÅ-ÒÎ ÂÛÃÐÓÇÊÀ ÈÇ 9.3?
psql -p 5432 -U postgres -d YL -f do.sql -o done.txt
rem טח-םאק? psql -p 5433 -U postgres -n public YL <do.sql 
notepad done.txt
pause