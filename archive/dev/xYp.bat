@echo off
rem создаёт ДРВ и обрабатывает его относительно леса и сем-таблиц!
rem переменная FN оставлена на всякий случай:-)
rem
rem 
set FN=text
call envVar.bat
rem
echo step-1. text processing (Yp0)
set PATH=%PATH%;%PGroot%\lib;%dlls%
SA_FOLsn.exe <yl/%FN%.yl >%FN%.SA.out.xml 2>%FN%.SA.rpt
echo step-2. DT processing (Yp1)
time /T
rem set PATH=%PATH%;%PGroot%\lib;%dlls%
Yp_1.exe >%FN%.Yp.out.xml
time /T
pause
