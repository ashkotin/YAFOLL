/* задание на вызываемый сканер Y!L*/
/*вход выдаётся целиком на stdout.
  !!!Вся UTF-8 обработка ведётся только здесь! СА об этом ничего не знает!!!
  BOM, WS, Comment не возвращают token. BAD_STRING - обработчик ошибки.
  1. В этой версии русские UTF-8 буквы допускаются.
*/
/*%option main*/
%option noyywrap 
/*РЯ буквы UTF-8 (см. гу-док Unicode)*/
RCL		"\xd0\x81"|("\xd0"([\x90-\xaf]))
RSL		"\xd1\x91"|("\xd0"([\xb0-\xbf]))|("\xd1"([\x80-\x8f]))
/*здесь в отдельную сборку выделены РВ задающие множества букв (кроме Lttr из-за РЯ, хотя логически это буквы;-). По идее не пересекающиеся!*/
LCL		[QWERTYUIOPASDFGHJKLZXCVBNM]
LSL		[qwertyuiopasdfghjklzxcvbnm]
Lttr	{LCL}|{LSL}|{RCL}|{RSL}
DIGIT	[0-9]
DOT     [.]
US		[_]
MI		[-]
ws		[ ]
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
PCT		[%]
TAB		"\x09"
EOL		"\x0A"
CR		"\x0D"
DQ		"\x22"
/*РВ для BOM и UTF-8 спец-букв...*/
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
FIX {NOT}|{AND}|{OR}|{IMPLIES}|{EQUIV}|{Neq}|{Leq}|{Geq}|{EQ}|{LT}|{GT}|{PL}|{MI}|{ST}|{DI}
WS ({ws}|{TAB}|{EOL}|{CR})+
Comment {MI}{MI}.*{EOL}
Id {FIX}|{Lttr}({Lttr}|{DIGIT}|{US})*
Ide {US}{Lttr}({Lttr}|{DIGIT}|{US})*
NN {DIGIT}+
RNp {NN}({DOT}{NN})?
/*онтологические РВ для правила _trmRE*/
String {DQ}[^"]*{DQ}
RN {MI}?{RNp}{PCT}?
Year {NN}"y"
%%
{BOM}		 						{printf("%s",yytext);/*UTF-8 BOM*/}
{WS} 								{printf("%s",yytext);/*WS пробелы, TAB и eol */} 
{Comment}						    {printf("%s",yytext); /*пропускаемый комментарий до конца строки */} 
{String}							{printf("%s",yytext); /*храним без обрамляющих кавычек*/yylval=to_buff(yytext+1,strlen(yytext)-2); return String;}
{RN}		  	   					{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return Number;}
{Year}		  	   					{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return Year;}
{EXISTS}	 						{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return EXISTS;/*EXISTS UTF-8*/}
{FOR_ANY}	 						{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return FOR_ANY;/*FOR_ANY UTF-8*/}
{DOT} 			 					{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return Dot;}
{COMMA}								{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return COMMA;/*пока используется только в правилах вывода!*/}
{COLON}								{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return COLON;}
{l_p}  								{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return l_p;}
{r_p} 								{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return r_p;}
{e_m} 								{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return e_m;}
{q_m} 								{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return q_m;}
"Declaration"  						{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return DECLARATION;}
"sort"  							{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return sort;}
"definition"  						{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return DEFINITION;}
"prime" 			 				{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return PRIME;}
"LA1" 								{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return LA1;}
"LA2" 								{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return LA2;}
"LA3" 								{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return LA3;}
"LA4" 								{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return LA4;}
"LA5" 								{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return LA5;}
"MP" 								{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return MP;}
"Gen" 								{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return Gen;}
"Proof" 							{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return Proof;}
{Id}								{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return Id;} 
{Ide}								{printf("%s",yytext); yylval=to_buff(yytext,strlen(yytext));return Ide;} 
.								   	{int lng=strlen(yytext); char ltt=*yytext; printf("<LA BAD_STRING lng=%i, lttHEX=%X, val=%s>",lng,ltt,yytext); /*ошибка: - неизвестная буква (байт)*/}
%%
/*Замечания
  1. Си-действие ({...) должно начинаться в той же строке что и РВ-правило!
  2. ид РВ (множеств букв...) и лексических нт (token) могут совпадать - они из разных пространств имён.
*/