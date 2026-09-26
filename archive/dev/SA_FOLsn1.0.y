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
%token EXISTS
%token FOR_ANY
%token Dot
%token COMMA
%token COLON
%token l_p
%token r_p
%token e_m
%token q_m
%token DECLARATION
%token PRIME
%token sort
%token DEFINITION
%token LA1
%token LA2
%token LA3
%token LA4
%token LA5
%token MP
%token Gen
%token Proof
%token Id
%token Ide
%token Number
%token String
%token Year

%start Statements

%%
/*<EBNF>(#st)	Statements:Statement+.*/
Statements :  Statement				{$$=crt_prnt("Statements","#st",""); up_node($1,$$,1);}
   | Statements Statement				{int chn=get_chn($1); up_node($2,$1,chn+1);$$=$1;}
;
Statement : String /*Хранимый комментарий:-)*/					{$$=crt_prnt("Statement","st-3",""); crt_up_node("String","",$1,$$,1);}
   | Declaration					{$$=crt_prnt("Statement","st-1",""); up_node($1,$$,1);}
   | Proof Id Id derived_formula Dot 					{$$=crt_prnt("Statement","st-12",""); crt_up_node("Proof","",$1,$$,1);crt_up_node("Id","",$2,$$,2);crt_up_node("Id","",$3,$$,3);up_node($4,$$,4);crt_up_node("Dot","",$5,$$,5);}
   | e_m Ide Id e_m 	/*КМАС. Добавление эл-та Ide в основу Id.*/					{$$=crt_prnt("Statement","fmca",""); crt_up_node("e_m","",$1,$$,1);crt_up_node("Ide","",$2,$$,2);crt_up_node("Id","",$3,$$,3);crt_up_node("e_m","",$4,$$,4);}
   | e_m Ide e_m 	/*КМАС. Удаление эл-та Ide из основы.*/					{$$=crt_prnt("Statement","fmcd",""); crt_up_node("e_m","",$1,$$,1);crt_up_node("Ide","",$2,$$,2);crt_up_node("e_m","",$3,$$,3);}
   | e_m term COLON e_m 	/*КМАС. Удаление значения терма.*/					{$$=crt_prnt("Statement","fmtd",""); crt_up_node("e_m","",$1,$$,1);up_node($2,$$,2);crt_up_node("COLON","",$3,$$,3);crt_up_node("e_m","",$4,$$,4);}
   | e_m term COLON term e_m   /*КМАС. Задание значения терма-1 равным term-2.*/					{$$=crt_prnt("Statement","fmta",""); crt_up_node("e_m","",$1,$$,1);up_node($2,$$,2);crt_up_node("COLON","",$3,$$,3);up_node($4,$$,4);crt_up_node("e_m","",$5,$$,5);}
   | q_m term q_m 	/*КМАС. Запрос на значение замкнутого терма.*/					{$$=crt_prnt("Statement","st-11",""); crt_up_node("q_m","",$1,$$,1);up_node($2,$$,2);crt_up_node("q_m","",$3,$$,3);}			
   | e_m Number e_m   					{$$=crt_prnt("Statement","st-6",""); crt_up_node("e_m","",$1,$$,1);crt_up_node("Number","",$2,$$,2);crt_up_node("e_m","",$3,$$,3);}
   | e_m error e_m	{printf("\n<SA STOP_e_m_Statement_token='%s'>",$2);/*error содержит лексему преткновения!!!*/}
   | error Dot	{printf("\n<SA STOP_Dot_Statement_token='%s'>",$1);}
;

