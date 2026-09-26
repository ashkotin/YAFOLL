/*шаблон СА*/
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
%token NOT
%token AND
%token OR
%token IMPLIES
%token EQUIV
%token Neq
%token Leq
%token Geq
%token WS
%token eq
%token Dot
%token COMMA
%token COLON
%token l_p
%token r_p
%token e_m
%token q_m
%token Plus
%token Minus
%token Multiply
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
%token function
%token predicate
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
%token Hypothesis
%token Theorem
%token functor
%token predicator
%token Id
%token Number
%token String
/*%token WS*/
/*%token Comm*/

%start Statements

%%

/*FOLsn-F rules*/
/*Для форм- параметров определений и задания КМАС.*/
/*<EBNF> Id_list : Id+ */
Id_list : Id {$$=to_buff(/*id*/crt_node(/*sid*/"Id_list",/*rid*/"#Id_list",/*v*/""));
				char* ch1=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);}
 | Id_list Id  {int chn=get_chn($1); char* ch_n=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$2); up_node(/*from*/ch_n,/*to*/$1,/*irn*/chn+1);$$=$1;}
;
/*Обработка: собираем в строку с терминатором "="*/
Id_list_b : l_p Id_list r_p {$$=to_buff(/*id*/crt_node(/*sid*/"Id_list_b",/*rid*/"Id_list_b-1",/*v*/""));
							 char* ch1=/*id*/crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
							 up_node(/*from*/$2,/*to*/$$,/*irn*/2);
							 char* ch3=/*id*/crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);
							}
;								
/*<EBNF> Id_list_bch : Id_list_b+*/
Id_list_bch : Id_list_b {$$=to_buff(/*id*/crt_node(/*sid*/"Id_list_bch",/*rid*/"#Id_list_bch",/*v*/""));
						 up_node(/*from*/$1,/*to*/$$,/*irn*/1);}
 | Id_list_bch Id_list_b {int chn=get_chn($1); up_node(/*from*/$2,/*to*/$1,/*irn*/chn+1);$$=$1;}
