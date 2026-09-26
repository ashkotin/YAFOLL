/*шаблон СА*/
%{
#define YYSTYPE char* /*тип атрибута дерева - строка букв (НЕ ПРОХОДИТ: char [255])*/
#define YYMAXDEPTH 500000 /* максимальная глубина стека. по умолчнанию - 10000.*/
#define YYDEBUG 1 /*включение кода трассы*/
#include <stdio.h>
#include <stdlib.h>
FILE *LAout; /*ЛА. файл выдачи. для выделения цепочек слов */
int yylex (void); /*ЛА. объявление*/
int yydebug; /*переменная управления трассой*/
void yyerror (char const *);/*СА. объявление ф-и обработки синт- ошибки. см. её тело в конце.*/
/*динамический буфер значения атрибута-строки*/
YYSTYPE to_buff(char* in) {char* str_buff=malloc(256); sprintf(str_buff,"%s",in); return (str_buff);}
%}
/*%define lr.type "ielr" /*для 2.5 тип генерируемых таблиц ielr canonical-lr*/
%glr-parser	/*без него тоже не плохо;-)*/
/*каждая строка token соответствую строке РВ!*/
%token EXISTS
%token FOR_ANY
%token NOT
%token AND
%token OR
%token IMPLIES
%token EQUIV
%token Neq
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
/*%token WS*/
/*%token Comm*/

%start Theory

%%

/*FOLsn rules*/
/*Для списков сортов и форм- параметров определений.*/
Id_list : Id {sprintf($$,"%s",$1)}
| Id COMMA Id_list {sprintf($$,"%s,%s",$1,$3)}
;

/*Объявления*/
Declaration : DECLARATION Id sort Dot /*WFC: Вводится новый сорт Id.*/{printf("<New sort='%s'>",$2);}
               	| DECLARATION Id COLON Id constant Dot /*WFC: Вводится новая константа Id-1 сорта Id-2.*/
		/*WFC: Вводится новая функция Id-1. Id-2 - сорт возвращаемого значения. Id_list - список сортов аргументов.*/
		| DECLARATION Id COLON Id function Id_list Dot {printf("<function id='%s' sort='%s' id_list='%s'>",$2,$4,$6);}
               	| DECLARATION Id predicate Id_list Dot /*WFC: Вводится новый предикат Id. Id_list - список сортов аргументов.*/
/*WFC. Требование к совокупности деклараций (при любых расширениях!): все идентификаторы различны.*/
;

/*Терм*/
term : Id /*WFC. Id - константа или переменная (если в формуле).    */
         | Id l_p TermList r_p                     /*WFC: Id - функция. WFC: количество, сортность аргументов.*/
;
/*-------------Добавка для сорта r - рациональных чисел!*/
term : Number ;
term : l_p term Plus term r_p | l_p term Minus term r_p | l_p term Multiply term r_p;
TermList : term | term COMMA term;

/*Пропозициональная формула*/
/*С равенством!*/
pro_Formula  : l_p term eq term r_p | l_p term Neq term r_p         
               | Id l_p TermList r_p   /*WFC: Id - предикат в классике. С операторами добавляется предикатор. WFC: количество, сортность и тип аргументов.*/
               | NOT pro_Formula
               | l_p pro_Formula AND pro_Formula r_p
               | l_p pro_Formula OR pro_Formula r_p
               | l_p pro_Formula IMPLIES pro_Formula r_p
               | l_p pro_Formula EQUIV pro_Formula r_p
;
/*Пренексная формула*/
/*Список переменных приписанных сорту*/
Id_list_s : Id COLON Id /*Переменная Id-1 имеет сорт Id-2.*/
 | Id COLON Id COMMA Id_list_s  
;
/*WFC: все Id переменных различны. */
/*Кванторная часть пренексных формул.*/
Q_group : EXISTS Id_list_s | FOR_ANY Id_list_s;
Q_group_list : Q_group | Q_group Q_group_list;
/*WFC: все Id переменных различны. Они уже различны в пределах Id_list, но здесь надо в пределах Q_group_list.*/
pre_formula : Q_group_list pro_Formula;
/*WFC: все переменные из Q_group_list упоминаются в Formula И других переменных в Formula нет.*/

formula : pro_Formula | pre_formula;

Statement : Declaration
              | Axiom Id formula Dot /*WFC: формула замкнутая!*/
              | Id l_p Id_list r_p e_m    /*Задание значения предиката. WFC: Id - предикат. Id_list - константы. WFC: количество и сортность аргументов.*/
		/*Задание значения функции. WFC: Id-1 - функция. Id-2 - константа. Id_list - константы. WFC: количество и сортность аргументов.*/
              | Id l_p Id_list r_p eq Id e_m 
              | formula q_m /*Запрос на значение формулы. WFC: формула замкнутая. Имеется в виду вычисление на КМАС.*/
              | term q_m /*Запрос на значение терма. WFC: терм константный.*/
	|error Dot	{printf("<SA BAD_Statement='%s'>",$1);}
;
/*WFC. Id на каждой совокупности (аксиом, гипотез, теорем) уникален. */
/*WFC: formula - замкнута.*/

Statements : Statement Statements | Statement;
Theory : Statements;
/*конец Y!L-0*/