/*Объявления*/	  
Declaration : DECLARATION Id sort Dot	/*Вводится новый сорт Id.*/	{$$=crt_prnt("Declaration","Dcl-1",""); crt_up_node("DECLARATION","",$1,$$,1);crt_up_node("Id","",$2,$$,2);crt_up_node("sort","",$3,$$,3); crt_up_node("Dot","",$4,$$,4);}
   | DECLARATION Id sort String Dot	/*Вводится новый сорт Id.*/					{$$=crt_prnt("Declaration","Dcl-2",""); crt_up_node("DECLARATION","",$1,$$,1);crt_up_node("Id","",$2,$$,2);crt_up_node("sort","",$3,$$,3);crt_up_node("String","",$4,$$,4);crt_up_node("Dot","",$5,$$,5);}
   | DECLARATION Id sig_f PRIME Dot	/*Вводится новая первичная функция Id*/					{$$=crt_prnt("Declaration","Dcl-4",""); crt_up_node("DECLARATION","",$1,$$,1);crt_up_node("Id","",$2,$$,2);up_node($3,$$,3);crt_up_node("PRIME","",$4,$$,4);crt_up_node("Dot","",$5,$$,5);}
   | DECLARATION Id sig_f PRIME Id Dot	/*Вводится новая первичная функция Id, с приписанной ей Сиф (Id-2)*/	{$$=crt_prnt("Declaration","Dcl-6",""); crt_up_node("DECLARATION","",$1,$$,1);crt_up_node("Id","",$2,$$,2);up_node($3,$$,3);crt_up_node("PRIME","",$4,$$,4);crt_up_node("Id","",$5,$$,5);crt_up_node("Dot","",$6,$$,6);}
   | DECLARATION Id sig_f DEFINITION Id_list_bch COLON term Dot	/*Функция термом с формальными параметрами из Id_list.*/					{$$=crt_prnt("Declaration","Dcl-5",""); crt_up_node("DECLARATION","",$1,$$,1);crt_up_node("Id","",$2,$$,2);up_node($3,$$,3);crt_up_node("DEFINITION","",$4,$$,4);up_node($5,$$,5);crt_up_node("COLON","",$6,$$,6); up_node($7,$$,7);crt_up_node("Dot","",$8,$$,8);}
;

/***Выведенная формула***/
derived_formula : LA1 l_p term COMMA term r_p 	/*М.65.*/					{$$=crt_prnt("derived_formula","LA1",""); crt_up_node("LA1","",$1,$$,1); crt_up_node("l_p","",$2,$$,2); up_node($3,$$,3); crt_up_node("COMMA","",$4,$$,4); up_node($5,$$,5); crt_up_node("r_p","",$6,$$,6);}
   | LA2 l_p term COMMA term COMMA term r_p 	/*М.65.*/					{$$=crt_prnt("derived_formula","LA2",""); crt_up_node("LA2","",$1,$$,1); crt_up_node("l_p","",$2,$$,2); up_node($3,$$,3); crt_up_node("COMMA","",$4,$$,4); up_node($5,$$,5); crt_up_node("COMMA","",$6,$$,6); up_node($7,$$,7); crt_up_node("r_p","",$8,$$,8);}					 
   | LA3 l_p term COMMA term r_p 			/*М.66.*/					{$$=crt_prnt("derived_formula","LA3",""); crt_up_node("LA3","",$1,$$,1); crt_up_node("l_p","",$2,$$,2);up_node($3,$$,3);crt_up_node("COMMA","",$4,$$,4); up_node($5,$$,5);crt_up_node("r_p","",$6,$$,6);}				
   | LA4 l_p Id COMMA term COMMA term r_p 			/*М.66.*/					{$$=crt_prnt("derived_formula","LA4",""); crt_up_node("LA4","",$1,$$,1); crt_up_node("l_p","",$2,$$,2);crt_up_node("Id","",$3,$$,3);crt_up_node("COMMA","",$4,$$,4); up_node($5,$$,5);crt_up_node("COMMA","",$6,$$,6); up_node($7,$$,7); crt_up_node("r_p","",$8,$$,8);}					 
   | LA5 l_p Id COMMA term COMMA term r_p 		/*М.66.*/					{$$=crt_prnt("derived_formula","LA5",""); crt_up_node("LA5","",$1,$$,1);crt_up_node("l_p","",$2,$$,2);crt_up_node("Id","",$3,$$,3);crt_up_node("COMMA","",$4,$$,4); up_node($5,$$,5); crt_up_node("COMMA","",$6,$$,6); up_node($7,$$,7); crt_up_node("r_p","",$8,$$,8);}					 
   | MP l_p derived_formula COMMA derived_formula r_p 		/*М.66.*/					{$$=crt_prnt("derived_formula","MP",""); crt_up_node("MP","",$1,$$,1); crt_up_node("l_p","",$2,$$,2); up_node($3,$$,3); crt_up_node("COMMA","",$4,$$,4); up_node($5,$$,5); crt_up_node("r_p","",$6,$$,6);}
   | Gen l_p Id COMMA derived_formula r_p 			/*М.66.*/					{$$=crt_prnt("derived_formula","Gen",""); crt_up_node("Gen","",$1,$$,1); crt_up_node("l_p","",$2,$$,2); crt_up_node("Id","",$3,$$,3); crt_up_node("COMMA","",$4,$$,4); up_node($5,$$,5); crt_up_node("r_p","",$6,$$,6);}
   | Id 					{$$=crt_prnt("derived_formula","derf-8","");crt_up_node("Id","",$1,$$,1);}
