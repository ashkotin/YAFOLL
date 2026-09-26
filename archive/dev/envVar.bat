@echo off
rem задаёт параметры сессии с PG. см. через админ. на тоши: 5433 - это как раз 9.3, а 5432 - 11.
set PGHOSTADDR=127.0.0.1
set PGPORT=5432
rem !!!приходится держать PGDATABASE в коде!!! set PGDATABASE=YL
set PGUSER=postgres
set PGPASSWORD=postgres
rem задаёт переменные среды разработки и выполнения для тоши.
set PGroot=C:\PostgreSQL\pg11
rem bin flex+bison
set FBbin=C:\gnuwin32\bin
rem указание flex выходного файла!!!
set FLEXo=-oLA_FOLsn.c
rem Си компилятор 
rem set CCbin=C:\MinGW\bin
set CCbin=C:\msys64\usr\bin
rem это можно было и не выносить;-)
set dlls=_dlls
