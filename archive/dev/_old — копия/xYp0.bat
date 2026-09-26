@echo off
rem создаёт ДРВ
rem имена файлов без расширения: initial_theory initial_theory_0 OWL2 defc_subst_test deff_subst_test w_test
rem initial_theory.fol - реальное начало, initial_theory_0.fol - только очистка!!!
rem
set ITH=initial_theory_0
set FN=deff_subst_test
rem
echo step-1. Add initial theory
echo on 
copy fol\%ITH%.fol+fol\%FN%.fol _tmp1.txt
echo off
echo step-2. reset DT. SKIP
rem set PATH=%PATH%;C:\Program Files (x86)\PostgreSQL\9.3\bin
rem psql -p 5433 -d YL -U postgres -f DB_reset.sql
echo step-3. Yp0.
set PATH=%PATH%;C:\Program Files (x86)\PostgreSQL\9.3\lib;C:\gnuwin32\bin;C:\_dlls;C:\LibIntl\bin
SA_FOLsn.exe <_tmp1.txt >%FN%.out.txt
echo step-4. Yp protocol.
notepad %FN%.out.txt
