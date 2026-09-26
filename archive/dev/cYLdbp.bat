rem 
set path=%PGroot%\bin
ecpg -r no_indicator YL_db.pgc >ecpg.rpt
ecpg -r no_indicator YL_db__SA_call.pgc >>ecpg.rpt
rem pause