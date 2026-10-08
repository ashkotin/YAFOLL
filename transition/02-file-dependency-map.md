# Карта переноса, зависимостей и версий

Основание: статическая инвентаризация `ashkotin/YAFOLL@18dc9687a8b86bb0b5c05ea2d652ddc831f196c8`, **не** результат сборки Windows. Пути относительно корня репозитория. Новая папка `windows-dev/` создаётся **в будущем**, при выполнении инструкции; перенос не выполнен. «Копия» ниже означает сохранение байтов и действующей грамматики; «производная» — заново проверяемый текст, а не `copy` файла архива.

| Старый путь / источник | Новый путь | Тип и назначение | Проверка |
|---|---|---|---|
| `archive/dev/LA_FOLsn.l` | `windows-dev/LA_FOLsn.l` | Копия действующего Flex-сканера; UTF-8-байты, `YYSTYPE`/Bison-токены | Flex создаёт `LA_FOLsn.c`; токены совпадают с `.y` |
| `archive/dev/SA_FOLsn.y` | `windows-dev/SA_FOLsn.y` | Копия GLR-грамматики с действиями и точными `crt_prnt` `rid`; не заменять ANTLR | Bison создаёт `SA_FOLsn.c`, сохраняются `st-3`, `Dcl-4`, `#st`, `_trmRE` |
| `archive/dev/YL_db.pgc` | `windows-dev/YL_db.pgc` | Копия ECPG-функций БД, обработчика Yp и `#include "YL_db__SA_call.c"` | ECPG создаёт `YL_db.c`; соединение идёт к `YL` |
| `archive/dev/YL_db__SA_call_FULL.pgc` | `windows-dev/YL_db__SA_call.pgc` | **Осознанный выбор версии:** переименованная копия полной SQL-реализации SA-call; не одноимённая заглушка | ECPG создаёт `YL_db__SA_call.c`; после SA `dt` непуста |
| `archive/dev/Yp_1.c` | `windows-dev/Yp_1.c` | Копия точки входа Yp1 (`Ypm()`); компилировать рядом с `YL_db.c` | `Yp_1.exe` обрабатывает `Statement/st-3` |
| `archive/PG_backups/YL_empty.dmp.sql` | `windows-dev/db/schema_seed.sql` | **Производная**, не дамп: DDL 8 таблиц/PK/индексы + проверенный `system` (1) и `sinfixes` (9); исключить `dt` (5 архивных строк), owner/obsolete `SET` | В новой БД `dt=dts=entities=0`; SQL восстанавливается с `ON_ERROR_STOP=1` |
| `archive/dev/yl/text.yl`, `archive/dev/yl/нач-онто.yl` (только синтаксический ориентир) | `windows-dev/examples/smoke.yl` | **Новый** минимальный файл: `"smoke"` + LF, UTF-8 без BOM, а не копия исторического теста | Yp0 создаёт `Statement/st-3` и `Statements/#st`; Yp1 добавляет дерево |
| `archive/dev/{cLA,cSA,cYLdbp,cLASA,cYp,xYp}.bat` (только исходная логика) | `windows-dev/scripts/{build,run}.bat` | **Новые** безопасные сценарии из `03-batch-script-improvements.md`; не копировать архивные переменные/локальные пути | Все команды идут из `%~dp0`, ошибки не маскируются |
| Корневая `.gitignore` (ориентир) | `windows-dev/.gitignore` | **Новый** локальный ignore generated C/output/конфигурации без маскирования `Yp_1.c` | `git check-ignore -v` на исходнике и генерате |
| `README.md`, `archive/root.md`, `transition/ANTLR4_transition.md` | `windows-dev/README.md` | **Новая** проверенная инструкция с версиями, ограничениями и ссылками на исторические документы | При переносе не выдавать архивное свидетельство за свежий тест |

## Граф сборки / запуска

```text
Flex: LA_FOLsn.l → LA_FOLsn.c ───────────────┐
Bison: SA_FOLsn.y → SA_FOLsn.c ──────────────┼─ gcc → SA_FOLsn.exe = SA/Yp0
ECPG: FULL.pgc (новое имя SA_call.pgc) ─────┬┘              │
       → YL_db__SA_call.c ───────────────────┤               ↓
ECPG: YL_db.pgc → YL_db.c (#include SA_call.c)┴──── PostgreSQL: dt
                               │                            │
                               └── Yp_1.c → gcc → Yp_1.exe ┘ → dts/entities
```

