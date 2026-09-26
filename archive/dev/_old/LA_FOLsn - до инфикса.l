/* задание на вызываемый сканер Y!L*/
/*вход выдаётся целиком на stdout.
  9-ая (BOM) и три последних РВ (WS, Comment, BAD_BYTE) не возвращают token.
*/
/*%option main*/
%option noyywrap 
RCL	[АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ]
RSL	[абвгдеёжзийклмнопрстуфхцчшщъыьэюя]
LCL	[QWERTYUIOPASDFGHJKLZXCVBNM]
LSL	[qwertyuiopasdfghjklzxcvbnm]
DIGIT	[0-9]
Dot     [.]
DQ ["]
%%
"\xE2\x88\x83" {/*EXISTS UTF-8*/ 	printf("%s",yytext); return EXISTS;}
"\xE2\x88\x80" {/*FOR_ANY UTF-8*/ 	printf("%s",yytext); return FOR_ANY;}
"\xc2\xac"     {/*NOT UTF-8*/ 		printf("%s",yytext); return NOT;}
"\xe2\x88\xa7" {/*AND UTF-8*/ 		printf("%s",yytext); return AND;}
"\xe2\x88\xa8" {/*OR UTF-8*/ 		printf("%s",yytext); return OR;}
"\xe2\x86\x92" {/*IMPLIES UTF-8*/ 	printf("%s",yytext); return IMPLIES;}
"\xe2\x89\xa1" {/*EQUIV UTF-8*/ 	printf("%s",yytext); return EQUIV;}
"\xe2\x89\xa0" {/*Neq UTF-8*/ 		printf("%s",yytext); return Neq;}
"\xe2\x89\xa4" {/*Leq UTF-8*/ 		printf("%s",yytext); return Leq;}
"\xe2\x89\xa5" {/*Geq UTF-8*/ 		printf("%s",yytext); return Geq;}
"\xEF\xBB\xBF" {/*WS UTF-8 BOM*/ 		printf("%s",yytext); }
"=" {/*eq = [=]*/ 	printf("%s",yytext); return eq;}
"." {/*Dot = [.]*/ 	printf("%s",yytext); return Dot;}
"," {/*COMMA = [,]*/ 	printf("%s",yytext); return COMMA;}
":" {/*COLON = [:]*/ 	printf("%s",yytext); return COLON;}
"(" {/*l_p = [(]*/ 	printf("%s",yytext); return l_p;}
")" {/*r_p = [)]*/ 	printf("%s",yytext); return r_p;}
"!" {/*e_m = [!]*/ 	printf("%s",yytext); return e_m;}
"?" {/*q_m = [?]*/ 	printf("%s",yytext); return q_m;}
"+" {/*Plus = [+]*/ 	printf("%s",yytext); return Plus;}
"-" {/*Minus = [-]*/ 	printf("%s",yytext); return Minus;}
"\*" {/*Multiply =[*]*/ printf("%s",yytext); return Multiply;}
"Ex" {/*EXISTS = 'Ex'*/ 	printf("%s",yytext); return EXISTS;}
"Any" {/*FOR_ANY = 'Any'*/ 	printf("%s",yytext); return FOR_ANY;}
"not" {/*NOT = 'not'*/ 		printf("%s",yytext); return NOT;}
"and" {/*AND = 'and'*/ 		printf("%s",yytext); return AND;}
"or" {/*OR = 'or'*/ 		printf("%s",yytext); return OR;}
"impl" {/*IMPLIES = 'impl'*/ 	printf("%s",yytext); return IMPLIES;}
"eqv" {/*EQUIV = 'eqv'*/ 	printf("%s",yytext); return EQUIV;} 
"neq" {/*Neq    = 'neq'*/ 	printf("%s",yytext); return Neq;}
"Declaration" {/*Declaration = 'Declaration'*/ 	printf("%s",yytext); return DECLARATION;}
"sort" {/*sort = 'sort'*/ 			printf("%s",yytext); return sort;}
"constant" {/*constant = 'constant'*/ 		printf("%s",yytext); return constant;}
"function" {/*function = 'function'*/ 		printf("%s",yytext); return function;}
"predicate" {/*predicate = 'predicate'*/ 	printf("%s",yytext); return predicate;}
"Axiom" {/*Axiom = 'Axiom'*/ 			printf("%s",yytext); return Axiom;}
"Definition" {/*Definition = 'Definition'*/ 	printf("%s",yytext); return DEFINITION;}
"prime" {/*НЕТ В GP!*/ 	printf("%s",yytext); return PRIME;}
"LA1" {/*LA1 = 'LA1'*/ 	printf("%s",yytext); return LA1;}
"LA2" {/*LA2 = 'LA2'*/ 	printf("%s",yytext); return LA2;}
"LA3" {/*LA3 = 'LA3'*/ 	printf("%s",yytext); return LA3;}
"LA4" {/*LA4 = 'LA4'*/ 	printf("%s",yytext); return LA4;}
"LA5" {/*LA5 = 'LA5'*/ 	printf("%s",yytext); return LA5;}
"MP" {/*MP = 'MP'*/ 	printf("%s",yytext); return MP;}
"Gen" {/*Gen = 'Gen'*/ 	printf("%s",yytext); return Gen;}
"Proof" {/*Proof = 'Proof'*/ 			printf("%s",yytext); return Proof;}
"Hypothesis" {/*Hypothesis = 'Hypothesis'*/ 	printf("%s",yytext); return Hypothesis;}
"Theorem" {/*Theorem = 'Theorem'*/ 		printf("%s",yytext); return Theorem;}
"functor" {/*functor = 'functor'*/ 		printf("%s",yytext); return functor;}
"predicator" {/*predicator = 'predicator'*/ 	printf("%s",yytext); return predicator;}
({LCL}|{LSL})({LCL}|{LSL}|{DIGIT}|"_")* {/*Id = {Letter}({AlphaNumeric}|_)**/ 			printf("%s",yytext); yylval=to_buff(yytext); return Id;} 
[-+]?{DIGIT}+({Dot}{DIGIT}+)?  {/*Number !Величина сорта R.*/ 	printf("%s",yytext); yylval=to_buff(yytext); return Number;}
{DQ}.*{DQ}  {/*String !Величина сорта S.*/ 	printf("%s",yytext); char str[1022]; strncpy(str,yytext+1,strlen(yytext)-2);
			 /*добавляем Null:*/str[strlen(yytext)-2]=0; yylval=to_buff(str); return String;}
[ \t\n]+			{/*WS пробелы и eol */						printf("%s",yytext); } 
"\-\-".*"\n" {/*Comm комментарий до конца строки */						printf("%s",yytext); } 
.			{	/*лексическая ошибка!!! - неизвестная буква (байт)*/		printf("<LA BAD_BYTE=%s>",yytext); }
%%
/**/