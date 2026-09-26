/*шаблон СА
!Чтобы по простому выделить КСГ из шаблона, Си-код обработки правил начинается с \t. да и вообще в отдельной строке!
НО при этом КСГ часть правила не должна начинаться с \t, т.е. отступ пробелами.
+Z:на 12:30 07.11.16 ЭТО НЕ ТАК!!!
Пуск gawk: gawk "{if(substr($0,1,1)!=\"	\") print $0;}" SA_FOLsn.y >SA_FOLsn_woC.txt
Потом забрать правила.
*/
/*Логика действий
1. основная идея - действия лишь(!) строят ДРВ.
2. но ДРВ - EBNF, в котором есть постфиксы "+" и "*" (см. комментарий с EBNF). поэтому нам нужна трансляция этих операторов в БНФ. 
При этом "конфликтность" bison привела к необходимости уже для + прибегнуть к двух вариантам трансляции. 
что усложнило (обобщило;-) нумерацию членов +-правила (иногда они имеют отрицательные номера!).
*/
%{
#define YYSTYPE char* /*тип атрибута дерева - указатель на строку букв (НЕ ПРОХОДИТ: char [255])*/
#define YYMAXDEPTH 500000 /* максимальная глубина стека. по умолчнанию - 10000.*/
#define YYDEBUG 1 /*включение кода трассы*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
FILE *LAout; /*ЛА. файл выдачи. для выделения цепочек слов */
int yylex (void); /*ЛА. объявление*/
int yydebug; /*переменная управления трассой*/
void yyerror (char const *);/*СА. объявление ф-и обработки синт- ошибки. см. её тело в конце.*/
#include "YL_db.c"
%}
/*%define lr.type "ielr" /*для 2.5 тип генерируемых таблиц ielr canonical-lr*/
%glr-parser	/*без него тоже неплохо;-)*/
/*каждая строка token соответствует(?) строке РВ, а %token нескольким!*/
%token QUANT
%token DOT
%token COMMA
%token COLON
%token l_p
%token r_p
%token l_cb
%token r_cb
%token e_m
%token q_m
%token DECLARATION
%token PRIME
%token DEFINITION
%token FINSET
%token FINSEQ
%token FUNC
%token TYPE
%token Id
%token Ide
%token Number
%token String
%token Natural

%start Statements
%%
/*выражения типа*/
type : TYPE /* значение лнт TYPE - один из начальных типов аля String|Number|Natural|Ide*/		{$$=crt_prnt("type","sig_iT",""); crt_up_node("TYPE","",$1,$$,1);};
type : Id /*!!!в ОЯ это правило вместе с DECL!!!*/		{$$=crt_prnt("type","sig_fsP",""); crt_up_node("Id","",$1,$$,1);};
type : FINSET l_p type r_p		 						{$$=crt_prnt("type","sig_fs",""); crt_up_node("FINSET","",$1,$$,1);crt_up_node("l_p","",$2,$$,2);up_node($3,$$,3);crt_up_node("r_p","",$4,$$,4);};
type : FINSEQ l_p types r_p								{$$=crt_prnt("type","sig_fsq",""); crt_up_node("FINSEQ","",$1,$$,1);crt_up_node("l_p","",$2,$$,2);up_node($3,$$,3);crt_up_node("r_p","",$4,$$,4);};
type : FUNC l_p types r_p  /*тип значения - первый!*/	{$$=crt_prnt("type","sig_f",""); crt_up_node("FUNC","",$1,$$,1);crt_up_node("l_p","",$2,$$,2);up_node($3,$$,3);crt_up_node("r_p","",$4,$$,4);};
/*<EBNF>(#types)	types:type+ */
	types : type										{$$=crt_prnt("types","#types",""); up_node($1,$$,1);}
	types : types type									{int chn=get_chn($1); up_node($2,$1,chn+1);$$=$1;};
