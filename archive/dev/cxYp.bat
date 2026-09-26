@echo off
set p1=%PATH%
echo step-1. cYLdbp.
call cYLdbp.bat
echo step-2. cc.
set PATH=C:\MinGW\bin;C:\Program Files (x86)\PostgreSQL\9.3\lib
cc Yp_1.c -o Yp_1.exe -I "C:\Program Files (x86)\PostgreSQL\9.3\include" -L "C:\Program Files (x86)\PostgreSQL\9.3\lib" -lecpg
echo step-3. Yp_1.
set PATH=%PATH%;C:\Program Files (x86)\PostgreSQL\9.3\lib;C:\gnuwin32\bin;C:\_dlls;C:\LibIntl\bin
Yp_1.exe >Yp_1.out.txt
echo step-4. Yp_1 protocol.
set PATH=%p1%
notepad Yp_1.out.txt
rem pause -pedantic-errors