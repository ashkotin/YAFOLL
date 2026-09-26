@echo off
rem set path=C:\gnuwin32\bin;C:\MinGW\bin;%path%
rem set PATH=C:\Users\Alex\YandexDisk\_Projects\YL\dev;
rem call envVar.bat
rem path=%FBbin%
rem flex --help
rem --outfile=LA_FOLsn.c LA_FOLsn.l
rem chcp 1251
rem LA_sample_a.exe <LA_sample.in.txt >LA_sample.out.txt 
rem start C:\Users\Alex\YandexDisk\_Projects\YL\dev\
rem !input file is alwayis in /yl subdir!
set infile=text.yl
LA_FOLsn_CALL.exe <yl/%infile% >LA_FOLsn_CALL.%infile%.out.txt 2>LA_FOLsn_CALL.%infile%.err.txt
rem notepad LA_sample.out.txt
pause