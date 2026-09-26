rem @echo off
set p1=%PATH%
call envVar.bat
rem set pg=C:\Program Files\PostgreSQL\9.2
rem 
echo step-1. cLA
call cLA.bat
echo step-2. cSA
call cSA.bat
rem 
echo step-3. cYLdbp
call cYLdbp.bat
rem комилятор cc
echo step-4. cc SA_FOLsn.c
set PATH=%CCbin%;%PGroot%\lib
gcc SA_FOLsn.c -o SA_FOLsn.exe -I "%PGroot%\include" -L "%PGroot%\lib" -lecpg
pause