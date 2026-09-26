/*шаблон СА
!Чтобы выделить по простому из шаблона КСГ Си-код обработки правил начинается с \t. 
Пуск gawk: gawk "{if(substr($0,1,1)!=\"	\") print $0;}" SA_FOLsn.y >SA_FOLsn_woC.txt
Потом забрать правила.
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
/*динамический (кучный;-) буфер значения атрибута-строки*/
YYSTYPE to_buff(char* in) {char* str_buff=malloc(256); strcpy(str_buff,in); return (str_buff);}
#include "YL_db.c"
%}
/*%define lr.type "ielr" /*для 2.5 тип генерируемых таблиц ielr canonical-lr*/
%glr-parser	/*без него тоже неплохо;-)*/
/*каждая строка token соответствую строке РВ, а %token нескольким!*/
%token INFIX
%token EXISTS
%token FOR_ANY
/*%token NOT
%token AND
%token OR
%token IMPLIES
%token EQUIV
%token Neq
%token Leq
%token Geq
%token WS
%token eq */
%token Dot
%token COMMA
%token COLON
%token l_p
%token r_p
%token e_m
%token q_m
/*%token Plus
%token Minus
%token Multiply*/
/*%token EXISTS
%token FOR_ANY
%token NOT
%token AND
%token OR
%token IMPLIES
%token EQUIV
%token Neq*/
%token DECLARATION
%token PRIME
%token infix
%token Add
%token to
%token sort
%token constant
/*%token function*/
%token Axiom
%token DEFINITION
%token LA1
%token LA2
%token LA3
%token LA4
%token LA5
%token MP
%token Gen
%token Proof
%token Theorem
%token Id
%token Ide
%token Number
%token String
/*%token WS*/
/*%token Comm*/

%start Statements

%%
/*<EBNF>Statements:Statement+.*/
Statements :  Statement
				{$$=to_buff(crt_node("Statements","#st","")); up_node($1,$$,1);}
   | Statements Statement
				{int chn=get_chn($1); up_node($2,$1,chn+1);$$=$1;}
