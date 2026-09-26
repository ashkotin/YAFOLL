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
Id_list : Id {char w[122]=""; strcpy(w,$1); strcat(w,","); $$=to_buff(/*id*/crt_node(/*sid*/"Id_list",/*rid*/"#Id_list",/*v*/w));
				char* id=/*id*/crt_node(/*sid*/"Id",/*rid*/"rex:Id",/*v*/$1); up_node(/*from*/id,/*to*/$$,/*irn*/1);}
 | Id_list Id  {int chn=get_chn($1); char w[122]=""; strcpy(w,node_get_v($1)); strcat(w,$2); strcat(w,","); node_put_v($1,&w[0]);
				char* id=/*id*/crt_node(/*sid*/"Id",/*rid*/"rex:Id",/*v*/$2); up_node(/*from*/id,/*to*/$1,/*irn*/chn+1);$$=$1;}
;
/*Обработка: собираем в строку с терминатором "="*/
Id_list_b : l_p Id_list r_p {$$=to_buff(/*id*/crt_node(/*sid*/"Id_list_b",/*rid*/"Id_list_b_0",/*v*/""));
							 up_node(/*from*/$2,/*to*/$$,/*irn*/2);}
;								
/*<EBNF> Id_list_bch : Id_list_b+*/
Id_list_bch : Id_list_b {$$=to_buff(/*id*/crt_node(/*sid*/"Id_list_bch",/*rid*/"#Id_list_bch",/*v*/""));
						 up_node(/*from*/$1,/*to*/$$,/*irn*/1);}
 | Id_list_bch Id_list_b {int chn=get_chn($1); up_node(/*from*/$2,/*to*/$1,/*irn*/chn+1);$$=$1;}
;
/*Синтаксис сигнатур*/
sig_f : sig_arg COLON sig_res /*строится сигф. $$ = <ид сигф>*/
				{int RC=sigf_add($1,$3,&$$);
							if (RC==0) {/*printf("\n<!!!SIG_F: sig %s upped from %s : %s:-)>\n",$$,$1,$3)*/;} 
							else if (RC==1) printf("\n<!!!SIG_F: Can't add! No sig arg!>");
							else if (RC==2) printf("\n<!!!SIG_F: Can't add! No sig res!>");
							else printf("\n<!!!SIG_F: Can't add! Unexpected RC=%i!>\n",RC);
				}
;
sig_res : Id 	/*WFC: Id - сорт.*//*проверяется что Id - сорт. $$=Id*/
				{char t[22];
				 if (e_exists_q($1,t)!=0) printf("\n<:-(no such entity %s!!!SIG_RES-1>\n",$1);
				 else if (strcmp(t,"sort")!=0) printf("\n<:-(%s must be a sort, but %s!!!SIG_RES-1>\n",$1,t);
				 else {$$=$1;/* printf("\n<SIG_RES-1: %s upped:-)>\n",$$);*/}
				}
	| l_p sig_f r_p /*$$ = <ид сигф> */
				{char t[22];
				 if (e_exists_q($2,t)!=0) printf("\n<:-(no such sig '%s'!!!SIG_RES-2>\n",$2);
				 else {$$=$2; /*printf("\n<!!!SIG_RES-2: %s upped:-)>\n",$$);*/}
				}
;
	/*<EBNF> sig_arg : (Id | l_p sig_f r_p)+*/