;
term : Id 			{$$=crt_prnt("term","trmi",""); crt_up_node("Id","",$1,$$,1);};
   /*(_trmRE) term:Ide|Number|String|Year. при обработке терма может встретиться правило _trmRE, единственный ребё которого - лнт!*/
term : Ide 			{$$=crt_prnt("term","_trmRE",""); crt_up_node("Ide","",$1,$$,1);};
term : Number			{$$=crt_prnt("term","_trmRE",""); crt_up_node("Number","",$1,$$,1);};
term : String			{$$=crt_prnt("term","_trmRE",""); crt_up_node("String","",$1,$$,1);};
term : Year			{$$=crt_prnt("term","_trmRE",""); crt_up_node("Year","",$1,$$,1);};
term : l_p Id term r_p 	/*префикс*/			{$$=crt_prnt("term","trmp",""); crt_up_node("l_p","",$1,$$,1); crt_up_node("Id","",$2,$$,2); up_node($3,$$,3);crt_up_node("r_p","",$4,$$,4);};
term : l_p term Id term r_p	/*инфикс*/			{$$=crt_prnt("term","trmin",""); crt_up_node("l_p","",$1,$$,1);	up_node($2,$$,2);crt_up_node("Id","",$3,$$,3);up_node($4,$$,4);	crt_up_node("r_p","",$5,$$,5);};
term : term l_p TermList r_p			{$$=crt_prnt("term","trmf",""); up_node($1,$$,1);crt_up_node("l_p","",$2,$$,2);	up_node($3,$$,3);crt_up_node("r_p","",$4,$$,4);};
term : l_p EXISTS  Id COLON Id term r_p			{$$=crt_prnt("term","trme",""); crt_up_node("l_p","",$1,$$,1); crt_up_node("EXISTS","",$2,$$,2); crt_up_node("Id","",$3,$$,3); crt_up_node("COLON","",$4,$$,4); crt_up_node("Id","",$5,$$,5); up_node($6,$$,6); crt_up_node("r_p","",$7,$$,7);};
term : l_p FOR_ANY Id COLON Id term r_p			{$$=crt_prnt("term","trma",""); crt_up_node("l_p","",$1,$$,1); crt_up_node("FOR_ANY","",$2,$$,2); crt_up_node("Id","",$3,$$,3); crt_up_node("COLON","",$4,$$,4); crt_up_node("Id","",$5,$$,5); up_node($6,$$,6); crt_up_node("r_p","",$7,$$,7);};

/*<EBNF>(#trml)	TermList : term* == epsilon|TermList_p НО строить можно было и напрямую;-) НОНО на ДРВ это не сказывается;-)*/
TermList : 			{$$=crt_prnt("TermList","#trml",""); }
   | TermList_p 			{$$=$1;}
