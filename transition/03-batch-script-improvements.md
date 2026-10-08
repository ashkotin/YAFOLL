# Адресные улучшения Windows-сценариев (предложения, не патч)

Ниже — **минимальные шаблоны для будущих новых файлов** `windows-dev/scripts/`; они **не записаны в репозиторий и не выполнялись на Windows**. Метка **[И]** — факт из архивного файла, **[W]** — предлагаемое поведение, требующее проверки. Никаких архивных значений `PGPASSWORD` здесь нет.

| Где в архиве | Наблюдение [И] | Минимальное изменение [W] |
|---|---|---|
| `dev/cLA.bat`, `cSA.bat` | `path=%FBbin%`, `set PATH=%FBbin%` затирают поиск остальных утилит; генерация без контроля отказа | Рабочая папка через `%~dp0`, `PATH` дополнять, `flex --outfile=...`, `bison --output=...`; `if errorlevel 1 goto fail` сразу после каждого шага. |
| `dev/cYLdbp.bat` | `set path=%PGroot%\bin`, две ECPG-команды с перенаправлением в отчёт; активный `YL_db__SA_call.pgc` — заглушка | Переключить источник **осознанно** на FULL, в новой папке он назван `YL_db__SA_call.pgc`; генерировать сначала SA-call, затем БД; явные `-o`, проверять оба результата. |
| `dev/cLASA.bat`, `cYp.bat` | `pause`, `PATH` и локальный PG-каталог; компиляция с `-lecpg` | Один `build.bat` с входом `PGROOT`, кавычками `-I/-L`, остановкой на ошибке, без `pause` в автоматическом режиме; битность сверять до запуска. |
| `dev/xYp.bat` | `FN=text` зашит, ввод `<yl/%FN%.yl`, SA stdout/stderr и Yp1 stdout перенаправлены; stderr Yp1 не выделен | `run.bat "examples\smoke.yl" [префикс]`, кавычки, уникальные пути артефактов в игнорируемом `out/`, контроль `errorlevel` **и** содержимого/БД. |
| `dev/envVar*.bat`, `x_psql*.bat`, `PG_backups/xImport.bat` | Локальные настройки, исторические установки и возможные секреты | Не переносить. `PGHOST`/`PGPORT`/`PGUSER` задать вне репо; пароль вводить интерактивно или держать в локальном защищённом pgpass вне клона. Отказ от `set PGPASSWORD=...`. |
| `dev/xYp_DBG.bat`, `x_gawk*.bat`, `dot/*.bat` | Отладка/конверсия необязательны для SA/Yp | Не включать в минимальную цепочку. Добавлять лишь после отдельной проверки нужности/инструментов. |

## Шаблон `windows-dev/scripts/build.bat` [W]

**Ожидает** уже установленные `flex`, `bison`, `ecpg`, `gcc`; `%PGROOT%` должен указывать на PostgreSQL с совместимыми headers/libs. Проверить после первого Windows-запуска имена ECPG-библиотек и DLL. Эти строки следуют из `cLA.bat`, `cSA.bat`, `cYLdbp.bat`, `cLASA.bat`, `cYp.bat`, `SA_FOLsn.y`, `YL_db.pgc` **[И]**, но сама композиция **[W]**.

```bat
@echo off
setlocal EnableExtensions DisableDelayedExpansion
if not defined PGROOT (echo Set PGROOT to PostgreSQL installation directory 1>&2 & exit /b 2)
for %%I in ("%~dp0..") do set "ROOT=%%~fI"
pushd "%ROOT%" || exit /b 2
if not exist "YL_db__SA_call.pgc" (echo Missing FULL SA-call source 1>&2 & goto fail)
set "PATH=%PGROOT%\bin;%PGROOT%\lib;%PATH%"
flex --outfile=LA_FOLsn.c LA_FOLsn.l
if errorlevel 1 goto fail
bison --report=all --report-file=bison.rpt.txt --warnings=all --output=SA_FOLsn.c SA_FOLsn.y
if errorlevel 1 goto fail
ecpg -r no_indicator -o YL_db__SA_call.c YL_db__SA_call.pgc
if errorlevel 1 goto fail
ecpg -r no_indicator -o YL_db.c YL_db.pgc
if errorlevel 1 goto fail
gcc SA_FOLsn.c -o SA_FOLsn.exe -I "%PGROOT%\include" -L "%PGROOT%\lib" -lecpg
if errorlevel 1 goto fail
gcc Yp_1.c -o Yp_1.exe -I "%PGROOT%\include" -L "%PGROOT%\lib" -lecpg
if errorlevel 1 goto fail
popd
exit /b 0
:fail
set "RC=%ERRORLEVEL%"
echo Build failed at errorlevel %RC% 1>&2
popd
if "%RC%"=="0" set "RC=1"
exit /b %RC%
```

