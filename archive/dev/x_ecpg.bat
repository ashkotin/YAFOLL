echo off
rem call envVar.bat
rem 
set PGroot=C:\PostgreSQL\pg11
rem set PGroot=C:\Program Files (x86)\PostgreSQL\9.3
rem set CCbin=C:\MinGW\bin
rem set CCbin=C:\mingw-w64\i686-8.1.0-posix-dwarf-rt_v6-rev0\mingw32\bin
set CCbin=C:\msys64\usr\bin
set PATH=%PGroot%\bin;%CCbin%
rem вместо I 
set CPATH=%PGroot%\include
rem вместо L set LIBRARY_PATH=%PGroot%\lib ?НЕ СРАБОТАЛ ДЛЯ ecpg И ЕСТЬ В СТРОКЕ gcc!
set PGHOSTADDR=127.0.0.1
set PGPORT=5432
rem !!!приходитс¤ держать PGDATABASE в коде!!! set PGDATABASE=YL
set PGUSER=postgres
set PGPASSWORD=postgres
ecpg -r no_indicator testECPG.pgc
gcc -o testECPG.exe testECPG.c -Wl,-L%PGroot%\lib,-lecpg 
testECPG.exe >testECPG.txt 2>testECPG.err
rem -lecpg
rem ./
rem YL_db.exe >YL_db.out.html
rem notepad YL_db.out.html
rem <id2title.txt title.txt
rem #shk: >cat2title.out
rem #shk: 3>/dev/null 4>nodes_stat.log 2>nodes_stat.err.txt
rem 
pause