sig_arg : Id /*WFC: Id - сорт.*/ /*проверяется что Id - сорт. $$=Id*/
				{char t[22];
				 if (e_exists_q($1,t)!=0) printf("\n<:-(no such entity %s!!!SIG_ARG-1>\n",$1);
				 else if (strcmp(t,"sort")!=0) printf("\n<:-(%s must be a sort, but %s!!!SIG_ARG-1>\n",$1,t);
				 else {$$=$1; /*printf("\n<!!!SIG_ARG-1: %s upped:-)>\n",$$);*/}
				}
	| l_p sig_f r_p {$$ = $2;}
	| sig_arg Id 	/*WFC: Id - сорт.*/ /*если sig_arg - цепь, то добавить Id в конец, иначе построить сигц. $$ = <ид сигц>*/
				{char t[22];
				 if (e_exists_q($2,t)!=0) printf("\n<:-(no such entity %s!!!SIG_ARG-3>\n",$2);
				 else if (strcmp(t,"sort")!=0) printf("\n<:-(%s must be a sort, but %s!!!SIG_ARG-3>\n",$2,t);
				 if (strncmp($1,"#",1)==0) 
				 {/*цепь уже есть*/int RC=sigc_add2($1,$2);
							if (RC==0) {/*printf("\n<:-)SIG_ARG-3: sigc %s added to end %s:-)>\n",$1,$2);*/ $$=$1;} 
							else printf("\n<:-(Can't add! Unexpected RC=%i from sigc_add2!!!SIG_ARG-3>\n",RC);
				 }
				 else      {/*делаем цепь*/int RC=sigc_add($1,$2,&$$);
							if (RC==0) {/*printf("\n<:-)SIG_ARG-3: sigc %s added 1 = %s, 2 = %s:-)>\n",$$,$1,$2)*/;} 
							else if (RC==1) printf("\n<:-(Can't add! No 1 = %s!SIG_ARG-3>\n",$1);
							else printf("\n<:-(Can't add! Unexpected RC=%i!SIG_ARG-3>\n",RC);
							}
				}
	| sig_arg l_p sig_f r_p /*если sig_arg - цепь, то добавить <ид сигф> в конец, иначе построить сигц. $$ = <ид сигц>*/
				{if (strncmp($1,"#",1)==0) 
				 {/*цепь уже есть*/int RC=sigc_add2($1,$3);
							if (RC!=0) printf("\n<:-(Can't add! Unexpected RC=%i from sigc_add2!SIG_ARG-4>\n",RC);
				 }
				 else      {/*делаем цепь*/int RC=sigc_add($1,$3,&$$);
							if (RC!=0) printf("\n<:-(Can't add! Unexpected RC=%i!SIG_ARG-3>\n",RC);
							}
				}
;
/*Объявления*/	  /*Вводится новый сорт Id.*/
Declaration :	DECLARATION Id sort Dot 	{char t[22]; 
											 if (sort_add($2,t,"")!=0) printf("\n<:-(Can't add! %s is already used as %s!DECLARATION_s>\n",$2,t);}
				| DECLARATION Id sort String Dot 	{char t[22]; 
											if (*$4==0) printf("\n<:-(Can't add! REx is empty!DECLARATION_s>\n");
											else if (sort_add($2,t,$4)!=0) printf("\n<:-(Can't add! %s is already used as %s!DECLARATION_s>\n",$2,t);}
		  /*Вводится новая константа Id-1 сорта Id-2.*/
               	| DECLARATION Id COLON Id constant Dot 
							{char t[22]; int RC = const_add($2,$4,t); 
							if (RC==0) /*printf ("\n<DECLARATION-c: %s added.>\n",$2)*/; 
							else if (RC==1) printf("\n<:-(DECLARATION-c: Can't add! %s is already used as %s!>\n",$2,t);
							else if (RC==2) printf("\n<:-(DECLARATION-c: Can't add! %s not exists!>\n",$4);
							else if (RC==3) printf("\n<:-(DECLARATION-c: Can't add! %s is not a sort!>\n",$4);
							else printf("\n<:-(DECLARATION-c: Can't add! Unexpected RC=%i!>\n",RC);}