**Ограничение:** этот шаблон проверяет коды генерации/компиляции, но не обнаруживает семантическую заглушку, если FULL ошибочно не перенесли. Добавить отдельную проверку содержимого выбранного файла и последующий тест `dt` из `01-windows-setup-guide.md`; не включать этот `.bat` в PR без Windows-проверки. При полном отсутствии `PGROOT` проверка завершается до построения `%PATH%`.

## Шаблон `windows-dev/scripts/run.bat` [W]

Пример предполагает запуск после `build.bat` и создания **отдельной** БД `YL`; `PGROOT` снова задаётся локально и должен указывать на ту же установку. Пути выходов относительны к корню новой папки, а не текущей папке вызвавшего процесса. `mkdir out` создаёт игнорируемую папку. Не принимать произвольный путь к output от недоверенного пользователя без дополнительной валидации.

```bat
@echo off
setlocal EnableExtensions DisableDelayedExpansion
if not defined PGROOT (echo Set PGROOT to PostgreSQL installation directory 1>&2 & exit /b 2)
for %%I in ("%~dp0..") do set "ROOT=%%~fI"
pushd "%ROOT%" || exit /b 2
set "PATH=%PGROOT%\bin;%PGROOT%\lib;%PATH%"
if not exist "out" mkdir "out"
if errorlevel 1 goto fail
set "INPUT=%~1"
if not defined INPUT set "INPUT=examples\smoke.yl"
if not exist "%INPUT%" (echo Missing input: "%INPUT%" 1>&2 & goto fail)
if not exist "SA_FOLsn.exe" (echo Build SA first 1>&2 & goto fail)
if not exist "Yp_1.exe" (echo Build Yp1 first 1>&2 & goto fail)
SA_FOLsn.exe < "%INPUT%" > "out\smoke.SA.out.xml" 2> "out\smoke.SA.rpt"
if errorlevel 1 goto fail
Yp_1.exe > "out\smoke.Yp1.out.xml" 2> "out\smoke.Yp1.err"
if errorlevel 1 goto fail
findstr /C:"st_rid='st-3'" "out\smoke.Yp1.out.xml" >nul
if errorlevel 1 goto fail
findstr /C:"<End " "out\smoke.Yp1.out.xml" >nul
if errorlevel 1 goto fail
popd
exit /b 0
:fail
set "RC=%ERRORLEVEL%"
echo Run failed or expected markers missing 1>&2
popd
if "%RC%"=="0" set "RC=1"
exit /b %RC%
```

**Критическое дополнение к шаблону:** `SA_FOLsn.y` возвращает `EXIT_SUCCESS` даже после `yyparse()` без проверки результата, поэтому даже `run.bat` с проверкой маркеров не заменяет SQL-проверки `dt`/`dts` до и после Yp1 и просмотра `SA.yyerror`, `BAD_BYTE`, `<ABORT>`, `Bad str_rid` в выводе. Провести их по `01-windows-setup-guide.md`, затем, если нужно автоматизировать, добавить `psql -X -v ON_ERROR_STOP=1` с учётными данными **из окружения/ввода**, а не из репозитория. По умолчанию `INPUT` настраивается первым аргументом, но ожидаемые маркеры рассчитаны **именно** на `smoke.yl`: для другого входа критерий проверки следует задать отдельно.

## Минимальный локальный `.gitignore` [W]

```gitignore
/LA_FOLsn.c
/SA_FOLsn.c
/YL_db.c
/YL_db__SA_call.c
/*.exe
/*.o
/*.obj
/*.dll
/*.rpt
/*.err
/*.out.*
/out/
/.env
/pgpass.conf
/*.backup
/*.dmp*
/db/*.backup
/db/*.dmp*
```

Не писать `*.c`: это скроет **первичный** `Yp_1.c`. Не считать ignore средством удаления уже отслеживаемого файла: перед коммитом проверить `git ls-files windows-dev` и содержимое staged изменений без вывода секретов. Если в будущем какие-то дампы действительно понадобятся как тестовые фикстуры, сначала очистить данные, описать происхождение и явно ревизовать исключение.
