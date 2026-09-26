/*шаблон СА*/
%{
#define YYSTYPE char* /*тип атрибута дерева - строка букв*/
#define YYMAXDEPTH 500000 /* максимальная глубина стека. по умолчнанию - 10000.*/
#define YYDEBUG 1 /*включение кода трассы*/
#include <stdio.h>
FILE *LAout; /*ЛА. файл выдачи. для выделения цепочек слов */
int yylex (void); /*ЛА. объявление*/
int yydebug; /*переменная управления трассой*/
void yyerror (char const *);/*СА. объявление ф-и обработки синт- ошибки. см. её тело в конце.*/
%}
/*%define lr.type "ielr" /*для 2.5 тип генерируемых таблиц ielr canonical-lr*/
%glr-parser	/*без него тоже не плохо;-)*/
%token RUS_NWF	/*имя собственное*/
%token RUS_CWF
%token RUS_SWF
%token LAT_CWF
%token LAT_SWF
%token RUS_I
%token LAT_I
%token ID /*идентификатор*/
%token OSF /* многоточие */
%token O_SF /*"!.."|"?.."*/
/*%token RARE_SF это редкие знакоформы см. ЛА*/
%token WS /* пробелы */

%start sentences

%%

Wf:	RUS_CWF|RUS_SWF| LAT_CWF|LAT_SWF|RUS_I|LAT_I| ID;
sWf:		RUS_SWF		|LAT_SWF|RUS_I|LAT_I| ID;

EoS	:'.' |'!' |'?' |OSF | O_SF;

sentences: sentence | sentences WS sentence;

sentence: 	 s_sentence	{printf("<l1_ss>\n");}
		|sse_seq WS dqc	{printf("<l1_ss_dqc$>\n");} /*умолчание точки!*/
/**************	|dqc		{printf("<???>\n");}   умолчание точки. даёт неоднозначность! из-за "-" и ds_sent-*/
		|ds_sentence	{printf("<l1_ds>\n");}
		|ds_seq WS dqc	{printf("<l1_ds_dqc$>\n");} /*умолчание точки!*/
		|error EoS	{printf("<BAD s>\n");}
;
s_sentence: 	 sse_seq EoS;
sse_seq: 	 RUS_CWF | RUS_CWF ',' | RUS_CWF ':' | RUS_CWF ';' | dqc | dqc ',' |RUS_NWF | RUS_NWF ','
		| ds_sentence WS '-' WS RUS_SWF 	/*предложение прямой речи - стартовый член ss!*/
		| ds_sentence WS '-' WS RUS_SWF ','	/*предложение прямой речи - стартовый член ss!*/
		| sse_seq WS sse
;
sse:	 sWf | sWf ':' | sWf ',' | sWf ';'
	|RUS_NWF  | RUS_NWF ':' | RUS_NWF ',' | RUS_NWF ';'
	|'-'
	| dqc | dqc ';' | dqc ','
	| brc | brc ';' | brc ','
;

cit_seq: 	 RUS_SWF | RUS_SWF ','
		| cit_seq WS ce
;
ce:	 Wf | Wf ':' | Wf ',' | Wf ';'
	|'-' 
;
s_seq:  s_sentence		{printf("<st_s>");}
	|ds_sentence
	|s_seq WS s_sentence
	|s_seq WS ds_sentence
;

dqc: 	 '"' dqc_txt '"'
	|'"' error '"'	{printf("<bad dqc>");}
;

brc: 	 '(' dqc_txt ')'
	|'(' error ')'	{printf("<bad brc>");}
;

dqc_txt: sse_seq 		{printf("<dqc_sse_seq>");} 
	|s_seq			{printf("<dqc_s_seq>");}
	|s_seq	WS sse_seq	{printf("<dqc_txt3>");}
	|s_seq	WS ds_seq	{printf("<dqc_txt4>");}
	|cit_seq		{printf("<dqc_cit1>");}
	|cit_seq EoS		{printf("<dqc_cit2>");}
;

ds_sentence:	 ds_seq EoS	/*direct speech sentence*/
		|ds_seq WS RUS_SWF ':' WS ds_sentence /*для обрубка*/
;
ds_seq:	 '-' WS RUS_CWF | '-' WS RUS_CWF ',' | '-' WS RUS_CWF ':' | '-' WS RUS_NWF | '-' WS RUS_NWF ','
	| ds_seq WS sse;


%%
/*ЛА. вставка Си его кода*/
#include "rusLAn.c"
int main (void) 
{
 LAout = fopen("out/LAout.txt","w");/*ЛА. открытие файл выдачи.*/
 yydebug = 0;
 return yyparse ();/*СА. пуск*/
 fclose(LAout);/*ЛА. закрытие файл выдачи.*/
}
void yyerror (char const *s) {printf ("<+++%s+++>", s);}
