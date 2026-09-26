@echo off
echo step-1. cYLdbp.
call envVar.bat
call cYLdbp.bat
echo step-2. cc.
set PATH=%CCbin%;%PGroot%\lib
rem -g это дебагить
gcc Yp_1.c -g -o Yp_1.exe -I "%PGroot%\include" -L "%PGroot%\lib" -lecpg
pause