;
/*Синтаксис сигнатур*/
sig_f : sig_arg COLON sig_res 
				{$$=to_buff(/*id*/crt_node(/*sid*/"sig_f",/*rid*/"sig_f-1",/*v*/""));
				 up_node(/*from*/$1,/*to*/$$,/*irn*/1);
				 char* ch2=/*id*/crt_node(/*sid*/"COLON",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
				 up_node(/*from*/$3,/*to*/$$,/*irn*/3);
				}
;
sig_res : Id 	{$$=to_buff(/*id*/crt_node(/*sid*/"sig_res",/*rid*/"sig_res-1",/*v*/""));
				 char* ch1=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
				}
	| l_p sig_f r_p {$$=to_buff(/*id*/crt_node(/*sid*/"sig_res",/*rid*/"sig_res-2",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 up_node(/*from*/$2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);}
;
	/*<EBNF> sig_arg : (Id | l_p sig_f r_p)+*/
sig_arg_b : Id {$$=to_buff(/*id*/crt_node(/*sid*/"sig_arg_b",/*rid*/"sig_arg_b-1",/*v*/""));
				 char* ch1=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);}
	| l_p sig_f r_p {$$=to_buff(/*id*/crt_node(/*sid*/"sig_arg_b",/*rid*/"sig_arg_b-2",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 up_node(/*from*/$2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);}
;
/*sig_arg : sig_arg_b+*/
sig_arg : sig_arg_b {$$=to_buff(/*id*/crt_node(/*sid*/"sig_arg",/*rid*/"#sig_arg",/*v*/""));
					 up_node(/*from*/$1,/*to*/$$,/*irn*/1);}
	|sig_arg  sig_arg_b {int chn=get_chn($1); up_node(/*from*/$2,/*to*/$1,/*irn*/chn+1);$$=$1;}
;
/*Объявления*/	  /*Вводится новый сорт Id.*/
Declaration :	DECLARATION Id sort Dot 
					{$$=to_buff(/*id*/crt_node(/*sid*/"Declaration",/*rid*/"Dcl-1",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"DECLARATION",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"sort",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);
					 char* ch4=/*id*/crt_node(/*sid*/"Dot",/*rid*/"",/*v*/$4); up_node(/*from*/ch4,/*to*/$$,/*irn*/4);}
				| DECLARATION Id sort String Dot
					{$$=to_buff(/*id*/crt_node(/*sid*/"Declaration",/*rid*/"Dcl-2",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"DECLARATION",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"sort",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);
					 char* ch4=/*id*/crt_node(/*sid*/"String",/*rid*/"",/*v*/$4); up_node(/*from*/ch4,/*to*/$$,/*irn*/4); 
					 char* ch5=/*id*/crt_node(/*sid*/"Dot",/*rid*/"",/*v*/$5); up_node(/*from*/ch5,/*to*/$$,/*irn*/5);}
		  /*Вводится новая константа Id-1 сорта Id-2.*/
               	| DECLARATION Id COLON Id constant Dot 
					{$$=to_buff(/*id*/crt_node(/*sid*/"Declaration",/*rid*/"Dcl-3",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"DECLARATION",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"COLON",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);
					 char* ch4=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$4); up_node(/*from*/ch4,/*to*/$$,/*irn*/4); 
					 char* ch5=/*id*/crt_node(/*sid*/"constant",/*rid*/"",/*v*/$5); up_node(/*from*/ch5,/*to*/$$,/*irn*/5);
					 char* ch6=/*id*/crt_node(/*sid*/"Dot",/*rid*/"",/*v*/$6); up_node(/*from*/ch6,/*to*/$$,/*irn*/6);}
		/*Вводится новая первичная функция Id */
				| DECLARATION Id sig_f PRIME Dot		
					{$$=to_buff(/*id*/crt_node(/*sid*/"Declaration",/*rid*/"Dcl-4",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"DECLARATION",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 up_node(/*from*/$3,/*to*/$$,/*irn*/3);
					 char* ch4=/*id*/crt_node(/*sid*/"PRIME",/*rid*/"",/*v*/$4); up_node(/*from*/ch4,/*to*/$$,/*irn*/4); 
					 char* ch5=/*id*/crt_node(/*sid*/"Dot",/*rid*/"",/*v*/$5); up_node(/*from*/ch5,/*to*/$$,/*irn*/5);}
		/*Вводится новая вторичная функция Id */
		| DECLARATION Id sig_f Dot			
					{$$=to_buff(/*id*/crt_node(/*sid*/"Declaration",/*rid*/"Dcl-5",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"DECLARATION",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 up_node(/*from*/$3,/*to*/$$,/*irn*/3);
					 char* ch4=/*id*/crt_node(/*sid*/"Dot",/*rid*/"",/*v*/$4); up_node(/*from*/ch4,/*to*/$$,/*irn*/4);}

/*WFC. Требование к совокупности деклараций: все идентификаторы различны.*/
;
/*Терм*/
	   /*атрибут: сорт/сигнатура. проверка на конст-, ф-ю. Остальное - q-переменная!*/
term : Id 
			{$$=to_buff(/*id*/crt_node(/*sid*/"term",/*rid*/"trmId",/*v*/""));
			char* chid=crt_node(/*sid*/"Id",/*rid*/"",/*v*/$1);up_node(/*from*/chid,/*to*/$$,/*irn*/1);}
	| Number
			{$$=to_buff(/*id*/crt_node(/*sid*/"term",/*rid*/"trmNum",/*v*/""));	
			char* chid=crt_node(/*sid*/"Number",/*rid*/"",/*v*/$1);up_node(/*from*/chid,/*to*/$$,/*irn*/1);}
	| String
			{$$=to_buff(/*id*/crt_node(/*sid*/"term",/*rid*/"trmStr",/*v*/""));	
			char* chid=crt_node(/*sid*/"String",/*rid*/"",/*v*/$1);up_node(/*from*/chid,/*to*/$$,/*irn*/1);}
	/*Здесь инфиксы унариков - собственно НЕ!!! WFC: унарик...*/
	| l_p INFIX term r_p
			{$$=to_buff(/*id*/crt_node(/*sid*/"term",/*rid*/"trmPrefix",/*v*/""));/*это узел левой части*/
			char* chid=crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$1);up_node(/*from*/chid,/*to*/$$,/*irn*/1);
				  chid=crt_node(/*sid*/"INFIX",/*rid*/"",/*v*/$2);up_node(/*from*/chid,/*to*/$$,/*irn*/2);
			up_node(/*from*/$3,/*to*/$$,/*irn*/3);
			chid=crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$4);up_node(/*from*/chid,/*to*/$$,/*irn*/4);}
	/*Здесь инфиксы бинариков!!! WFC: бинарик...*/ 
	| l_p term INFIX term r_p
			{$$=to_buff(/*id*/crt_node(/*sid*/"term",/*rid*/"trmInfix",/*v*/""));/*это узел левой части*/
			char* chid=crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$1);up_node(/*from*/chid,/*to*/$$,/*irn*/1);
			up_node(/*from*/$2,/*to*/$$,/*irn*/2);
			chid=crt_node(/*sid*/"INFIX",/*rid*/"",/*v*/$3);up_node(/*from*/chid,/*to*/$$,/*irn*/3);
			up_node(/*from*/$4,/*to*/$$,/*irn*/4);
			chid=crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$5);up_node(/*from*/chid,/*to*/$$,/*irn*/5);}
/*	| l_p term Id term r_p	Z: ЭТО 3 КОНФЛИКТА СДВИГА/ВЫВОДА:-(!!! И похоже неоднозначность с TermList!!! WFC: Id - бинарная ф-я!*/
 	| term l_p TermList r_p
			{$$=to_buff(/*id*/crt_node(/*sid*/"term",/*rid*/"trmF",/*v*/""));	
			up_node(/*from*/$1,/*to*/$$,/*irn*/1);
			char* chid=crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$2);up_node(/*from*/chid,/*to*/$$,/*irn*/2);
			up_node(/*from*/$3,/*to*/$$,/*irn*/3);
			chid=crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$4);up_node(/*from*/chid,/*to*/$$,/*irn*/4);}
 	  /*WFC: term возвращает функцию. WFC: количество, сортность аргументов.*/ 
	| l_p EXISTS  Id COLON Id term r_p
			{$$=to_buff(/*id*/crt_node(/*sid*/"term",/*rid*/"trmEx",/*v*/""));
			char* chid=crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$1);up_node(/*from*/chid,/*to*/$$,/*irn*/1);
				  chid=crt_node(/*sid*/"EXISTS",/*rid*/"",/*v*/$2);up_node(/*from*/chid,/*to*/$$,/*irn*/2);
				  chid=crt_node(/*sid*/"Id",/*rid*/"",/*v*/$3);up_node(/*from*/chid,/*to*/$$,/*irn*/3);
				  chid=crt_node(/*sid*/"COLON",/*rid*/"",/*v*/$4);up_node(/*from*/chid,/*to*/$$,/*irn*/4);
				  chid=crt_node(/*sid*/"Id",/*rid*/"",/*v*/$5);up_node(/*from*/chid,/*to*/$$,/*irn*/5);
				  up_node(/*from*/$6,/*to*/$$,/*irn*/6);
				  chid=crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$7);up_node(/*from*/chid,/*to*/$$,/*irn*/7);}
	  /*WFC: сорт term - TV*//*WFC: Id-1 - переменная, Id-2 - сорт*/ 	
	| l_p FOR_ANY Id COLON Id term r_p
			{$$=to_buff(/*id*/crt_node(/*sid*/"term",/*rid*/"trmEx",/*v*/""));
			char* chid=crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$1);up_node(/*from*/chid,/*to*/$$,/*irn*/1);
				  chid=crt_node(/*sid*/"FOR_ANY",/*rid*/"",/*v*/$2);up_node(/*from*/chid,/*to*/$$,/*irn*/2);
				  chid=crt_node(/*sid*/"Id",/*rid*/"",/*v*/$3);up_node(/*from*/chid,/*to*/$$,/*irn*/3);
				  chid=crt_node(/*sid*/"COLON",/*rid*/"",/*v*/$4);up_node(/*from*/chid,/*to*/$$,/*irn*/4);
				  chid=crt_node(/*sid*/"Id",/*rid*/"",/*v*/$5);up_node(/*from*/chid,/*to*/$$,/*irn*/5);
				  up_node(/*from*/$6,/*to*/$$,/*irn*/6);
				  chid=crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$7);up_node(/*from*/chid,/*to*/$$,/*irn*/7);}
	/*WFC: сорт term - TV*//*WFC: Id-1 - переменная, Id-2 - сорт*/
