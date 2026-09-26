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

%start Statements

%%

/*FOLsn-F rules*/
/*Для форм- параметров определений.*/
/*EBNF. Id_list : Id+ */
Id_list : Id {sprintf($$,"%s",$1)}
| Id Id_list {sprintf($$,"%s,%s",$1,$2)}
;
/*Синтаксис сигнатур*/
sig_f : sig_res COMMA sig_arg
sig_res : Id | l_p sig_f r_p /*WFC: Id - сорт.*/
/*<EBNF> sig_arg : (Id | l_p sig_f r_p)+*/
sig_arg : Id | l_p sig_f r_p 	/*WFC: Id - сорт.*/ 
 | Id sig_arg			/*WFC: Id - сорт.*/ 
 | l_p sig_f r_p sig_arg
;


/*Объявления*/
Declaration :	  DECLARATION Id sort Dot /*WFC: Вводится новый сорт Id.*/{printf("<New sort='%s'>",$2);}
               	| DECLARATION Id COLON Id constant Dot /*WFC: Вводится новая константа Id-1 сорта Id-2.*/
		/*WFC: Вводится новая функция Id */
		| DECLARATION Id sig_f Dot
/*WFC. Требование к совокупности деклараций (при любых расширениях!): все идентификаторы различны.*/
;

/*Терм*/
term :	  Id /*WFC. Id - константа или переменная (если в формуле).    */
	| Number 
        | Id l_p TermList r_p                   /*WFC: Id - функция. WFC: количество, сортность аргументов.*/
 	| l_p TermList r_p  l_p TermList r_p 	/*WFC: TermList возвращает функцию. WFC: количество, сортность аргументов.*/
	| Q_group_list term; /*сорт терма - TV*//*WFC: все переменные из Q_group_list упоминаются в term И других переменных в term нет.*/
;
TermList : term | term TermList ;

/*-------------Добавка для сорта r - рациональных чисел!*/
/*Синтаксический сахар для арифм- ф-й*/
/*term : l_p term Plus term r_p | l_p term Minus term r_p | l_p term Multiply term r_p;*/
/* +?А где деление??????????????????????????????????????????????????????????????????????????????????????*/

/*Пропозициональная формула*/
/*С равенством!*/
/*В F это терм возвращающий TV значение!!! Синт- сахар!!!*/
/*term  : l_p term eq term r_p | l_p term Neq term r_p         
               | NOT term
               | l_p term AND term r_p
               | l_p term OR term r_p
               | l_p term IMPLIES term r_p
               | l_p term EQUIV term r_p
;
*/
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

/*Определения*/
/*Id-1 - уникальный идентификатор определения. Id-2 - уникальный идентификатор определяемого.*/
Definition : DEFINITION Id Id constant term Dot /*WFC: "вызываемые" Id в терме должны быть константами.*/
    	/*Функция термом с переменными из Id_list.*/
	| DEFINITION Id Id l_p Id_list r_p COMMA term Dot /* !WFC: состав "вызываемых" Id в терме должен быть формальные параметры и, возможно, константы.*/   
;
/*WFC: состав "вызываемых" Id в формуле для предиката должен быть формальные параметры, возможно константы и, если есть кванторы, то их переменные.*/
/*Требования к совокупности при любых расширениях:*/
/*WFC. Id определения уникален на определениях.*/
/*WFC. Id определяемого должен быть раньше задекларирован.*/

/*Выведенная формула*/
/*На входе LA иногда термы но в основном формулы!*/
derived_formula : LA1 l_p term COMMA term r_p 	/*return A(BA). WFC:все термы - замкнутые формулы*/
 |LA2 l_p term COMMA term COMMA term r_p 	/*return импли-формула. WFC:все термы - замкнутые формулы*/
 |LA3 l_p term COMMA term r_p 			/*return импли-не-формула. WFC:все термы - замкнутые формулы*/
 |LA4 l_p Id COMMA term COMMA term r_p 			/*Id - переменная. WFC:term-1 - классический терм, term-2 - формула (какая?)*/
 |LA5 l_p Id COMMA term COMMA term r_p 		/*Id - переменная. WFC:все термы - замкнутые формулы*/
 |MP l_p derived_formula COMMA derived_formula r_p 		/*проверяет строение F2 и наличие в ней F1.*/
 |Gen l_p Id COMMA derived_formula r_p 			/*Id - переменная. ничего не проверяет.*/
 | Id 								/*WFC: Id - теоремы или прикладной аксиомы!*/
;

Statement : 	Declaration | Definition
              | Axiom Id term Dot /*WFC: формула замкнутая!*/
		/*КМАС. Задание значения функции предикатно: последний параметр - значение ф-и. Предикат задаётся как ф-я!*/
              | e_m Id l_p Id_list r_p e_m    /*WFC: Id - ф-я. Id_list - константы. WFC: количество и сортность аргументов.*/
		/*КМАС. Запрос на значение терма и замкнутой формулы.*/
              | q_m term q_m /* WFC: классический терм - константный, формула - замкнутая.*/
	      | Proof Id derived_formula Dot 	/*Id - имя теоремы! Может быть несколько доказательств одной и той же теоремы!, т.е. это не ПК!*/
              | Theorem Id term Dot 		/*WFC: term - замкнутая формула*/
	|error Dot	{printf("<SA BAD_Statement='%s'>",$1);}
;
/*WFC. Id на каждой совокупности (аксиом, гипотез, теорем) уникален. */

Statements :  Statement | Statement Statements;


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
