/* задание на вызываемый сканер Y!L*/
/*вход выдаётся целиком на stdout.
  !!!Вся UTF-8 обработка ведётся только здесь! СА об этом ничего не знает!!!
  BOM, WS, Comment не возвращают token. BAD_STRING - обработчик ошибки.
  1. В этой версии русские буквы не используются
     +прописать диапазоны русских букв для UTF-8 (см. гдок Unicode)
*/
/*%option main*/
%option noyywrap 
/*здесь в отдельную сборку выделены РВ задающие множества букв. По идее не пересекающиеся!*/
LCL		[QWERTYUIOPASDFGHJKLZXCVBNM]
LSL		[qwertyuiopasdfghjklzxcvbnm]
Lttr	{LCL}|{LSL}
DIGIT	[0-9]
DOT     [.]
US		[_]
MI		[-]
ws		[ ]
TAB		[\t]
EOL		[\n]
COMMA	[,]
COLON	[:]
l_p		[(]
r_p		[)]
e_m		[!]
q_m		[?]
EQ		[=]
LT		[<]
GT		[>]
PL		[+]
ST		[*]
DI		[/]
/*далее идут РВ для BOM и UTF-8 букв*/
DQ		"\x22"
BOM		"\xEF\xBB\xBF"
EXISTS	"\xE2\x88\x83"
FOR_ANY	"\xE2\x88\x80"
NOT		"\xc2\xac"
AND		"\xe2\x88\xa7"
OR		"\xe2\x88\xa8"
IMPLIES	"\xe2\x86\x92"
EQUIV	"\xe2\x89\xa1"
Neq		"\xe2\x89\xa0"
Leq		"\xe2\x89\xa4"
Geq		"\xe2\x89\xa5"
%%
{BOM}		 						{printf("%s",yytext);/*UTF-8 BOM*/}
({ws}|{TAB}|{EOL})+ 				{printf("%s",yytext);/*WS пробелы, TAB и eol */} 
{MI}{MI}.*{EOL}					    {printf("%s",yytext); /*Comment - пропускаемый комментарий до конца строки */} 
{DQ}[^"]*{DQ}						{printf("%s",yytext); char str[1022]; strncpy(str,yytext+1,strlen(yytext)-2);/*add Null:*/str[strlen(yytext)-2]=0; yylval=to_buff(str); return String;}
{MI}?{DIGIT}+({DOT}{DIGIT}+)?  	    {printf("%s",yytext); yylval=to_buff(yytext);return Number;}
{EXISTS}	 						{printf("%s",yytext); yylval=to_buff(yytext);return EXISTS;/*EXISTS UTF-8*/}
{FOR_ANY}	 						{printf("%s",yytext); yylval=to_buff(yytext);return FOR_ANY;/*FOR_ANY UTF-8*/}
{DOT} 			 					{printf("%s",yytext); yylval=to_buff(yytext);return Dot;}
{COMMA}								{printf("%s",yytext); yylval=to_buff(yytext);return COMMA;/*COMMA = [,]*/}
{COLON}								{printf("%s",yytext); yylval=to_buff(yytext);return COLON;}
{l_p}  								{printf("%s",yytext); yylval=to_buff(yytext);return l_p;}
{r_p} 								{printf("%s",yytext); yylval=to_buff(yytext);return r_p;}
{e_m} 								{printf("%s",yytext); yylval=to_buff(yytext);return e_m;}
{q_m} 								{printf("%s",yytext); yylval=to_buff(yytext);return q_m;}
"Declaration"  						{printf("%s",yytext); yylval=to_buff(yytext);return DECLARATION;}
"sort"  							{printf("%s",yytext); yylval=to_buff(yytext);return sort;}
"constant"  						{printf("%s",yytext); yylval=to_buff(yytext);return constant;}
"Axiom"  							{printf("%s",yytext); yylval=to_buff(yytext);return Axiom;}
"Definition"  						{printf("%s",yytext); yylval=to_buff(yytext);return DEFINITION;}
"prime" 			 				{printf("%s",yytext); yylval=to_buff(yytext);return PRIME;}
"infix" 			 				{printf("%s",yytext); yylval=to_buff(yytext);return infix;}
"Add" 				 				{printf("%s",yytext); yylval=to_buff(yytext);return Add;}
"to" 								{printf("%s",yytext); yylval=to_buff(yytext);return to;}
"LA1" 								{printf("%s",yytext); yylval=to_buff(yytext);return LA1;}
"LA2" 								{printf("%s",yytext); yylval=to_buff(yytext);return LA2;}
"LA3" 								{printf("%s",yytext); yylval=to_buff(yytext);return LA3;}
"LA4" 								{printf("%s",yytext); yylval=to_buff(yytext);return LA4;}
"LA5" 								{printf("%s",yytext); yylval=to_buff(yytext);return LA5;}
"MP" 								{printf("%s",yytext); yylval=to_buff(yytext);return MP;}
"Gen" 								{printf("%s",yytext); yylval=to_buff(yytext);return Gen;}
"Proof" 							{printf("%s",yytext); yylval=to_buff(yytext);return Proof;}
"Theorem" 							{printf("%s",yytext); yylval=to_buff(yytext);return Theorem;}
"neq"|"leq"|"geq"|"not"|"and"|"or"|"impl"|"eqv"			{printf("%s",yytext); yylval=to_buff(yytext);return INFIX;}
{NOT}|{AND}|{OR}|{IMPLIES}|{EQUIV}|{Neq}|{Leq}|{Geq}	{printf("%s",yytext); yylval=to_buff(yytext);return INFIX;}
{EQ}|{LT}|{GT}|{PL}|{MI}|{ST}|{DI}						{printf("%s",yytext); yylval=to_buff(yytext);return INFIX;}
{Lttr}({Lttr}|{DIGIT}|{US})*		{printf("%s",yytext); yylval=to_buff(yytext);return Id;} 
{US}{Lttr}({Lttr}|{DIGIT}|{US})*	{printf("%s",yytext); yylval=to_buff(yytext);return Ide;} 
.								   	{int lng=strlen(yytext); char ltt=*yytext; printf("<LA BAD_STRING lng=%i, lttHEX=%X, val=%s>",lng,ltt,yytext); /*ошибка: - неизвестная буква (байт)*/}
%%
/*Замечания
  1. Си-действие ({...) должно начинаться в той же строке что и РВ-правило!
  2. ид РВ (множеств букв...) и лексических нт (token) могут совпадать - они из разных пространств имён.
*/