/*term - the main structure (expression) in YAFOLL*/
term : Id 												{$$=crt_prnt("term","trmi",""); crt_up_node("Id","",$1,$$,1);};
/*(_trmRE) term:Ide|Number|String|Natural. при обработке терма может встретиться правило _trmRE, единственный ребё которого - лнт!*/
	term : Ide 											{$$=crt_prnt("term","_trmRE",""); crt_up_node("Ide","",$1,$$,1);};
	term : Number										{$$=crt_prnt("term","_trmRE",""); crt_up_node("Number","",$1,$$,1);};
	term : String										{$$=crt_prnt("term","_trmRE",""); crt_up_node("String","",$1,$$,1);};
	term : Natural										{$$=crt_prnt("term","_trmRE",""); crt_up_node("Natural","",$1,$$,1);};
term : l_p Id term r_p 	/*prefix function call*/		{$$=crt_prnt("term","trmp",""); crt_up_node("l_p","",$1,$$,1); crt_up_node("Id","",$2,$$,2); up_node($3,$$,3);crt_up_node("r_p","",$4,$$,4);};
term : l_p term Id term r_p	/*infix function call*/		{$$=crt_prnt("term","trmin",""); crt_up_node("l_p","",$1,$$,1);	up_node($2,$$,2);crt_up_node("Id","",$3,$$,3);up_node($4,$$,4);	crt_up_node("r_p","",$5,$$,5);};
term : term l_p TermList r_p /*standard function call*/	{$$=crt_prnt("term","trmf",""); up_node($1,$$,1);crt_up_node("l_p","",$2,$$,2);	up_node($3,$$,3);crt_up_node("r_p","",$4,$$,4);};
term : l_p QUANT Id COLON term term r_p					{$$=crt_prnt("term","trmQ",""); crt_up_node("l_p","",$1,$$,1); crt_up_node("QUANT","",$2,$$,2); crt_up_node("Id","",$3,$$,3); crt_up_node("COLON","",$4,$$,4); up_node($5,$$,5); up_node($6,$$,6); crt_up_node("r_p","",$7,$$,7);};
term : conds term	/*precondition call*/				{$$=crt_prnt("term","trmC",""); up_node($1,$$,1);up_node($2,$$,2);};
conds : l_cb term r_cb 	/*precondition*/ 				{$$=crt_prnt("conds","conds",""); crt_up_node("l_cb","",$1,$$,1); up_node($2,$$,2);crt_up_node("r_cb","",$3,$$,3);};
/*<EBNF>(#trml)	TermList : term* */
	TermList : 											{$$=crt_prnt("TermList","#trml",""); };
	TermList :  term TermList 							{int chn=get_chn($2); up_node($1,$2,-chn-1);$$=$2;}; /*Z:Перестановка ведёт к: 2 конфликта сдвига/вывода!!! Возможно с Id_list либо правилами вывода и можно вводить ","*/
/*<EBNF> (#Id_list_bch)	Id_list_bch : Id_list_b+ */ /*formal parameter list in function definition*/
	Id_list_bch : Id_list_b 							{$$=crt_prnt("Id_list_bch","#Id_list_bch",""); up_node($1,$$,1);};
	Id_list_bch : Id_list_bch Id_list_b 				{int chn=get_chn($1); up_node($2,$1,chn+1);$$=$1;};
Id_list_b : l_p Id_list r_p 							{$$=crt_prnt("Id_list_b","Id_list_b-1",""); crt_up_node("l_p","",$1,$$,1); up_node($2,$$,2); crt_up_node("r_p","",$3,$$,3);	};								
/*Для форм- параметров определений.*/
/*<EBNF> (#Id_list) Id_list : Id* */
	Id_list :  											{$$=crt_prnt("Id_list","#Id_list",""); };/*обработка эпсилон*/
	Id_list :  Id_list Id  								{ int chn=get_chn($1); crt_up_node("Id","",$2,$1,chn+1); $$=$1;}; 
/*<EBNF>(#st)	Statements:Statement+ */
	Statements :  Statement								{$$=crt_prnt("Statements","#st",""); up_node($1,$$,1);}
	Statements : Statements Statement					{int chn=get_chn($1); up_node($2,$1,chn+1);$$=$1;};