/*РЕШЕНИЕ РЕАЛИЗАЦИИ: развёртываем sig_f в следующих правилах, чтобы иметь доступ к атрибутам частей*/
		/*Вводится новая первичная функция Id */
		| DECLARATION Id sig_arg COLON sig_res PRIME Dot		
							{char* msg; int RC=f_add($2,$3,$5,1,&msg);
							if (RC!=0) printf("\n<:-(Can't add function. rc=%i, msg=(%s). DECLARATION_f 1>\n",RC,msg);} 
		/*Вводится новая вторичная функция Id */
		| DECLARATION Id sig_arg COLON sig_res Dot			
							{char* msg; int RC=f_add($2,$3,$5,0,&msg); 
							if (RC!=0) printf("\n<:-(Can't add function. rc=%i, msg=(%s). DECLARATION_f 0>\n",RC,msg);} 

/*WFC. Требование к совокупности деклараций: все идентификаторы различны.*/
;
/*Терм*/
	   /*атрибут: сорт/сигнатура. проверка на конст-, ф-ю. Остальное - q-переменная!*/
term : Id {$$=to_buff(/*id*/crt_node(/*sid*/"term",/*rid*/"trmId",/*v*/""));
			char* chid=crt_node(/*sid*/"Id",/*rid*/"",/*v*/$1);up_node(/*from*/chid,/*to*/$$,/*irn*/1);}
	| Number {$$=to_buff(/*id*/crt_node(/*sid*/"term",/*rid*/"trmNum",/*v*/""));	
			char* chid=crt_node(/*sid*/"Number",/*rid*/"",/*v*/$1);up_node(/*from*/chid,/*to*/$$,/*irn*/1);}
	| String {$$=to_buff(/*id*/crt_node(/*sid*/"term",/*rid*/"trmStr",/*v*/""));	
			char* chid=crt_node(/*sid*/"String",/*rid*/"",/*v*/$1);up_node(/*from*/chid,/*to*/$$,/*irn*/1);}
	/*Здесь инфиксы унариков - собственно НЕ!!! WFC: унарик...*/
	| l_p INFIX term r_p {$$=to_buff(/*id*/crt_node(/*sid*/"term",/*rid*/"trmPrefix",/*v*/""));/*это узел левой части*/
			char* chid=crt_node(/*sid*/"INFIX",/*rid*/"",/*v*/$2);up_node(/*from*/chid,/*to*/$$,/*irn*/2);
			up_node(/*from*/$3,/*to*/$$,/*irn*/3);}
	/*Здесь инфиксы бинариков!!! WFC: бинарик...*/ 
	| l_p term INFIX term r_p {$$=to_buff(/*id*/crt_node(/*sid*/"term",/*rid*/"trmInfix",/*v*/""));/*это узел левой части*/
			up_node(/*from*/$2,/*to*/$$,/*irn*/2);
			char* chid=crt_node(/*sid*/"INFIX",/*rid*/"",/*v*/$3);up_node(/*from*/chid,/*to*/$$,/*irn*/3);
			up_node(/*from*/$4,/*to*/$$,/*irn*/4);}
/*	| l_p term Id term r_p	Z: ЭТО 3 КОНФЛИКТА СДВИГА/ВЫВОДА:-(!!! И похоже неоднозначность с TermList!!! WFC: Id - бинарная ф-я!*/
 	| term l_p TermList r_p {$$=to_buff(/*id*/crt_node(/*sid*/"term",/*rid*/"trmf",/*v*/""));	
			up_node(/*from*/$1,/*to*/$$,/*irn*/1);up_node(/*from*/$3,/*to*/$$,/*irn*/3);}
 	  /*WFC: term возвращает функцию. WFC: количество, сортность аргументов.*/ 
	| l_p EXISTS  Id COLON Id term r_p 	{$$=to_buff(/*id*/crt_node(/*sid*/"term",/*rid*/"trmEx",/*v*/""));
			char* chid=crt_node(/*sid*/"Id",/*rid*/"",/*v*/$3);up_node(/*from*/chid,/*to*/$$,/*irn*/3);
				  chid=crt_node(/*sid*/"Id",/*rid*/"",/*v*/$5);up_node(/*from*/chid,/*to*/$$,/*irn*/5);
				  up_node(/*from*/$6,/*to*/$$,/*irn*/6);}
	  /*WFC: сорт term - TV*//*WFC: Id-1 - переменная, Id-2 - сорт*/ 	
	| l_p FOR_ANY Id COLON Id term r_p	{$$=to_buff(/*id*/crt_node(/*sid*/"term",/*rid*/"trmAny",/*v*/""));
			char* chid=crt_node(/*sid*/"Id",/*rid*/"",/*v*/$3);up_node(/*from*/chid,/*to*/$$,/*irn*/3);
				  chid=crt_node(/*sid*/"Id",/*rid*/"",/*v*/$5);up_node(/*from*/chid,/*to*/$$,/*irn*/5);
				  up_node(/*from*/$6,/*to*/$$,/*irn*/6);}
	/*WFC: сорт term - TV*//*WFC: Id-1 - переменная, Id-2 - сорт*/
