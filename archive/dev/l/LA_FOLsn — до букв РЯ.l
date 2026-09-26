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
/*РВ для BOM и UTF-8 спец-букв*/
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
/*РВ для или перед обработкой*/
FIX "neq"|"leq"|"geq"|"not"|"and"|"or"|"impl"|"eqv"|{NOT}|{AND}|{OR}|{IMPLIES}|{EQUIV}|{Neq}|{Leq}|{Geq}|{EQ}|{LT}|{GT}|{PL}|{MI}|{ST}|{DI}
WS ({ws}|{TAB}|{EOL})+
Comment {MI}{MI}.*{EOL}
Id {Lttr}({Lttr}|{DIGIT}|{US})*
Ide {US}{Id}
NN {DIGIT}+
RNp {NN}({DOT}{NN})?
/*онтологические РВ для правила _trmRE*/
String {DQ}[^"]*{DQ}
RN {MI}?{RNp}
Year {NN}"y"
%%
{BOM}		 						{printf("%s",yytext);/*UTF-8 BOM*/}
{WS} 								{printf("%s",yytext);/*WS пробелы, TAB и eol */} 
{Comment}						    {printf("%s",yytext); /*пропускаемый комментарий до конца строки */} 
{String}							{printf("%s",yytext); char str[1022]; strncpy(str,yytext+1,strlen(yytext)-2);/*add Null:*/str[strlen(yytext)-2]=0; yylval=to_buff(str); return String;}
{RN}		  	   					{printf("%s",yytext); yylval=to_buff(yytext);return Number;}
{Year}		  	   					{printf("%s",yytext); yylval=to_buff(yytext);return Year;}
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
"Definition"  						{printf("%s",yytext); yylval=to_buff(yytext);return DEFINITION;}
"prime" 			 				{printf("%s",yytext); yylval=to_buff(yytext);return PRIME;}
"fix" 			 					{printf("%s",yytext); yylval=to_buff(yytext);return fix;}
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
{FIX}								{printf("%s",yytext); yylval=to_buff(yytext);return FIX;}
{Id}								{printf("%s",yytext); yylval=to_buff(yytext);return Id;} 
{Ide}								{printf("%s",yytext); yylval=to_buff(yytext);return Ide;} 
.								   	{int lng=strlen(yytext); char ltt=*yytext; printf("<LA BAD_STRING lng=%i, lttHEX=%X, val=%s>",lng,ltt,yytext); /*ошибка: - неизвестная буква (байт)*/}
%%
/*Замечания
  1. Си-действие ({...) должно начинаться в той же строке что и РВ-правило!
  2. ид РВ (множеств букв...) и лексических нт (token) могут совпадать - они из разных пространств имён.
*/