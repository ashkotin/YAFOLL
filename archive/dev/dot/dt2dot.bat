rem @echo off
rem 
set PATH=%PATH%;C:\Program Files (x86)\PostgreSQL\9.3\bin
psql -p 5433 -d YL -U postgres -F " " --no-align -f dt2dot.sql -t >dt_body_.txt
copy dot_begin.txt+dt_body_.txt+dot_end.txt dt.dot.txt
rem 
pause