;
/*(#trml)	TermList : term+*/
TermList : term {$$=to_buff(/*id*/crt_node(/*sid*/"TermList",/*rid*/"#trml",/*v*/"")); up_node(/*from*/$1,/*to*/$$,/*irn*/-1);}
	/*Z:Перестановка ведёт к: 2 конфликта сдвига/вывода!!! Возможно с Id_list и можно вводить ","*/
	| term TermList {int chn=get_chn($2); up_node(/*from*/$1,/*to*/$2,/*irn*/-chn-1);$$=$2;}
; 

/***Определения***/
/*Id-1 - уникальный идентификатор определения. Id-2 - уникальный идентификатор определяемого.*/
Definition : DEFINITION Id Id constant term Dot {if (*$5!=0) {char* msg=const_add_d($2,$3,$5);
												  if (*msg!=0) printf("\n<:-(Can't add definition to theory. msg=(%s). Definition:const-1>\n",msg);}
												else printf("\n<:-(Can't add definition to theory. Definition:const-2>\n");}
   	/*Функция термом с формальными параметрами из Id_list.*/
	| DEFINITION Id Id Id_list_bch COLON term Dot {$$=to_buff(/*id*/crt_node(/*sid*/"Definition",/*rid*/"Definition_2",/*v*/""));
								char* chid=crt_node(/*sid*/"Id",/*rid*/"",/*v*/$2);up_node(/*from*/chid,/*to*/$$,/*irn*/2);
								chid=crt_node(/*sid*/"Id",/*rid*/"",/*v*/$3);up_node(/*from*/chid,/*to*/$$,/*irn*/3);
								up_node(/*from*/$4,/*to*/$$,/*irn*/4);
								up_node(/*from*/$6,/*to*/$$,/*irn*/6);
	/* !WFC: все формальные параметры должны быть различны.*/   
	char* msg=def_chk_fp($4); if (*msg!=0) printf("\n<:-(Can't add definition to theory. msg=(%s). Definition:func-1>\n",msg);
	/* !WFC: соблюдение декларации!*/
	/* !WFC: в составе "вызываемых" Id в терме могут быть формальные параметры, константы, кванторные переменные.*/   
	}
;
/*Требования к совокупности при любых расширениях:*/
/*WFC. Id определения уникален на определениях.*/

/***Выведенная формула***/
/*На входе LA иногда термы но в основном формулы! +У: у Менд- формулы вовсе не замкнутые!!!Z!!!*/
derived_formula : LA1 l_p term COMMA term r_p 	/*М.65. return t1>(t2>t1). WFC:все термы - замкнутые формулы*/
 |LA2 l_p term COMMA term COMMA term r_p 	/*М.65. return импли-формула. WFC:все термы - замкнутые формулы*/
 |LA3 l_p term COMMA term r_p 			/*М.66. return импли-не-формула. WFC:все термы - замкнутые формулы*/
 |LA4 l_p Id COMMA term COMMA term r_p 			/*М.66. Id - переменная. WFC:term-1 - классический терм, term-2 - формула (какая?)*/
 |LA5 l_p Id COMMA term COMMA term r_p 		/*М.66. Id - переменная. WFC:все термы - замкнутые формулы*/
 |MP l_p derived_formula COMMA derived_formula r_p 		/*М.66. проверяет строение F2 и наличие в ней F1.*/
 |Gen l_p Id COMMA derived_formula r_p 			/*М.66. Id - переменная. ничего не проверяет.*/
 | Id 								/*WFC: Id - теоремы или прикладной аксиомы!*/