; 
/*<EBNF>()	TermList_p : term+ !!!у вспомогательных правил не проставлен ид!!!*/
TermList_p : term			{$$=crt_prnt("TermList","#trml","");  up_node($1,$$,-1);}
 /*Z:Перестановка ведёт к: 2 конфликта сдвига/вывода!!! Возможно с Id_list либо правилами вывода и можно вводить ","*/
   | term TermList_p 			{int chn=get_chn($2); up_node($1,$2,-chn-1);$$=$2;}
; 

/*Для форм- параметров определений.*/
/*<EBNF> (#Id_list) Id_list : Id* */
Id_list :  				{$$=crt_prnt("Id_list","#Id_list",""); }/*обработка эпсилон*/
 | Id_listp  				{$$=$1;}
;
/*<EBNF> ()	Id_listp : Id+ */
Id_listp : Id 				{$$=crt_prnt("Id_list","#Id_list",""); crt_up_node("Id","",$1,$$,1);}
 | Id_listp Id  				{int chn=get_chn($1); char* ch_n=crt_node("Id","",$2); up_node(ch_n,$1,chn+1);$$=$1;}
;
Id_list_b : l_p Id_list r_p 							{$$=crt_prnt("Id_list_b","Id_list_b-1",""); crt_up_node("l_p","",$1,$$,1); up_node($2,$$,2); crt_up_node("r_p","",$3,$$,3);	}
;								
/*<EBNF> (#Id_list_bch)	Id_list_bch : Id_list_b+*/
Id_list_bch : Id_list_b 						{$$=crt_prnt("Id_list_bch","#Id_list_bch",""); up_node($1,$$,1);}
 | Id_list_bch Id_list_b 				{int chn=get_chn($1); up_node($2,$1,chn+1);$$=$1;}
;
/*Синтаксис сигнатур*/
sig_f : sig_arg COLON sig_e 				{$$=crt_prnt("sig_f","sig_f",""); up_node($1,$$,1); crt_up_node("COLON","",$2,$$,2); up_node($3,$$,3);}
;
sig_e : Id				{$$=crt_prnt("sig_e","sig_eI",""); crt_up_node("Id","",$1,$$,1);}
   | l_p sig_f r_p 				{$$=crt_prnt("sig_e","sig_eF",""); crt_up_node("l_p","",$1,$$,1); up_node($2,$$,2); crt_up_node("r_p","",$3,$$,3);}
;
/*<EBNF> (#sig_arg)	sig_arg : sig_e* */
sig_arg :  				{$$=crt_prnt("sig_arg","#sig_arg",""); }/*обработка эпсилон*/
   |  sig_ep 				{$$=$1;}
;
/*<EBNF> ()	sig_ep : sig_e+ *//*!!!будучи нацелена на sig_arg* эта группа правил снабжена соответствующими действиями построения частей *-дерева!!!*/
sig_ep : sig_e 				{$$=crt_prnt("sig_arg","#sig_arg",""); up_node($1,$$,1);}
   |sig_ep  sig_e				{int chn=get_chn($1); up_node($2,$1,chn+1);$$=$1;}
;

%%
/*ЛА. вставка его Си кода*/
#include "LA_FOLsn.c"
void yyerror (char const *s) {printf ("<SA.yyerror msg='%s before this element!'>",s);}
int main (void)
{yydebug = 0; 
 if (connect()!=0) YL_abort("SA. connection failed."); /*printf ("\nSA connected.");*/
 /*чистим ДРВ*/dt_reset(1);/*если не 1 чистки не будет*//*printf ("\nSA. before yyparse.");*/
  /*ГЛУБОКАЯ ОТЛАДКА - падение delete from IN doc*/
  /*if (doc("0")!=0) printf("\n SA.main doc returns not 0");*/
 /*вызов парсера*/yyparse (); /*printf ("\nSA. after yyparse.");*/
 disconnect(); exit(EXIT_SUCCESS);
}