;
/*(#trml)	TermList : term+*/
TermList : term
			{$$=to_buff(/*id*/crt_node(/*sid*/"TermList",/*rid*/"#trml",/*v*/"")); up_node(/*from*/$1,/*to*/$$,/*irn*/-1);}
	/*Z:Перестановка ведёт к: 2 конфликта сдвига/вывода!!! Возможно с Id_list и можно вводить ","*/
	| term TermList 
			{int chn=get_chn($2); up_node(/*from*/$1,/*to*/$2,/*irn*/-chn-1);$$=$2;}
; 

/***Определения***/
/*Id-1 - уникальный идентификатор определения. Id-2 - уникальный идентификатор определяемого.*/
Definition : DEFINITION Id Id constant term Dot 
					{$$=to_buff(/*id*/crt_node(/*sid*/"Definition",/*rid*/"Def-1",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"DEFINITION",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);
					 char* ch4=/*id*/crt_node(/*sid*/"constant",/*rid*/"",/*v*/$4); up_node(/*from*/ch4,/*to*/$$,/*irn*/4); 
					 up_node(/*from*/$5,/*to*/$$,/*irn*/5);
					 char* ch6=/*id*/crt_node(/*sid*/"Dot",/*rid*/"",/*v*/$6); up_node(/*from*/ch6,/*to*/$$,/*irn*/6);}
					 /*Функция термом с формальными параметрами из Id_list.*/
	| DEFINITION Id Id Id_list_bch COLON term Dot
								{$$=to_buff(/*id*/crt_node(/*sid*/"Definition",/*rid*/"Def-2",/*v*/""));
								 char* ch1=/*id*/crt_node(/*sid*/"DEFINITION",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
								 char* chid=crt_node(/*sid*/"Id",/*rid*/"",/*v*/$2);up_node(/*from*/chid,/*to*/$$,/*irn*/2);
								 chid=crt_node(/*sid*/"Id",/*rid*/"",/*v*/$3);up_node(/*from*/chid,/*to*/$$,/*irn*/3);
								 up_node(/*from*/$4,/*to*/$$,/*irn*/4);
								 char* ch5=/*id*/crt_node(/*sid*/"COLON",/*rid*/"",/*v*/$5); up_node(/*from*/ch5,/*to*/$$,/*irn*/5); 
								 up_node(/*from*/$6,/*to*/$$,/*irn*/6);
								 char* ch7=/*id*/crt_node(/*sid*/"Dot",/*rid*/"",/*v*/$7); up_node(/*from*/ch7,/*to*/$$,/*irn*/7);}
	/* !WFC: все формальные параметры должны быть различны.*/   
	/*char* msg=def_chk_fp($4); if (*msg!=0) printf("\n<:-(Can't add definition to theory. msg=(%s). Definition:func-1>\n",msg);*/
	/* !WFC: соблюдение декларации!*/
	/* !WFC: в составе "вызываемых" Id в терме могут быть формальные параметры, константы, кванторные переменные.*/   
;
/*Требования к совокупности при любых расширениях:*/
/*WFC. Id определения уникален на определениях.*/

/***Выведенная формула***/
/*На входе LA иногда термы но в основном формулы! +У: у Менд- формулы вовсе не замкнутые!!!Z!!!*/
derived_formula : LA1 l_p term COMMA term r_p 	/*М.65. return t1>(t2>t1). WFC:все термы - замкнутые формулы*/
					{$$=to_buff(/*id*/crt_node(/*sid*/"derived_formula",/*rid*/"LA1",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"LA1",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 up_node(/*from*/$3,/*to*/$$,/*irn*/3);
					 char* ch4=/*id*/crt_node(/*sid*/"COMMA",/*rid*/"",/*v*/$4); up_node(/*from*/ch4,/*to*/$$,/*irn*/4); 
					 up_node(/*from*/$5,/*to*/$$,/*irn*/5);
					 char* ch6=/*id*/crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$6); up_node(/*from*/ch6,/*to*/$$,/*irn*/6);}
				| LA2 l_p term COMMA term COMMA term r_p 	/*М.65. return импли-формула. WFC:все термы - замкнутые формулы*/
					{$$=to_buff(/*id*/crt_node(/*sid*/"derived_formula",/*rid*/"LA2",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"LA2",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 up_node(/*from*/$3,/*to*/$$,/*irn*/3);
					 char* ch4=/*id*/crt_node(/*sid*/"COMMA",/*rid*/"",/*v*/$4); up_node(/*from*/ch4,/*to*/$$,/*irn*/4); 
					 up_node(/*from*/$5,/*to*/$$,/*irn*/5);
					 char* ch6=/*id*/crt_node(/*sid*/"COMMA",/*rid*/"",/*v*/$6); up_node(/*from*/ch6,/*to*/$$,/*irn*/6);
					 up_node(/*from*/$7,/*to*/$$,/*irn*/7);
					 char* ch8=/*id*/crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$8); up_node(/*from*/ch6,/*to*/$$,/*irn*/8);}					 
				| LA3 l_p term COMMA term r_p 			/*М.66. return импли-не-формула. WFC:все термы - замкнутые формулы*/
					{$$=to_buff(/*id*/crt_node(/*sid*/"derived_formula",/*rid*/"LA3",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"LA3",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 up_node(/*from*/$3,/*to*/$$,/*irn*/3);
					 char* ch4=/*id*/crt_node(/*sid*/"COMMA",/*rid*/"",/*v*/$4); up_node(/*from*/ch4,/*to*/$$,/*irn*/4); 
					 up_node(/*from*/$5,/*to*/$$,/*irn*/5);
					 char* ch6=/*id*/crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$6); up_node(/*from*/ch6,/*to*/$$,/*irn*/6);}				
 				| LA4 l_p Id COMMA term COMMA term r_p 			/*М.66. Id - переменная. WFC:term-1 - классический терм, term-2 - формула (какая?)*/
					{$$=to_buff(/*id*/crt_node(/*sid*/"derived_formula",/*rid*/"LA4",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"LA4",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);
					 char* ch4=/*id*/crt_node(/*sid*/"COMMA",/*rid*/"",/*v*/$4); up_node(/*from*/ch4,/*to*/$$,/*irn*/4); 
					 up_node(/*from*/$5,/*to*/$$,/*irn*/5);
					 char* ch6=/*id*/crt_node(/*sid*/"COMMA",/*rid*/"",/*v*/$6); up_node(/*from*/ch6,/*to*/$$,/*irn*/6);
					 up_node(/*from*/$7,/*to*/$$,/*irn*/7);
					 char* ch8=/*id*/crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$8); up_node(/*from*/ch6,/*to*/$$,/*irn*/8);}					 
 				| LA5 l_p Id COMMA term COMMA term r_p 		/*М.66. Id - переменная. WFC:все термы - замкнутые формулы*/
					{$$=to_buff(/*id*/crt_node(/*sid*/"derived_formula",/*rid*/"LA5",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"LA5",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);
					 char* ch4=/*id*/crt_node(/*sid*/"COMMA",/*rid*/"",/*v*/$4); up_node(/*from*/ch4,/*to*/$$,/*irn*/4); 
					 up_node(/*from*/$5,/*to*/$$,/*irn*/5);
					 char* ch6=/*id*/crt_node(/*sid*/"COMMA",/*rid*/"",/*v*/$6); up_node(/*from*/ch6,/*to*/$$,/*irn*/6);
					 up_node(/*from*/$7,/*to*/$$,/*irn*/7);
					 char* ch8=/*id*/crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$8); up_node(/*from*/ch6,/*to*/$$,/*irn*/8);}					 
 				| MP l_p derived_formula COMMA derived_formula r_p 		/*М.66. проверяет строение F2 и наличие в ней F1.*/
					{$$=to_buff(/*id*/crt_node(/*sid*/"derived_formula",/*rid*/"MP",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"MP",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 up_node(/*from*/$3,/*to*/$$,/*irn*/3);
					 char* ch4=/*id*/crt_node(/*sid*/"COMMA",/*rid*/"",/*v*/$4); up_node(/*from*/ch4,/*to*/$$,/*irn*/4); 
					 up_node(/*from*/$5,/*to*/$$,/*irn*/5);
					 char* ch6=/*id*/crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$6); up_node(/*from*/ch6,/*to*/$$,/*irn*/6);}
 				| Gen l_p Id COMMA derived_formula r_p 			/*М.66. Id - переменная. ничего не проверяет.*/
					{$$=to_buff(/*id*/crt_node(/*sid*/"derived_formula",/*rid*/"Gen",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"Gen",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);
					 char* ch4=/*id*/crt_node(/*sid*/"COMMA",/*rid*/"",/*v*/$4); up_node(/*from*/ch4,/*to*/$$,/*irn*/4); 
					 up_node(/*from*/$5,/*to*/$$,/*irn*/5);
					 char* ch6=/*id*/crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$6); up_node(/*from*/ch6,/*to*/$$,/*irn*/6);}
 				| Id /*WFC: Id - теоремы или прикладной аксиомы!*/
					{$$=to_buff(/*id*/crt_node(/*sid*/"derived_formula",/*rid*/"derf-8",/*v*/""));
					char* ch1=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);}
;

Statement :   Declaration
					{$$=to_buff(/*id*/crt_node(/*sid*/"Statement",/*rid*/"st-1",/*v*/""));
					 up_node(/*from*/$1,/*to*/$$,/*irn*/1);}
			| Definition
					{$$=to_buff(/*id*/crt_node(/*sid*/"Statement",/*rid*/"st-2",/*v*/""));
					 up_node(/*from*/$1,/*to*/$$,/*irn*/1);}
			| String /*Хранимый комментарий:-)*/
					{$$=to_buff(/*id*/crt_node(/*sid*/"Statement",/*rid*/"st-3",/*v*/""));
					 char* ch=/*id*/crt_node(/*sid*/"String",/*rid*/"",/*v*/$1); up_node(/*from*/ch,/*to*/$$,/*irn*/1);}
            | Add infix String to Id Dot /*WFC: Id - ф-я...*/
					{$$=to_buff(/*id*/crt_node(/*sid*/"Statement",/*rid*/"st-4",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"Add",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"infix",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"String",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);
					 char* ch4=/*id*/crt_node(/*sid*/"to",/*rid*/"",/*v*/$4); up_node(/*from*/ch4,/*to*/$$,/*irn*/4); 
					 char* ch5=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$5); up_node(/*from*/ch5,/*to*/$$,/*irn*/5); 
					 char* ch6=/*id*/crt_node(/*sid*/"Dot",/*rid*/"",/*v*/$6); up_node(/*from*/ch6,/*to*/$$,/*irn*/6);}
            | Axiom Id term Dot /*WFC: term - замкнутая формула!*/
					{$$=to_buff(/*id*/crt_node(/*sid*/"Statement",/*rid*/"st-5",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"Axiom",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 up_node(/*from*/$3,/*to*/$$,/*irn*/3);
					 char* ch4=/*id*/crt_node(/*sid*/"Dot",/*rid*/"",/*v*/$4); up_node(/*from*/ch4,/*to*/$$,/*irn*/4);} 
            | e_m Number e_m    /*WFC: номер команды из списка.*/
					{$$=to_buff(/*id*/crt_node(/*sid*/"Statement",/*rid*/"st-6",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"e_m",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"Number",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"e_m",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);}
			/*КМАС. Удаление значения функции Id-1.*/
			/*WFC: Id-1 - первичная ф-я. Id_list - константы. WFC: количество и сортность аргументов.*/
            | e_m Id l_p Id_list r_p COLON e_m 
					{$$=to_buff(/*id*/crt_node(/*sid*/"Statement",/*rid*/"st-7",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"e_m",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);
					 up_node(/*from*/$4,/*to*/$$,/*irn*/4); 
					 char* ch5=/*id*/crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$5); up_node(/*from*/ch5,/*to*/$$,/*irn*/5);
					 char* ch6=/*id*/crt_node(/*sid*/"COLON",/*rid*/"",/*v*/$6); up_node(/*from*/ch6,/*to*/$$,/*irn*/6);
					 char* ch7=/*id*/crt_node(/*sid*/"e_m",/*rid*/"",/*v*/$7); up_node(/*from*/ch7,/*to*/$$,/*irn*/7);}
			/*КМАС. Задание значения функции Id-1 равным Id-2.*/
			/*WFC: Id-1 - первичная ф-я. Id_list, Id-2 - константы. WFC: количество и сортность аргументов.*/
            | e_m Id l_p Id_list r_p COLON Id e_m   
					{$$=to_buff(/*id*/crt_node(/*sid*/"Statement",/*rid*/"st-8",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"e_m",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);
					 up_node(/*from*/$4,/*to*/$$,/*irn*/4); 
					 char* ch5=/*id*/crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$5); up_node(/*from*/ch5,/*to*/$$,/*irn*/5);
					 char* ch6=/*id*/crt_node(/*sid*/"COLON",/*rid*/"",/*v*/$6); up_node(/*from*/ch6,/*to*/$$,/*irn*/6);
					 char* ch7=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$7); up_node(/*from*/ch7,/*to*/$$,/*irn*/7);
					 char* ch8=/*id*/crt_node(/*sid*/"e_m",/*rid*/"",/*v*/$8); up_node(/*from*/ch8,/*to*/$$,/*irn*/8);}
			/*КМАС. Задание значения функции Id-1 равным числу.*/
			/*WFC: Id-1 - первичная ф-я. Id_list - константы. WFC: количество и сортность аргументов.*/
            | e_m Id l_p Id_list r_p COLON Number e_m 
					{$$=to_buff(/*id*/crt_node(/*sid*/"Statement",/*rid*/"st-9",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"e_m",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);
					 up_node(/*from*/$4,/*to*/$$,/*irn*/4); 
					 char* ch5=/*id*/crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$5); up_node(/*from*/ch5,/*to*/$$,/*irn*/5);
					 char* ch6=/*id*/crt_node(/*sid*/"COLON",/*rid*/"",/*v*/$6); up_node(/*from*/ch6,/*to*/$$,/*irn*/6);
					 char* ch7=/*id*/crt_node(/*sid*/"Number",/*rid*/"",/*v*/$7); up_node(/*from*/ch7,/*to*/$$,/*irn*/7);
					 char* ch8=/*id*/crt_node(/*sid*/"e_m",/*rid*/"",/*v*/$8); up_node(/*from*/ch8,/*to*/$$,/*irn*/8);}
			/*КМАС. Задание значения функции Id-1 равным строке.*/
			/*WFC: Id-1 - первичная ф-я. Id_list - константы. WFC: количество и сортность аргументов.*/
            | e_m Id l_p Id_list r_p COLON String e_m 
					{$$=to_buff(/*id*/crt_node(/*sid*/"Statement",/*rid*/"st-10",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"e_m",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"l_p",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);
					 up_node(/*from*/$4,/*to*/$$,/*irn*/4); 
					 char* ch5=/*id*/crt_node(/*sid*/"r_p",/*rid*/"",/*v*/$5); up_node(/*from*/ch5,/*to*/$$,/*irn*/5);
					 char* ch6=/*id*/crt_node(/*sid*/"COLON",/*rid*/"",/*v*/$6); up_node(/*from*/ch6,/*to*/$$,/*irn*/6);
					 char* ch7=/*id*/crt_node(/*sid*/"String",/*rid*/"",/*v*/$7); up_node(/*from*/ch7,/*to*/$$,/*irn*/7);
					 char* ch8=/*id*/crt_node(/*sid*/"e_m",/*rid*/"",/*v*/$8); up_node(/*from*/ch8,/*to*/$$,/*irn*/8);}
			/*КМАС. Запрос на значение терма и замкнутой формулы.*/
            | q_m term q_m /* WFC: классический терм - константный, формула - замкнутая.*/
					{$$=to_buff(/*id*/crt_node(/*sid*/"Statement",/*rid*/"st-11",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"q_m",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 up_node(/*from*/$2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"q_m",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);}			
			| Proof Id Id derived_formula Dot 	/*Id-2 - имя теоремы! Может быть несколько доказательств одной и той же теоремы!*/
					{$$=to_buff(/*id*/crt_node(/*sid*/"Statement",/*rid*/"st-12",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"Proof",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 char* ch3=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$3); up_node(/*from*/ch3,/*to*/$$,/*irn*/3);
					 up_node(/*from*/$4,/*to*/$$,/*irn*/4); 
					 char* ch5=/*id*/crt_node(/*sid*/"Dot",/*rid*/"",/*v*/$5); up_node(/*from*/ch5,/*to*/$$,/*irn*/5);}
            | Theorem Id term Dot 		/*WFC: term - замкнутая формула*/
					{$$=to_buff(/*id*/crt_node(/*sid*/"Statement",/*rid*/"st-13",/*v*/""));
					 char* ch1=/*id*/crt_node(/*sid*/"Theorem",/*rid*/"",/*v*/$1); up_node(/*from*/ch1,/*to*/$$,/*irn*/1);
					 char* ch2=/*id*/crt_node(/*sid*/"Id",/*rid*/"",/*v*/$2); up_node(/*from*/ch2,/*to*/$$,/*irn*/2);
					 up_node(/*from*/$3,/*to*/$$,/*irn*/3); 
					 char* ch4=/*id*/crt_node(/*sid*/"Dot",/*rid*/"",/*v*/$4); up_node(/*from*/ch4,/*to*/$$,/*irn*/4);}
	|error Dot	{printf("\n<SA BAD_Statement='%s'>\n",$1);}
;
/*WFC. Id на каждой совокупности (аксиом, гипотез, теорем) уникален. */
/*<EBNF>Statements:Statement+.*/
Statements :  Statement
				{$$=to_buff(/*id*/crt_node(/*sid*/"Statements",/*rid*/"#st",/*v*/"")); up_node(/*from*/$1,/*to*/$$,/*irn*/1);}
			| Statements Statement
				{int chn=get_chn($1); up_node(/*from*/$2,/*to*/$1,/*irn*/chn+1);$$=$1;}
;

%%
/*ЛА. вставка его Си кода*/
#include "LA_FOLsn.c"
int main (void) 
{yydebug = 0; int rc;
 if (connect()!=0) goto bad; /*printf ("Connected.\n");*/
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
void yyerror (char const *s) {printf ("<--SA>");}