;
Statement : String /*Хранимый комментарий:-)*/
					{$$=to_buff(crt_node("Statement","st-3",""));
					 char* ch=crt_node("String","",$1); up_node(ch,$$,1);}
   | Add infix String to Id Dot 
					{$$=to_buff(crt_node("Statement","st-4",""));
					 char* ch1=crt_node("Add","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("infix","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("String","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("to","",$4); up_node(ch4,$$,4); 
					 char* ch5=crt_node("Id","",$5); up_node(ch5,$$,5); 
					 char* ch6=crt_node("Dot","",$6); up_node(ch6,$$,6);}
   | Declaration
					{$$=to_buff(crt_node("Statement","st-1",""));
					 up_node($1,$$,1);}
   | Definition
					{$$=to_buff(crt_node("Statement","st-2",""));
					 up_node($1,$$,1);}
   | Axiom Id term Dot 
					{$$=to_buff(crt_node("Statement","st-5",""));
					 char* ch1=crt_node("Axiom","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 up_node($3,$$,3);
					 char* ch4=crt_node("Dot","",$4); up_node(ch4,$$,4);} 
   | Theorem Id term Dot 
					{$$=to_buff(crt_node("Statement","st-13",""));
					 char* ch1=crt_node("Theorem","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 up_node($3,$$,3); 
					 char* ch4=crt_node("Dot","",$4); up_node(ch4,$$,4);}
   | Proof Id Id derived_formula Dot 
					{$$=to_buff(crt_node("Statement","st-12",""));
					 char* ch1=crt_node("Proof","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("Id","",$3); up_node(ch3,$$,3);
					 up_node($4,$$,4); 
					 char* ch5=crt_node("Dot","",$5); up_node(ch5,$$,5);}
   | e_m Id Id e_m 	/*КМАС. Добавление эл-та Id-1 в основу Id-2.*/
					{$$=to_buff(crt_node("Statement","fmca",""));
					 char* ch1=crt_node("e_m","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("Id","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("e_m","",$4); up_node(ch4,$$,4);}
   | e_m Id e_m 	/*КМАС. Удаление эл-та Id из основы.*/
					{$$=to_buff(crt_node("Statement","fmcd",""));
					 char* ch1=crt_node("e_m","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("e_m","",$3); up_node(ch3,$$,3);}
   | e_m term COLON e_m 	/*КМАС. Удаление значения терма.*/
					{$$=to_buff(crt_node("Statement","fmtd",""));
					 char* ch1=crt_node("e_m","",$1); up_node(ch1,$$,1);
					 up_node($2,$$,2); 
					 char* ch3=crt_node("COLON","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("e_m","",$4); up_node(ch4,$$,4);}
   | e_m term COLON term e_m   /*КМАС. Задание значения терма-1 равным term-2.*/
					{$$=to_buff(crt_node("Statement","fmta",""));
					 char* ch1=crt_node("e_m","",$1); up_node(ch1,$$,1);
					 up_node($2,$$,2); 
					 char* ch3=crt_node("COLON","",$3); up_node(ch3,$$,3);
					 up_node($4,$$,4); 
					 char* ch5=crt_node("e_m","",$5); up_node(ch5,$$,5);}
   | q_m term q_m 	/*КМАС. Запрос на значение замкнутого терма.*/
					{$$=to_buff(crt_node("Statement","st-11",""));
					 char* ch1=crt_node("q_m","",$1); up_node(ch1,$$,1);
					 up_node($2,$$,2);
					 char* ch3=crt_node("q_m","",$3); up_node(ch3,$$,3);}			
   | e_m Number e_m   
					{$$=to_buff(crt_node("Statement","st-6",""));
					 char* ch1=crt_node("e_m","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Number","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("e_m","",$3); up_node(ch3,$$,3);}
   | e_m error e_m	{printf("\n<SA BAD_e_m_Statement_token='%s'>",$2);/*error содержит лексему преткновения!!!*/}
   | error Dot	{printf("\n<SA BAD_Dot_Statement_token='%s'>",$1);}
;

/*Объявления*/	  
Declaration :	DECLARATION Id sort Dot 	/*Вводится новый сорт Id.*/
					{$$=to_buff(crt_node("Declaration","Dcl-1",""));
					 char* ch1=crt_node("DECLARATION","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("sort","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("Dot","",$4); up_node(ch4,$$,4);}
   | DECLARATION Id sort String Dot			/*Вводится новый сорт Id.*/
					{$$=to_buff(crt_node("Declaration","Dcl-2",""));
					 char* ch1=crt_node("DECLARATION","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("sort","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("String","",$4); up_node(ch4,$$,4); 
					 char* ch5=crt_node("Dot","",$5); up_node(ch5,$$,5);}
   | DECLARATION Id COLON Id constant Dot	/*Вводится новая константа Id-1 сорта Id-2.*/
					{$$=to_buff(crt_node("Declaration","Dcl-3",""));
					 char* ch1=crt_node("DECLARATION","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("COLON","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("Id","",$4); up_node(ch4,$$,4); 
					 char* ch5=crt_node("constant","",$5); up_node(ch5,$$,5);
					 char* ch6=crt_node("Dot","",$6); up_node(ch6,$$,6);}
   | DECLARATION Id sig_f PRIME Dot			/*Вводится новая первичная функция Id */
					{$$=to_buff(crt_node("Declaration","Dcl-4",""));
					 char* ch1=crt_node("DECLARATION","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 up_node($3,$$,3);
					 char* ch4=crt_node("PRIME","",$4); up_node(ch4,$$,4); 
					 char* ch5=crt_node("Dot","",$5); up_node(ch5,$$,5);}
   | DECLARATION Id sig_f PRIME Id Dot			/*Вводится новая первичная функция Id с приписанной ей Сиф (Id-2)*/
					{$$=to_buff(crt_node("Declaration","Dcl-6",""));
					 char* ch1=crt_node("DECLARATION","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 up_node($3,$$,3);
					 char* ch4=crt_node("PRIME","",$4); up_node(ch4,$$,4); 
					 char* ch5=crt_node("Id","",$5); up_node(ch5,$$,5);
					 char* ch6=crt_node("Dot","",$6); up_node(ch6,$$,6);}
   | DECLARATION Id sig_f Dot				/*Вводится новая вторичная функция Id */			
					{$$=to_buff(crt_node("Declaration","Dcl-5",""));
					 char* ch1=crt_node("DECLARATION","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 up_node($3,$$,3);
					 char* ch4=crt_node("Dot","",$4); up_node(ch4,$$,4);}
;

/***Определения***/
Definition : DEFINITION Id Id constant term Dot 
					{$$=to_buff(crt_node("Definition","Def-1",""));
					 char* ch1=crt_node("DEFINITION","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("Id","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("Id","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("constant","",$4); up_node(ch4,$$,4); 
					 up_node($5,$$,5);
					 char* ch6=crt_node("Dot","",$6); up_node(ch6,$$,6);}
   | DEFINITION Id Id Id_list_bch COLON term Dot 		/*Функция термом с формальными параметрами из Id_list.*/
								{$$=to_buff(crt_node("Definition","Def-2",""));
								 char* ch1=crt_node("DEFINITION","",$1); up_node(ch1,$$,1);
								 char* chid=crt_node("Id","",$2);up_node(chid,$$,2);
								 chid=crt_node("Id","",$3);up_node(chid,$$,3);
								 up_node($4,$$,4);
								 char* ch5=crt_node("COLON","",$5); up_node(ch5,$$,5); 
								 up_node($6,$$,6);
								 char* ch7=crt_node("Dot","",$7); up_node(ch7,$$,7);}
;

/***Выведенная формула***/
derived_formula : LA1 l_p term COMMA term r_p 	/*М.65.*/
					{$$=to_buff(crt_node("derived_formula","LA1",""));
					 char* ch1=crt_node("LA1","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("l_p","",$2); up_node(ch2,$$,2);
					 up_node($3,$$,3);
					 char* ch4=crt_node("COMMA","",$4); up_node(ch4,$$,4); 
					 up_node($5,$$,5);
					 char* ch6=crt_node("r_p","",$6); up_node(ch6,$$,6);}
   | LA2 l_p term COMMA term COMMA term r_p 	/*М.65.*/
					{$$=to_buff(crt_node("derived_formula","LA2",""));
					 char* ch1=crt_node("LA2","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("l_p","",$2); up_node(ch2,$$,2);
					 up_node($3,$$,3);
					 char* ch4=crt_node("COMMA","",$4); up_node(ch4,$$,4); 
					 up_node($5,$$,5);
					 char* ch6=crt_node("COMMA","",$6); up_node(ch6,$$,6);
					 up_node($7,$$,7);
					 char* ch8=crt_node("r_p","",$8); up_node(ch6,$$,8);}					 
   | LA3 l_p term COMMA term r_p 			/*М.66.*/
					{$$=to_buff(crt_node("derived_formula","LA3",""));
					 char* ch1=crt_node("LA3","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("l_p","",$2); up_node(ch2,$$,2);
					 up_node($3,$$,3);
					 char* ch4=crt_node("COMMA","",$4); up_node(ch4,$$,4); 
					 up_node($5,$$,5);
					 char* ch6=crt_node("r_p","",$6); up_node(ch6,$$,6);}				
    | LA4 l_p Id COMMA term COMMA term r_p 			/*М.66.*/
					{$$=to_buff(crt_node("derived_formula","LA4",""));
					 char* ch1=crt_node("LA4","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("l_p","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("Id","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("COMMA","",$4); up_node(ch4,$$,4); 
					 up_node($5,$$,5);
					 char* ch6=crt_node("COMMA","",$6); up_node(ch6,$$,6);
					 up_node($7,$$,7);
					 char* ch8=crt_node("r_p","",$8); up_node(ch6,$$,8);}					 
    | LA5 l_p Id COMMA term COMMA term r_p 		/*М.66.*/
					{$$=to_buff(crt_node("derived_formula","LA5",""));
					 char* ch1=crt_node("LA5","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("l_p","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("Id","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("COMMA","",$4); up_node(ch4,$$,4); 
					 up_node($5,$$,5);
					 char* ch6=crt_node("COMMA","",$6); up_node(ch6,$$,6);
					 up_node($7,$$,7);
					 char* ch8=crt_node("r_p","",$8); up_node(ch6,$$,8);}					 
    | MP l_p derived_formula COMMA derived_formula r_p 		/*М.66.*/
					{$$=to_buff(crt_node("derived_formula","MP",""));
					 char* ch1=crt_node("MP","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("l_p","",$2); up_node(ch2,$$,2);
					 up_node($3,$$,3);
					 char* ch4=crt_node("COMMA","",$4); up_node(ch4,$$,4); 
					 up_node($5,$$,5);
					 char* ch6=crt_node("r_p","",$6); up_node(ch6,$$,6);}
    | Gen l_p Id COMMA derived_formula r_p 			/*М.66.*/
					{$$=to_buff(crt_node("derived_formula","Gen",""));
					 char* ch1=crt_node("Gen","",$1); up_node(ch1,$$,1);
					 char* ch2=crt_node("l_p","",$2); up_node(ch2,$$,2);
					 char* ch3=crt_node("Id","",$3); up_node(ch3,$$,3);
					 char* ch4=crt_node("COMMA","",$4); up_node(ch4,$$,4); 
					 up_node($5,$$,5);
					 char* ch6=crt_node("r_p","",$6); up_node(ch6,$$,6);}
    | Id 
					{$$=to_buff(crt_node("derived_formula","derf-8",""));
					char* ch1=crt_node("Id","",$1); up_node(ch1,$$,1);}
;
term : Id 
			{$$=to_buff(crt_node("term","trmi",""));
			char* chid=crt_node("Id","",$1);up_node(chid,$$,1);}
   | Number
			{$$=to_buff(crt_node("term","trmn",""));	
			char* chid=crt_node("Number","",$1);up_node(chid,$$,1);}
   | String
			{$$=to_buff(crt_node("term","trms",""));	
			char* chid=crt_node("String","",$1);up_node(chid,$$,1);}
   | l_p INFIX term r_p 	/*префикс*/
			{$$=to_buff(crt_node("term","trmp",""));/*это узел левой части*/
			char* chid=crt_node("l_p","",$1);up_node(chid,$$,1);
				  chid=crt_node("INFIX","",$2);up_node(chid,$$,2);
			up_node($3,$$,3);
			chid=crt_node("r_p","",$4);up_node(chid,$$,4);}
   | l_p term INFIX term r_p	/*инфикс*/
			{$$=to_buff(crt_node("term","trmin",""));/*это узел левой части*/
			char* chid=crt_node("l_p","",$1);up_node(chid,$$,1);
			up_node($2,$$,2);
			chid=crt_node("INFIX","",$3);up_node(chid,$$,3);
			up_node($4,$$,4);
			chid=crt_node("r_p","",$5);up_node(chid,$$,5);}
	/*| l_p term Id term r_p	Z: ЭТО 3 КОНФЛИКТА СДВИГА/ВЫВОДА:-(!!! И похоже неоднозначность с TermList!!!*/
   | term l_p TermList r_p
			{$$=to_buff(crt_node("term","trmf",""));	
			up_node($1,$$,1);
			char* chid=crt_node("l_p","",$2);up_node(chid,$$,2);
			up_node($3,$$,3);
			chid=crt_node("r_p","",$4);up_node(chid,$$,4);}
   | l_p EXISTS  Id COLON Id term r_p
			{$$=to_buff(crt_node("term","trme",""));
			char* chid=crt_node("l_p","",$1);up_node(chid,$$,1);
				  chid=crt_node("EXISTS","",$2);up_node(chid,$$,2);
				  chid=crt_node("Id","",$3);up_node(chid,$$,3);
				  chid=crt_node("COLON","",$4);up_node(chid,$$,4);
				  chid=crt_node("Id","",$5);up_node(chid,$$,5);
				  up_node($6,$$,6);
				  chid=crt_node("r_p","",$7);up_node(chid,$$,7);}
   | l_p FOR_ANY Id COLON Id term r_p
			{$$=to_buff(crt_node("term","trma",""));
			char* chid=crt_node("l_p","",$1);up_node(chid,$$,1);
				  chid=crt_node("FOR_ANY","",$2);up_node(chid,$$,2);
				  chid=crt_node("Id","",$3);up_node(chid,$$,3);
				  chid=crt_node("COLON","",$4);up_node(chid,$$,4);
				  chid=crt_node("Id","",$5);up_node(chid,$$,5);
				  up_node($6,$$,6);
				  chid=crt_node("r_p","",$7);up_node(chid,$$,7);}
;
/*<EBNF>(#trml)	TermList : term+*/
TermList : term
			{$$=to_buff(crt_node("TermList","#trml","")); up_node($1,$$,-1);}
	/*Z:Перестановка ведёт к: 2 конфликта сдвига/вывода!!! Возможно с Id_list и можно вводить ","*/
   | term TermList 
			{int chn=get_chn($2); up_node($1,$2,-chn-1);$$=$2;}
; 

/*Для форм- параметров определений и задания КМАС.*/
/*<EBNF> Id_list : Id+ */
Id_list : Id 
				{$$=to_buff(crt_node("Id_list","#Id_list",""));
				 char* ch1=crt_node("Id","",$1); up_node(ch1,$$,1);}
 | Id_list Id  
				{int chn=get_chn($1); char* ch_n=crt_node("Id","",$2); up_node(ch_n,$1,chn+1);$$=$1;}
;
Id_list_b : l_p Id_list r_p 
							{$$=to_buff(crt_node("Id_list_b","Id_list_b-1",""));
							 char* ch1=crt_node("l_p","",$1); up_node(ch1,$$,1);
							 up_node($2,$$,2);
							 char* ch3=crt_node("r_p","",$3); up_node(ch3,$$,3);
							}
;								
/*<EBNF> Id_list_bch : Id_list_b+*/
Id_list_bch : Id_list_b 
						{$$=to_buff(crt_node("Id_list_bch","#Id_list_bch",""));
						 up_node($1,$$,1);}
 | Id_list_bch Id_list_b 
				{int chn=get_chn($1); up_node($2,$1,chn+1);$$=$1;}
;
/*Синтаксис сигнатур*/
sig_f : sig_arg COLON sig_e 
				{$$=to_buff(crt_node("sig_f","sig_f",""));
				 up_node($1,$$,1);
				 char* ch2=crt_node("COLON","",$2); up_node(ch2,$$,2);
				 up_node($3,$$,3);}
;
sig_e : Id
				{$$=to_buff(crt_node("sig_e","sig_eI",""));
				 char* ch1=crt_node("Id","",$1); up_node(ch1,$$,1);}
   | l_p sig_f r_p 
				{$$=to_buff(crt_node("sig_e","sig_eF",""));
					 char* ch1=crt_node("l_p","",$1); up_node(ch1,$$,1);
					 up_node($2,$$,2);
					 char* ch3=crt_node("r_p","",$3); up_node(ch3,$$,3);}
;
/*<EBNF> sig_arg : sig_e+*/
sig_arg : sig_e 
				{$$=to_buff(crt_node("sig_arg","#sig_arg",""));
					 up_node($1,$$,1);}
   |sig_arg  sig_e 
				{int chn=get_chn($1); up_node($2,$1,chn+1);$$=$1;}
;

%%
/*ЛА. вставка его Си кода*/
#include "LA_FOLsn.c"
int main (void) 
{yydebug = 0; int rc;
 if (connect()!=0) goto bad; /*printf ("Connected.\n");*/
 /*чистим ДРВ*/dt_reset(1);/*если не 1 чистки не будет*/
 /*вызов парсера*/
 yyparse ();/*было return */
/* if (commit()!=0) goto bad;*/
 rc = EXIT_SUCCESS;

badr:
 disconnect(); /*printf ("Disconnected.\n");*/
 exit(rc);

bad:
 printf("Unexpected respond from DBMS! Check it!\n");
 printf("sqlca.sqlcode=%i, sqlca.sqlstate=%s.\n",sqlca.sqlcode,sqlca.sqlstate);
 printf("sqlca.sqlerrm.sqlerrmc=%s.\n",sqlca.sqlerrm.sqlerrmc);
 rc = EXIT_FAILURE;
goto badr;
}
void yyerror (char const *s) {printf ("<SA_yyerror msg='%s before this element!'>",s);}
