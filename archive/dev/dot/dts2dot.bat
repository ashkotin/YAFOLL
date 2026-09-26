rem 
@echo off
rem 
set PATH=%PATH%;C:\Program Files (x86)\PostgreSQL\9.3\bin
rem set APPDATA=%APPDATA%;C:\Users\Alex
rem set PGPASSFILE=C:\__data\_Projects\OWL 2. Операторная семантика - 2\dev\pgpass.conf
psql -p 5433 -d YL -U postgres -F " " --no-align -f dts2dot_2.1.sql -t >dt_body_2.1_.txt
psql -p 5433 -d YL -U postgres -F " " --no-align -f dts2dot_2.2.sql -t >dt_body_2.2_.txt
copy dot_begin.txt+dt_body_2.1_.txt+dt_body_2.2_.txt+dot_end.txt dt.dot
rem 
pause