/*Определения*/
/*Id-1 - уникальный идентификатор определения. Id-2 - уникальный идентификатор определяемого.*/
Definition : DEFINITION Id Id constant term Dot /*WFC: "вызываемые" Id в терме должны быть константами.*/
    /*Функция термом с переменными из Id_list. !WFC: состав "вызываемых" Id в терме должен быть формальные параметры и, возможно, константы.*/
    |DEFINITION Id Id l_p Id_list r_p function term Dot    
    |DEFINITION Id Id l_p Id_list r_p predicate formula Dot    /* Предикат формулой с перем-. !WFC: свободные переменные pre_formula равны Id_list.*/
;
/*WFC: состав "вызываемых" Id в формуле для предиката должен быть формальные параметры, возможно константы и, если есть кванторы, то их переменные.*/
/*Требования к совокупности при любых расширениях:*/
/*WFC. Id определения уникален на определениях.*/
/*WFC. Id определяемого должен быть раньше задекларирован.*/
Statement : Definition;

/*-----------FOL(sd) end-----------*/

/*Выведенная формула*/
/*На выходе формула!*/
derived_formula : LA1 l_p formula COMMA formula r_p 	/*return A(BA)*/
 |LA2 l_p formula COMMA formula COMMA formula r_p 	/*return импли-формула*/
 |LA3 l_p formula COMMA formula r_p 			/*return импли-не-формула*/
 |LA4 l_p Id COMMA term COMMA formula r_p 			/*Id - переменная.*/
 |LA5 l_p Id COMMA formula COMMA formula r_p 		/*Id - переменная.*/
 |MP l_p derived_formula COMMA derived_formula r_p 		/*проверяет строение F2 и наличие в ней F1.*/
 |Gen l_p Id COMMA derived_formula r_p 			/*Id - переменная. ничего не проверяет.*/
 | Id 								/*WFC: Id - теоремы или прикладной аксиомы!*/
;
Statement : Proof Id derived_formula Dot 	/*Id - имя теоремы! Может быть несколько доказательств одной и той же теоремы!, т.е. это не ПК!*/
              /*| Hypothesis Id formula Dot /*Пожалуй это не нужно - теорема без доказательства и есть гипотеза;-)*/
              | Theorem Id formula Dot 
;

/*-------------Операторная добавка*/
/*Сигнатура предиката как аргумента - список сортов в скобках. Для строения аргументов операторов.*/
Id_list_in_br : l_p Id_list r_p ;
/*Вид аргументов оператора: к обычным добавляется предикат! */       
oper_args_type_list : Id | Id_list_in_br
| Id COMMA oper_args_type_list | Id_list_in_br COMMA oper_args_type_list 
;
/*WFC: Id - сорт.*/
/*Объявления операторов. */
   	      /*Вводится новый оператор Id возвращающий предикат. В Id_list - сорта аргументов предиката. oper_args_type_list - вид аргументов оператора.*/
Declaration : DECLARATION Id COLON l_p Id_list r_p functor oper_args_type_list Dot 
   /*Вводится новый оператор Id-1 возвращающий функцию. В Id_list - сорта аргументов функции. Id-2 - сорт возвращаемого функцией значения.*/
 | DECLARATION Id COLON l_p Id_list COLON Id r_p functor oper_args_type_list Dot /*oper_args_type_list - вид аргументов оператора.*/
   /*insert entities(id=Id,type="ff"). 
   --sig-1 - сигнатура результата функтора - функция.
     sig-1=new_sig. entities(Id).ref_r_sig=sig-1. sig-1.ref_r_sig=Id-2. -- там сорт!
     ?аргумент в Id_list один? T:sig-1.ref_arg_sig=Id_list. -- там один и сорт!
   --   sig-2 - сигнатура аргументов функции (результата функтора) - цепь сортов.
     F:{sig-2=new_sig. sig-1.ref_arg_sig=sig-2. построить по Id_list цепь в sig_seq ссылающуюся на sig-2 (ref_struct'ы ссылаются на сорта из Id_list!)}
   --!Обработка oper_args_type_list!
     см.г-док!
   */
 | DECLARATION Id  predicator oper_args_type_list Dot /*Вводится новый оператор Id возвращающий True|False. oper_args_type_list - вид аргументов оператора.*/
;
/*Терм операторный.         */
term :  Id l_p TermList r_p l_p TermList r_p;  /*WFC: Id - функтор возвращающий функцию. WFC: количество, сортность и тип аргументов.*/
/*Операторная формула.*/
pro_Formula  : Id l_p TermList r_p l_p TermList r_p;  /*WFC: Id - функтор возвращающий предикат. WFC: количество, сортность и тип аргументов.*/
/*Определения.*/
             /*функтор возвращающий функцию. Id_list-1 - формальные параметры ф-а. Id_list-2 - ф-и/предиката. WFC: форм параметры*/  
Definition : DEFINITION Id Id l_p Id_list r_p l_p Id_list r_p functor term Dot
            |DEFINITION Id Id l_p Id_list r_p l_p Id_list r_p functor formula Dot  /*функтор возвращающий предикат. WFC: форм параметры*/  
            |DEFINITION Id Id l_p Id_list r_p predicator formula Dot /*predicator*/
;

%%
/*ЛА. вставка Си его кода*/
#include "LA_FOLsn.c"
int main (void) 
{
/*ЛА. LAout = fopen("out/LAout.txt","w"); открытие файл выдачи.*/
 yydebug = 0;
 return yyparse ();/*СА. пуск*/
/*ЛА. fclose(LAout); закрытие файл выдачи.*/
}
void yyerror (char const *s) {printf ("<SA BAD_NEWS='%s'>", s);}
