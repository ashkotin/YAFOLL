@echo off
rem задаЄт параметры сессии с PG. см. через админ. на тоши: 5433 - это как раз 9.3, а 5432 - 9.2.
set PGHOSTADDR=127.0.0.1
set PGPORT=5433
rem !!!приходитс€ держать PGDATABASE в коде!!! set PGDATABASE=YL
set PGUSER=postgres
set PGPASSWORD=postgres
rem задаЄт переменные среды разработки и выполнени€ дл€ прести.
rem !!!Ќ≈ ѕ–ќ¬≈–яЋќ—№!!!
set PGroot=D:\Program Files\PostgreSQL\9.2
rem bin flex+bison
set FBbin=D:\minGW\msys\1.0\bin
rem указание flex выходного файла!!!
set FLEXo=--outfile=LA_FOLsn.c
rem —и компил€тор 
set CCbin=D:\MinGW\bin
set dlls=_dlls