На практике компилятор разбирает сгенерированный `SA_FOLsn.c` с включёнными `YL_db.c` и `LA_FOLsn.c`; `Yp_1.c` включает `YL_db.c`. Не компилировать каждый из этих трёх generated C как отдельную единицу одновременно — возможны дублирующиеся определения. Исполнитель связывается с `libecpg`; сервер/CLI `psql` — отдельная зависимость. `%glr-parser`, порядок и побочные эффекты дерева оставляются неизменными; ANTLR4-адаптация — отдельный проект.

## Не переносить в `windows-dev/`

| Архивные группы | Почему |
|---|---|
| `archive/dev/{LA_FOLsn.c,SA_FOLsn.c,YL_db.c,YL_db__SA_call.c,lex.yy.c}` и `archive/dev/C/*.c` при наличии первичных `.l/.y/.pgc` | Generated/double-source; `SA_call.c` в архиве — заглушка. `C/` — эксперименты/дубли, не рабочее ядро. |
| `archive/dev/YL_db__SA_call.pgc` | Заглушка; заменяется выбором `_FULL.pgc` под нужным именем. |
| `archive/dev/_old*/`, `archive/dev/{l,y,pgc}/`, `archive/dev/yl/old/`, `*1.0.*` | Исторические срезы; нельзя смешивать грамматику, лексер, SQL и рантайм разных поколений. |
| `archive/dev/{envVar*.bat,x_psql*.bat,x_ecpg.bat,x_cc.bat,cxYp.bat}`, `archive/dev/_old/pgpass.conf`, `archive/PG_backups/x{Import,Export}.bat` | Машинозависимые пути/переменные и возможные учётные данные; ревизовать локально и не публиковать. |
| `archive/dev/_dlls/**`, `*.exe`, `*.obj`, `*.stackdump`, `*.rpt`, `*.out*`, `archive/dev/{html,xml,txt,dot}/` | Исторические двоичные зависимости, протоколы, артефакты и отдельная визуализация; устанавливать согласованные библиотеки заново. |
| `archive/PG_backups/{YL.4.dmp.sql,YL.backup,YL.2.dmp.txt,YL.3.dmp.txt,YL.dmp.txt}` и логи `xI*` | Полные/старые состояния и отчёты: не стартовая схема, могут содержать данные. |
| `archive/PG_backups/{YL.dmp.sql,YL_empty_перед_FIX.dmp.sql}` | Статически совпадают с `YL_empty.dmp.sql`; нет смысла хранить ещё копии. |
| `archive/dev/yl/DBProba_for_test.yl`, `archive/dev/yl/people.yl`, `archive/dev/yl/text.yl` как автоматический smoke | Исторический/объёмный/отладочный вход; `text.yl` содержит лексемы для отрицательной проверки. Оставить в архиве как исследовательский материал. |
| `archive/dev/{do.sql,do-1.sql,testECPG.*,C_prog*,LA_FOLsn_CALL*}`, `archive/dev/dot/*` | Разрушительные SQL и диагностические/побочные инструменты; не нужны для SA/Yp0/Yp1 smoke. |

`archive/YL.doc/YAFOLL.2.0 Описание языка(вар-после-восстан).odt` остаётся в архиве; ведущие `+`-строки — идеи. Для более широкой семантической проверки нужны одобренные автором тесты под **именно этот** код.

## Регистр рисков зависимости

1. **ECPG/Windows:** `ecpg` и `libecpg` не заменяются одним `psql`; сверить битность GCC, клиентских DLL и Postgres (`cYLdbp.bat`, `cLASA.bat`). Старые каталоги 9.2/9.3/pg11 — история, не совместимый комплект по умолчанию.
2. **Dump:** `YL_empty.dmp.sql` содержит `SET default_with_oids = false`, `ALTER ... OWNER TO postgres`, пять `dt`-строк; для новой версии PG и другой роли нужен производный seed. Не считать `YL.4.dmp.sql` чистой схемой.
3. **Стык грамматики/исполнителя:** `Dcl-4` vs `Dcl_prm` в `SA_FOLsn.y` / `YL_db.pgc`; не маскировать этот риск простым комментарием-строкой smoke.
4. **Код выхода/протокол:** `SA_FOLsn.y` вызывает `yyparse()` без обработки результата; ошибка парсера может сосуществовать с `EXIT_SUCCESS`. `Ypm()` выводит XML-подобный протокол, который нужно проверять по содержимому и БД.
5. **Безопасность:** корневая `.gitignore` не защищает от SQL-дампов, конфигураций и generated C. Проверить tracked/untracked вручную до коммита и повторно на чистом клоне.
