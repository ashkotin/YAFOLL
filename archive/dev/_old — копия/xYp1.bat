@echo off
set p1=%PATH%
rem имена файлов без расширения: OWL2 defc_subst_test deff_subst_test w_test
set FN=deff_subst_test
set PATH=C:\MinGW\bin;C:\Program Files (x86)\PostgreSQL\9.3\lib
echo step-1. Yp_1.
set PATH=%PATH%;C:\Program Files (x86)\PostgreSQL\9.3\lib;C:\gnuwin32\bin;C:\_dlls;C:\LibIntl\bin
Yp_1.exe >%FN%.out.txt
echo step-2. Yp_1 protocol.
set PATH=%p1%
notepad %FN%.out.txt
rem pause