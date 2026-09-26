rem @echo off
set PATH=%PATH%;C:\__IndProgs\gawk
rem а) выдаёт строки с заголовками Си-ф.
gawk "{if(substr($0,1,1)!=\" \" && length($0)!=0 && substr($0,1,1)!=\"}\") print $0;}" YL_db.pgc >YL_db_H_lines.txt
notepad YL_db_H_lines.txt