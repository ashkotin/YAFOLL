@echo off
rem задаёт параметры сессии с PG. см. через админ. на тоши: 5433 - это как раз 9.3, а 5432 - 9.2.
set PGHOSTADDR=127.0.0.1
set PGPORT=5433
rem !!!приходится держать PGDATABASE в коде!!! set PGDATABASE=YL
set PGUSER=postgres
set PGPASSWORD=postgres
rem задаёт переменные среды разработки и выполнения для тоши.
set PGroot=C:\Program Files (x86)\PostgreSQL\9.3
rem bin flex+bison
set FBbin=C:\gnuwin32\bin
rem указание flex выходного файла!!!
set FLEXo=-oLA_FOLsn.c
rem Си компилятор 
set CCbin=C:\MinGW\bin
rem это можно было и не выносить;-)
set dlls=_dlls
