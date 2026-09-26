rem @echo off
set PATH=%PATH%;C:\__IndProgs\gawk
rem пропускает в КСГ строки с Си-кодом действий (они начинаются с \t).
rem gawk "{if(substr($0,1,1)!=\"	\") print $0;}" SA_FOLsn.y >SA_FOLsn_CFG_.txt
rem выдаёт часть до первого tab
gawk "{split($0,array,\"	\"); print array[1];}" SA_FOLsn.y >SA_FOLsn_CFG_.txt
notepad SA_FOLsn_CFG_.txt