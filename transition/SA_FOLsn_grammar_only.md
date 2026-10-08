# Грамматика YAFOLL: EBNF и идентификаторы альтернатив

> **Исправление (важно для Yp):** ANTLR-метка `#st_3` — только имя альтернативы в дереве разбора. Исходный идентификатор узла исполнителя — строка `"st-3"` во втором аргументе `crt_prnt`. Метку нельзя использовать вместо `rid`. Раньше я не вынес это предупреждение в ответ; изменение было потенциально опасным. Теперь **каждая** языковая альтернатива содержит дословный `rid` рядом с ANTLR-меткой.

Источник: [`archive/dev/SA_FOLsn.y`](https://github.com/ashkotin/YAFOLL/blob/main/archive/dev/SA_FOLsn.y). **Это адаптация к нотации ANTLR4, не дословная транскрипция:** все переименования и отличия записаны в [`ANTLR4_transition.md`](ANTLR4_transition.md). Это исправленная версия извлечения: где в комментарии задано EBNF-правило, оно приведено **вместо** развёртки Bison. В ANTLR4 уникальное имя альтернативы ставится в конце после `#`, например `#fmca`; это не ключевое слово. Сохранены 34 языковые альтернативы, включая пять восстановленных EBNF-правил.

**Точность переноса `rid`.** Утверждение «у каждой альтернативы свой уникальный второй аргумент `crt_prnt`» не буквально выполняется для данного файла: четыре литеральные альтернативы `term` имеют один `rid="_trmRE"`; у вторых (рекурсивных) альтернатив пяти развёрток EBNF вызова `crt_prnt` нет. Поэтому для литералов использованы разные имена `#trmRE_Ide`, `#trmRE_Number`, `#trmRE_String`, `#trmRE_Natural`, а исходный `rid` указан рядом. `#types`, `#trml`, `#Id_list_bch`, `#Id_list`, `#st` в строках `rid` содержат ведущий `#`: его нельзя включить в имя ANTLR-метки; исходное значение оставлено в комментарии. Дефис в `st-3`, `Dcl-4`, `Id_list_b-1`, `st-11`, `Dcl-5`, `st-6` запрещён в имени ANTLR-метки, поэтому там применён `_`; **оригинальный `rid` нигде не заменяется**. Для `conds` метка `#condsNode` устраняет конфликт с именем правила.

**Лексика.** В ANTLR имена токенов записаны прописными буквами: `l_p/r_p/l_cb/r_cb/e_m/q_m → L_P/R_P/L_CB/R_CB/E_M/Q_M`; `Id/Ide/Number/String/Natural → ID/IDE/NUMBER/STRING/NATURAL`. Смысл токенов пока задаётся исходным Flex-лексером, полноценный ANTLR-лексер здесь не перенесён. Объявления `tokens` позволяют обсуждать синтаксис, но этот файл ещё не запускает YAFOLL.

**Восстановление после ошибок.** Две исходные продукции Bison `Statement : e_m error e_m` и `Statement : error DOT` не задают предложений языка, не вызывают `crt_prnt` и не имеют `rid`. Их нельзя буквально переносить в ANTLR: встроенный токен Bison `error` и механизм обработки ошибок ANTLR различны. Они намеренно исключены из `statement`, а не снабжены выдуманными исходными идентификаторами.

```antlr
/*
 * ANTLR4-style parser grammar from archive/dev/SA_FOLsn.y,
 * Git tree 92107c98b8f40388ccec0f17564c600fb8a14528.
 * WARNING: #labels are ANTLR parse-tree names, NOT Yp node IDs (rid).
 * For Yp, use the EXACT string in every crt_prnt rid="..." comment;
 * NEVER infer rid from #label (st-3 != st_3; #types != typesSeq).
 * Five EBNF rules restored from source comments; no semantic actions.
 * Token names adapted to ANTLR uppercase. No lexer/error recovery supplied.
 */
parser grammar YAFOLLSyntax;

tokens {
    QUANT, DOT, COMMA, COLON, L_P, R_P, L_CB, R_CB, E_M, Q_M,
    DECLARATION, PRIME, DEFINITION, FINSET, FINSEQ, FUNC, TYPE,
    ID, IDE, NUMBER, STRING, NATURAL
}

// Source EBNF: types : type+ ; base-case crt_prnt only.
types
    : type+ /* crt_prnt rid="#types" */ #typesSeq
    ;

type
    : TYPE                  /* crt_prnt rid="sig_iT" */  #sig_iT
    | ID                    /* crt_prnt rid="sig_fsP" */ #sig_fsP
    | FINSET L_P type R_P   /* crt_prnt rid="sig_fs" */  #sig_fs
    | FINSEQ L_P types R_P  /* crt_prnt rid="sig_fsq" */ #sig_fsq
    | FUNC L_P types R_P    /* crt_prnt rid="sig_f" */   #sig_f
    ;

term
    : ID                               /* crt_prnt rid="trmi" */   #trmi
    | IDE                              /* crt_prnt rid="_trmRE" */ #trmRE_Ide
    | NUMBER                           /* crt_prnt rid="_trmRE" */ #trmRE_Number
    | STRING                           /* crt_prnt rid="_trmRE" */ #trmRE_String
    | NATURAL                          /* crt_prnt rid="_trmRE" */ #trmRE_Natural
    | L_P ID term R_P                  /* crt_prnt rid="trmp" */   #trmp
    | L_P term ID term R_P             /* crt_prnt rid="trmin" */  #trmin
    | term L_P termList R_P            /* crt_prnt rid="trmf" */   #trmf
    | L_P QUANT ID COLON term term R_P /* crt_prnt rid="trmQ" */   #trmQ
    | conds term                       /* crt_prnt rid="trmC" */   #trmC
    ;

conds
    : L_CB term R_CB /* crt_prnt rid="conds" */ #condsNode
    ;

// Source EBNF: TermList : term* ; base-case crt_prnt only.
termList
    : term* /* crt_prnt rid="#trml" */ #trml
    ;

// Source EBNF: Id_list_bch : Id_list_b+ ; base-case crt_prnt only.
idListBch
    : idListB+ /* crt_prnt rid="#Id_list_bch" */ #idListBchSeq
    ;

idListB
    : L_P idList R_P /* crt_prnt rid="Id_list_b-1" */ #Id_list_b_1
    ;

// Source EBNF: Id_list : Id* ; base-case crt_prnt only.
idList
    : ID* /* crt_prnt rid="#Id_list" */ #idListSeq
    ;

// Source EBNF: Statements : Statement+ ; base-case crt_prnt only.
statements
    : statement+ /* crt_prnt rid="#st" */ #st
    ;

statement
    : STRING                                /* crt_prnt rid="st-3" */     #st_3
    | DECLARATION ID type DOT               /* crt_prnt rid="Dcl-4" */    #Dcl_4
    | DECLARATION ID type ID DOT            /* crt_prnt rid="Dcl_prmfC" */ #Dcl_prmfC
    | E_M term ID E_M                      /* crt_prnt rid="fmca" */     #fmca
    | E_M ID term E_M                      /* crt_prnt rid="fmcd" */     #fmcd
    | E_M ID NATURAL term E_M              /* crt_prnt rid="fmcaq" */    #fmcaq
    | E_M ID NATURAL E_M                   /* crt_prnt rid="fmcdq" */    #fmcdq
    | E_M term COLON term E_M              /* crt_prnt rid="fmta" */     #fmta
    | E_M term COLON E_M                   /* crt_prnt rid="fmtd" */     #fmtd
    | Q_M term Q_M                         /* crt_prnt rid="st-11" */    #st_11
    | DECLARATION ID type DEFINITION idListBch COLON term DOT /* crt_prnt rid="Dcl-5" */ #Dcl_5
    | E_M NATURAL E_M                      /* crt_prnt rid="st-6" */     #st_6
    ;
```