;

Statement : 	Declaration | Definition | String /*Комментарий:-)*/
              | Add infix String to Id Dot /*WFC: Id - ф-я...*/{char* msg; int rc=a_i2f($5,$3,&msg); 
										if (rc!=0) printf("\n<:-(Can't add infix to f-n. rc=%i, msg=(%s).>\n",rc,msg);} 
              | Axiom Id term Dot /*WFC: term - замкнутая формула!*/
              | e_m Number e_m    /*WFC: номер команды из списка.*/{if (doc($2)!=0) printf("\n<!Not a command - %s!>\n",$2);}
		/*КМАС. Удаление значения функции Id-1.*/
		/*WFC: Id-1 - первичная ф-я. Id_list - константы. WFC: количество и сортность аргументов.*/
              | e_m Id l_p Id_list r_p COLON e_m   {char* msg; char err_e[22]; int rc=a_p_f($2,$4,$7,0,err_e,&msg); 
										if (rc!=0) printf("\n<:-(Can't assign nothing to f-n. rc=%i, msg=(%s), err_e=(%s). e_m-0>\n",rc,msg,err_e);} 
		/*КМАС. Задание значения функции Id-1 равным Id-2.*/
		/*WFC: Id-1 - первичная ф-я. Id_list, Id-2 - константы. WFC: количество и сортность аргументов.*/
              | e_m Id l_p Id_list r_p COLON Id e_m   {char* msg; char err_e[22]; int rc=a_p_f($2,$4,$7,1,err_e,&msg);
										if (rc!=0) printf("\n<:-(Can't assign const to f-n. rc=%i, msg=(%s), err_e=(%s). e_m-1>\n",rc,msg,err_e);} 
		/*КМАС. Задание значения функции Id-1 равным числу.*/
		/*WFC: Id-1 - первичная ф-я. Id_list - константы. WFC: количество и сортность аргументов.*/
              | e_m Id l_p Id_list r_p COLON Number e_m {char* msg; char err_e[22]; int rc=a_p_f($2,$4,$7,2,err_e,&msg);
										if (rc!=0) printf("\n<:-(Can't assign number to f-n. rc=%i, msg=(%s), err_e=(%s). e_m-2>\n",rc,msg,err_e);} 
		/*КМАС. Задание значения функции Id-1 равным строке.*/
		/*WFC: Id-1 - первичная ф-я. Id_list - константы. WFC: количество и сортность аргументов.*/
              | e_m Id l_p Id_list r_p COLON String e_m {char* msg; char err_e[22]; int rc=a_p_f($2,$4,$7,3,err_e,&msg);
										if (rc!=0) printf("\n<:-(Can't assign string to f-n rc=%i, msg=(%s), err_e=(%s). e_m-3>\n",rc,msg,err_e);} 
		/*КМАС. Запрос на значение терма и замкнутой формулы.*/
              | q_m term q_m /* WFC: классический терм - константный, формула - замкнутая.*/
	      | Proof Id derived_formula Dot 	/*Id - имя теоремы! Может быть несколько доказательств одной и той же теоремы!, т.е. это не ПК!*/
              | Theorem Id term Dot 		/*WFC: term - замкнутая формула*/
	|error Dot	{printf("\n<SA BAD_Statement='%s'>\n",$1);}
;
/*WFC. Id на каждой совокупности (аксиом, гипотез, теорем) уникален. */
/*<EBNF>Statements:Statement+. +У:А почему push?*/
Statements :  Statement | Statements Statement;


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
