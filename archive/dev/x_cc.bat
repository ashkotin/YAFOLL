@echo off
rem set p1=%PATH%
rem set pn=C_prog_4
rem set pg=C:\Program Files\PostgreSQL\9.2
rem 
rem комилятор cc
rem set PATH=C:\MinGW\bin;C:\PostgreSQL\pg11\lib
rem gcc %pn%.c -o %pn%.exe
rem %pn%.exe
rem 
rem 
rem set PGroot=C:\PostgreSQL\pg11
set CCbin=C:\MinGW\bin
rem set PATH=%CCbin%;%PGroot%\lib
set PATH=%CCbin%;
rem вместо I 
rem set CPATH=%PGroot%\include
rem вместо L
rem set LIBRARY_PATH=%PGroot%\lib
rem gcc --help
rem gcc --version
rem gcc SA_FOLsn.c -o SA_FOLsn.exe -I "%PGroot%\include" -L "%PGroot%\lib" -lecpg 
rem 
gcc LA_FOLsn_CALL.c -o LA_FOLsn_CALL.exe
rem gcc SA_FOLsn.c -o SA_FOLsn.exe -lecpg -llibpg == libpg НЕТ
rem gcc SA_FOLsn.c -Wl,-Bstatic -lecpg -Wl,-Bdynamic -o SA_FOLsn.exe rem --не катит - то же нет ссылок
rem >gcc.out.txt
rem ПУСК set PATH=%p1%;C:\Program Files (x86)\PostgreSQL\9.3\lib
rem SA_FOLsn.exe <test_sigs_terms.fol >SA.out.html
rem notepad SA.out.html
rem
rem FMAS.negative_tests.fol
rem 2>SA.stderr.txt
rem 2>gcc.err.txt
rem 
pause