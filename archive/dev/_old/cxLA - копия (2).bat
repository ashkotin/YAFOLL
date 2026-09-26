rem echo off
set path=C:\gnuwin32\bin;C:\MinGW\bin;%path%
flex <LA_FOLsn_a.l -oLA_FOLsn_a.c
gcc -o LA_FOLsn_a.exe LA_FOLsn_a.c
LA_FOLsn_a.exe <Algor_UTF-8.fol >LA.out.txt 
notepad LA.out.txt
pause