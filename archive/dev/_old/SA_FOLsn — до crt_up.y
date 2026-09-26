/*шаблон СА
!Чтобы по простому выделить КСГ из шаблона, Си-код обработки правил начинается с \t. да и вообще в отдельной строке!
НО при этом КСГ часть правила не должна начинаться с \t, т.е. отступ проблеами.
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
%token Add
%token to
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
/*<EBNF>Statements:Statement+.*/
Statements :  Statement
				{char* ch0=crt_node("Statements","#st",""); $$=to_buff(ch0,strlen(ch0)+1); up_node($1,$$,1);}
   | Statements Statement
				{int chn=get_chn($1); up_node($2,$1,chn+1);$$=$1;}
;
Statement : String /*Хранимый комментарий:-)*/
					{char* ch0=crt_node("Statement","st-3",""); $$=to_buff(ch0,strlen(ch0)+1);
					 crt_up_node("String","",$1,$$,1);}
   | Declaration
					{char* ch0=crt_node("Statement","st-1",""); $$=to_buff(ch0,strlen(ch0)+1);
					 up_node($1,$$,1);}
   | Proof Id Id derived_formula Dot 
					{char* ch0=crt_node("Statement","st-12",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("Proof","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("Id","",$3); up_node(ch3,$$,3);
					 up_node($4,$$,4); 
					 char* ch5=crt_node("Dot","",$5); up_node(ch5,$$,5);}
   | e_m Ide Id e_m 	/*КМАС. Добавление эл-та Ide в основу Id.*/
					{char* ch0=crt_node("Statement","fmca",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("e_m","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Ide","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("Id","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("e_m","",$4); up_node(ch4,$$,4);}
   | e_m Ide e_m 	/*КМАС. Удаление эл-та Ide из основы.*/
					{char* ch0=crt_node("Statement","fmcd",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("e_m","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Ide","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("e_m","",$3); up_node(ch3,$$,3);}
   | e_m term COLON e_m 	/*КМАС. Удаление значения терма.*/
					{char* ch0=crt_node("Statement","fmtd",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("e_m","",$1); up_node(ch1,$$,1);
					 up_node($2,$$,2); 
					 char* ch3=crt_node("COLON","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("e_m","",$4); up_node(ch4,$$,4);}
   | e_m term COLON term e_m   /*КМАС. Задание значения терма-1 равным term-2.*/
					{char* ch0=crt_node("Statement","fmta",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("e_m","",$1); up_node(ch1,$$,1);
					 up_node($2,$$,2); 
					 char* ch3=crt_node("COLON","",$3); up_node(ch3,$$,3);
					 up_node($4,$$,4); 
					 char* ch5=crt_node("e_m","",$5); up_node(ch5,$$,5);}
   | q_m term q_m 	/*КМАС. Запрос на значение замкнутого терма.*/
					{char* ch0=crt_node("Statement","st-11",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("q_m","",$1); up_node(ch1,$$,1);
					 up_node($2,$$,2);
					 char* ch3=crt_node("q_m","",$3); up_node(ch3,$$,3);}			
   | e_m Number e_m   
					{char* ch0=crt_node("Statement","st-6",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("e_m","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Number","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("e_m","",$3); up_node(ch3,$$,3);}
   | e_m error e_m	{printf("\n<SA STOP_e_m_Statement_token='%s'>",$2);/*error содержит лексему преткновения!!!*/}
   | error Dot	{printf("\n<SA STOP_Dot_Statement_token='%s'>",$1);}
;

/*Объявления*/	  
Declaration :	DECLARATION Id sort Dot 	/*Вводится новый сорт Id.*/
					{char* ch0=crt_node("Declaration","Dcl-1",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("DECLARATION","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("sort","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("Dot","",$4); up_node(ch4,$$,4);}
   | DECLARATION Id sort String Dot			/*Вводится новый сорт Id.*/
					{char* ch0=crt_node("Declaration","Dcl-2",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("DECLARATION","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("sort","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("String","",$4); up_node(ch4,$$,4); 
					 char* ch5=crt_node("Dot","",$5); up_node(ch5,$$,5);}
   | DECLARATION Id sig_f PRIME Dot			/*Вводится новая первичная функция Id*/
					{char* ch0=crt_node("Declaration","Dcl-4",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("DECLARATION","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 up_node($3,$$,3);
					 char* ch4=crt_node("PRIME","",$4); up_node(ch4,$$,4); 
					 char* ch5=crt_node("Dot","",$5); up_node(ch5,$$,5);}
   | DECLARATION Id sig_f PRIME Id Dot			/*Вводится новая первичная функция Id, с приписанной ей Сиф (Id-2)*/
					{char* ch0=crt_node("Declaration","Dcl-6",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("DECLARATION","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 up_node($3,$$,3);
					 char* ch4=crt_node("PRIME","",$4); up_node(ch4,$$,4); 
					 char* ch5=crt_node("Id","",$5); up_node(ch5,$$,5);
					 char* ch6=crt_node("Dot","",$6); up_node(ch6,$$,6);}
					/*Вводится новая вторичная функция Id*/			
	| DECLARATION Id sig_f DEFINITION Id_list_bch COLON term Dot 		/*Функция термом с формальными параметрами из Id_list.*/
					{char* ch0=crt_node("Declaration","Dcl-5",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("DECLARATION","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 up_node($3,$$,3);
								 char* ch4=crt_node("DEFINITION","",$4); up_node(ch4,$$,4);
								 up_node($5,$$,5);
								 char* ch6=crt_node("COLON","",$6); up_node(ch6,$$,6); 
								 up_node($7,$$,7);
								 char* ch8=crt_node("Dot","",$8); up_node(ch8,$$,8);}
;

/***Выведенная формула***/
derived_formula : LA1 l_p term COMMA term r_p 	/*М.65.*/
					{char* ch0=crt_node("derived_formula","LA1",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("LA1","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("l_p","",$2); up_node(ch2,$$,2);
					 up_node($3,$$,3);
					 char* ch4=crt_node("COMMA","",$4); up_node(ch4,$$,4); 
					 up_node($5,$$,5);
					 char* ch6=crt_node("r_p","",$6); up_node(ch6,$$,6);}
   | LA2 l_p term COMMA term COMMA term r_p 	/*М.65.*/
					{char* ch0=crt_node("derived_formula","LA2",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("LA2","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("l_p","",$2); up_node(ch2,$$,2);
					 up_node($3,$$,3);
					 char* ch4=crt_node("COMMA","",$4); up_node(ch4,$$,4); 
					 up_node($5,$$,5);
					 char* ch6=crt_node("COMMA","",$6); up_node(ch6,$$,6);
					 up_node($7,$$,7);
					 char* ch8=crt_node("r_p","",$8); up_node(ch6,$$,8);}					 
   | LA3 l_p term COMMA term r_p 			/*М.66.*/
					{char* ch0=crt_node("derived_formula","LA3",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("LA3","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("l_p","",$2); up_node(ch2,$$,2);
					 up_node($3,$$,3);
					 char* ch4=crt_node("COMMA","",$4); up_node(ch4,$$,4); 
					 up_node($5,$$,5);
					 char* ch6=crt_node("r_p","",$6); up_node(ch6,$$,6);}				
   | LA4 l_p Id COMMA term COMMA term r_p 			/*М.66.*/
					{char* ch0=crt_node("derived_formula","LA4",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("LA4","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("l_p","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("Id","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("COMMA","",$4); up_node(ch4,$$,4); 
					 up_node($5,$$,5);
					 char* ch6=crt_node("COMMA","",$6); up_node(ch6,$$,6);
					 up_node($7,$$,7);
					 char* ch8=crt_node("r_p","",$8); up_node(ch6,$$,8);}					 
   | LA5 l_p Id COMMA term COMMA term r_p 		/*М.66.*/
					{char* ch0=crt_node("derived_formula","LA5",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("LA5","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("l_p","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("Id","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("COMMA","",$4); up_node(ch4,$$,4); 
					 up_node($5,$$,5);
					 char* ch6=crt_node("COMMA","",$6); up_node(ch6,$$,6);
					 up_node($7,$$,7);
					 char* ch8=crt_node("r_p","",$8); up_node(ch6,$$,8);}					 
   | MP l_p derived_formula COMMA derived_formula r_p 		/*М.66.*/
					{char* ch0=crt_node("derived_formula","MP",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("MP","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("l_p","",$2); up_node(ch2,$$,2);
					 up_node($3,$$,3);
					 char* ch4=crt_node("COMMA","",$4); up_node(ch4,$$,4); 
					 up_node($5,$$,5);
					 char* ch6=crt_node("r_p","",$6); up_node(ch6,$$,6);}
   | Gen l_p Id COMMA derived_formula r_p 			/*М.66.*/
					{char* ch0=crt_node("derived_formula","Gen",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("Gen","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("l_p","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("Id","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("COMMA","",$4); up_node(ch4,$$,4); 
					 up_node($5,$$,5);
					 char* ch6=crt_node("r_p","",$6); up_node(ch6,$$,6);}
   | Id 
					{char* ch0=crt_node("derived_formula","derf-8",""); $$=to_buff(ch0,strlen(ch0)+1);
					char* ch1=crt_node("Id","",$1); up_node(ch1,$$,1);}
;
term : Id 
			{char* ch0=crt_node("term","trmi",""); $$=to_buff(ch0,strlen(ch0)+1);
			char* chid=crt_node("Id","",$1);up_node(chid,$$,1);}
   /*(_trmRE) term:Ide|Number|String|Year. при обработке терма может встретиться правило _trmRE, 
    единственный ребё которого - нт - обычно лнт!*/
   | Ide 
			{char* ch0=crt_node("term","_trmRE",""); $$=to_buff(ch0,strlen(ch0)+1);
			char* chid=crt_node("Ide","",$1);up_node(chid,$$,1);}
   | Number
			{char* ch0=crt_node("term","_trmRE",""); $$=to_buff(ch0,strlen(ch0)+1);	
			char* chid=crt_node("Number","",$1);up_node(chid,$$,1);}
   | String
			{char* ch0=crt_node("term","_trmRE",""); $$=to_buff(ch0,strlen(ch0)+1);	
			char* chid=crt_node("String","",$1);up_node(chid,$$,1);}
   | Year
			{char* ch0=crt_node("term","_trmRE",""); $$=to_buff(ch0,strlen(ch0)+1);	
			char* chid=crt_node("Year","",$1);up_node(chid,$$,1);}
   | l_p Id term r_p 	/*префикс*/
			{char* ch0=crt_node("term","trmp",""); $$=to_buff(ch0,strlen(ch0)+1);/*это узел левой части*/
			char* chid=crt_node("l_p","",$1);up_node(chid,$$,1);
				  chid=crt_node("Id","",$2);up_node(chid,$$,2);
			up_node($3,$$,3);
			chid=crt_node("r_p","",$4);up_node(chid,$$,4);}
   | l_p term Id term r_p	/*инфикс*/
			{char* ch0=crt_node("term","trmin",""); $$=to_buff(ch0,strlen(ch0)+1);/*это узел левой части*/
			char* chid=crt_node("l_p","",$1);up_node(chid,$$,1);
			up_node($2,$$,2);
			chid=crt_node("Id","",$3);up_node(chid,$$,3);
			up_node($4,$$,4);
			chid=crt_node("r_p","",$5);up_node(chid,$$,5);}
   | term l_p TermList r_p
			{char* ch0=crt_node("term","trmf",""); $$=to_buff(ch0,strlen(ch0)+1);	
			up_node($1,$$,1);
			char* chid=crt_node("l_p","",$2);up_node(chid,$$,2);
			up_node($3,$$,3);
			chid=crt_node("r_p","",$4);up_node(chid,$$,4);}
   | l_p EXISTS  Id COLON Id term r_p
			{char* ch0=crt_node("term","trme",""); $$=to_buff(ch0,strlen(ch0)+1);
			char* chid=crt_node("l_p","",$1);up_node(chid,$$,1);
				  chid=crt_node("EXISTS","",$2);up_node(chid,$$,2);
				  chid=crt_node("Id","",$3);up_node(chid,$$,3);
				  chid=crt_node("COLON","",$4);up_node(chid,$$,4);
				  chid=crt_node("Id","",$5);up_node(chid,$$,5);
				  up_node($6,$$,6);
				  chid=crt_node("r_p","",$7);up_node(chid,$$,7);}
   | l_p FOR_ANY Id COLON Id term r_p
			{char* ch0=crt_node("term","trma",""); $$=to_buff(ch0,strlen(ch0)+1);
			char* chid=crt_node("l_p","",$1);up_node(chid,$$,1);
				  chid=crt_node("FOR_ANY","",$2);up_node(chid,$$,2);
				  chid=crt_node("Id","",$3);up_node(chid,$$,3);
				  chid=crt_node("COLON","",$4);up_node(chid,$$,4);
				  chid=crt_node("Id","",$5);up_node(chid,$$,5);
				  up_node($6,$$,6);
				  chid=crt_node("r_p","",$7);up_node(chid,$$,7);}
;
/*<EBNF>(#trml)	TermList : term**/
TermList : 
			{char* ch0=crt_node("TermList","#trml",""); $$=to_buff(ch0,strlen(ch0)+1);}
   | TermList_p 
			{$$=$1;}
; 
/*<EBNF>(#trml)	TermList_p : term+*/
TermList_p : term
			{char* ch0=crt_node("TermList","#trml",""); $$=to_buff(ch0,strlen(ch0)+1); up_node($1,$$,-1);}
	/*Z:Перестановка ведёт к: 2 конфликта сдвига/вывода!!! Возможно с Id_list и можно вводить ","*/
   | term TermList_p 
			{int chn=get_chn($2); up_node($1,$2,-chn-1);$$=$2;}
; 

/*Для форм- параметров определений.*/
/*<EBNF> Id_list : Id* */
Id_list :  
				{char* ch0=crt_node("Id_list","#Id_list",""); $$=to_buff(ch0,strlen(ch0)+1);}/*обработка эпсилон*/
 | Id_listp  
				{$$=$1;}
;
/*<EBNF> Id_listp : Id+ */
Id_listp : Id 
				{char* ch0=crt_node("Id_list","#Id_list",""); $$=to_buff(ch0,strlen(ch0)+1);
				 char* ch1=crt_node("Id","",$1); up_node(ch1,$$,1);}
 | Id_listp Id  
				{int chn=get_chn($1); char* ch_n=crt_node("Id","",$2); up_node(ch_n,$1,chn+1);$$=$1;}
;
Id_list_b : l_p Id_list r_p 
							{char* ch0=crt_node("Id_list_b","Id_list_b-1",""); $$=to_buff(ch0,strlen(ch0)+1);
							 char* ch1=crt_node("l_p","",$1); up_node(ch1,$$,1);
							 up_node($2,$$,2);
							 char* ch3=crt_node("r_p","",$3); up_node(ch3,$$,3);
							}
;								
/*<EBNF> Id_list_bch : Id_list_b+*/
Id_list_bch : Id_list_b 
						{char* ch0=crt_node("Id_list_bch","#Id_list_bch",""); $$=to_buff(ch0,strlen(ch0)+1);
						 up_node($1,$$,1);}
 | Id_list_bch Id_list_b 
				{int chn=get_chn($1); up_node($2,$1,chn+1);$$=$1;}
;
/*Синтаксис сигнатур*/
sig_f : sig_arg COLON sig_e 
				{char* ch0=crt_node("sig_f","sig_f",""); $$=to_buff(ch0,strlen(ch0)+1);
				 up_node($1,$$,1);
				 char* ch2=crt_node("COLON","",$2); up_node(ch2,$$,2);
				 up_node($3,$$,3);}
;
sig_e : Id
				{char* ch0=crt_node("sig_e","sig_eI",""); $$=to_buff(ch0,strlen(ch0)+1);
				 char* ch1=crt_node("Id","",$1); up_node(ch1,$$,1);}
   | l_p sig_f r_p 
				{char* ch0=crt_node("sig_e","sig_eF",""); $$=to_buff(ch0,strlen(ch0)+1);
					 char* ch1=crt_node("l_p","",$1); up_node(ch1,$$,1);
					 up_node($2,$$,2);
					 char* ch3=crt_node("r_p","",$3); up_node(ch3,$$,3);}
;
/*<EBNF> sig_arg : sig_e* */
sig_arg :  
				{char* ch0=crt_node("sig_arg","#sig_arg",""); $$=to_buff(ch0,strlen(ch0)+1);}/*обработка эпсилон*/
   |  sig_ep 
				{$$=$1;}
;
/*<EBNF> sig_ep : sig_e+ *//*!!!будучи нацелена на sig_arg* эта группа правил снабжена соответствующими действиями построения частей *-дерева!!!*/
sig_ep : sig_e 
				{char* ch0=crt_node("sig_arg","#sig_arg",""); $$=to_buff(ch0,strlen(ch0)+1);
					 up_node($1,$$,1);}
   |sig_ep  sig_e
				{int chn=get_chn($1); up_node($2,$1,chn+1);$$=$1;}
;

%%
/*ЛА. вставка его Си кода*/
#include "LA_FOLsn.c"
void yyerror (char const *s) {printf ("<SA.yyerror msg='%s before this element!'>",s);}
int main (void)
{yydebug = 0; 
 if (connect()!=0) YL_abort("SA. connection failed."); /*printf ("\nSA connected.");*/
 /*чистим ДРВ*/dt_reset(1);/*если не 1 чистки не будет*//*printf ("\nSA. before yyparse.");*/
 /*вызов парсера*/yyparse (); /*printf ("\nSA. after yyparse.");*/
 disconnect(); exit(EXIT_SUCCESS);
}
