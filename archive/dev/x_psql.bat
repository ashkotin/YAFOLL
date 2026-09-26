@echo off
rem 9.2, 9.3...סל. ןמנעû...!!!!!!
rem set PATH=%PATH%;C:\Program Files\PostgreSQL\9.2\bin
rem set PATH=%PATH%;C:\Program Files (x86)\PostgreSQL\9.3\bin
set PGPASSWORD=postgres
rem ÝÒÎ ÂÛÃÐÓÇÊÀ ÈÇ 9.2 pg_dump.exe -U postgres -n public -f YL.dmp.txt YL
rem ÝÒÎ ÂÛÃÐÓÇÊÀ ÈÇ 9.3 
psql -p 5432 -U postgres -n YL <do.sql 
pause