Statement : String 										{$$=crt_prnt("Statement","st-3",""); crt_up_node("String","",$1,$$,1);};
Statement : DECLARATION Id type DOT						{$$=crt_prnt("Statement","Dcl-4",""); crt_up_node("DECLARATION","",$1,$$,1);crt_up_node("Id","",$2,$$,2);up_node($3,$$,3);crt_up_node("DOT","",$4,$$,4);};
Statement : DECLARATION Id type Id DOT					{$$=crt_prnt("Statement","Dcl_prmfC",""); crt_up_node("DECLARATION","",$1,$$,1);crt_up_node("Id","",$2,$$,2);up_node($3,$$,3);crt_up_node("Id","",$4,$$,4);crt_up_node("DOT","",$5,$$,5);};
Statement : e_m term Id e_m 							{$$=crt_prnt("Statement","fmca",""); crt_up_node("e_m","",$1,$$,1);up_node($2,$$,2);crt_up_node("Id","",$3,$$,3);crt_up_node("e_m","",$4,$$,4);};
Statement : e_m Id term e_m 							{$$=crt_prnt("Statement","fmcd",""); crt_up_node("e_m","",$1,$$,1);crt_up_node("Id","",$2,$$,2);up_node($3,$$,3); crt_up_node("e_m","",$4,$$,4);};
Statement : e_m Id Natural term e_m 					{$$=crt_prnt("Statement","fmcaq",""); crt_up_node("e_m","",$1,$$,1);crt_up_node("Id","",$2,$$,2);crt_up_node("Natural","",$3,$$,3); up_node($3,$$,4); crt_up_node("e_m","",$5,$$,5);};
Statement : e_m Id Natural e_m      					{$$=crt_prnt("Statement","fmcdq",""); crt_up_node("e_m","",$1,$$,1);crt_up_node("Id","",$2,$$,2);crt_up_node("Natural","",$3,$$,3); crt_up_node("e_m","",$4,$$,4);};
Statement : e_m term COLON term e_m   					{$$=crt_prnt("Statement","fmta",""); crt_up_node("e_m","",$1,$$,1);up_node($2,$$,2);crt_up_node("COLON","",$3,$$,3);up_node($4,$$,4);crt_up_node("e_m","",$5,$$,5);};
Statement : e_m term COLON e_m 							{$$=crt_prnt("Statement","fmtd",""); crt_up_node("e_m","",$1,$$,1);up_node($2,$$,2);crt_up_node("COLON","",$3,$$,3);crt_up_node("e_m","",$4,$$,4);};
Statement : q_m term q_m 								{$$=crt_prnt("Statement","st-11",""); crt_up_node("q_m","",$1,$$,1);up_node($2,$$,2);crt_up_node("q_m","",$3,$$,3);};	
Statement : DECLARATION Id type DEFINITION Id_list_bch COLON term DOT		{$$=crt_prnt("Statement","Dcl-5",""); crt_up_node("DECLARATION","",$1,$$,1);crt_up_node("Id","",$2,$$,2);up_node($3,$$,3);crt_up_node("DEFINITION","",$4,$$,4);up_node($5,$$,5);crt_up_node("COLON","",$6,$$,6); up_node($7,$$,7);crt_up_node("DOT","",$8,$$,8);};
Statement : e_m Natural e_m   							{$$=crt_prnt("Statement","st-6",""); crt_up_node("e_m","",$1,$$,1);crt_up_node("Natural","",$2,$$,2);crt_up_node("e_m","",$3,$$,3);};
Statement : e_m error e_m																	{printf("\n<SA STOP_e_m_Statement_token='%s'>",$2);/*error содержит лексему перед преткновением!!!*/};
Statement : error DOT																		{printf("\n<SA STOP_DOT_Statement_token='%s'>",$1);};
%%
/*ЛА. вставка его Си кода*/
#include "LA_FOLsn.c"
void yyerror (char const *s) {printf ("\n<SA.yyerror msg='Error %s after this token:'>",s);} 
int main (void)
{yydebug = 0; 
 if (connect()!=0) YL_abort("SA. connection failed."); /*printf ("\nSA connected.");*/
 /*чистим ДРВ*/dt_reset(1);/*если не 1 чистки не будет*//*printf ("\nSA. before yyparse.");*/
 /*вызов парсера*/yyparse (); /*printf ("\nSA. after yyparse.");*/
 disconnect(); exit(EXIT_SUCCESS);
}
