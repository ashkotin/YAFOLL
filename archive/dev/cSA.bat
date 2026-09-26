rem set PATH=C:\GnuWin32\bin
set PATH=%FBbin%
rem D:\minGW\msys\1.0\bin
bison --report=all --report-file=bison.rpt.txt --warnings=all SA_FOLsn.y --output=SA_FOLsn.c
