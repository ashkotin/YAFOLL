@echo off
rem создаёт ДРВ и обрабатывает его относительно леса и сем-таблиц!
rem набор тестов... в w-документе "YAFOLL. Тесты". переменная оставлена на всякий случай:-)
rem
set FN=text
rem gnw был в начале p2
set gnw=C:\gnuwin32\bin
set p2=C:\_dlls
rem ;C:\LibIntl\bin
set PGl=C:\Program Files (x86)\PostgreSQL\9.3\lib
rem
echo step-1. text processing (Yp0)
set PATH=%PATH%;%PGl%;%p2%
SA_FOLsn.exe <yl/%FN%.yl >%FN%.Yp.out.xml
echo step-2. DT processing (Yp1)
time /T
set MGW=C:\MinGW\bin
rem MGW был в начале MGW ниже
set PATH=%PGl%;%p2%
Yp_1.exe >>%FN%.Yp.out.xml
time /T
pause
