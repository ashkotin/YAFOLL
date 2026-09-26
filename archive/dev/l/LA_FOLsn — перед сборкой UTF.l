/* задание на вызываемый сканер Y!L*/
/*вход выдаётся целиком на stdout.
  9-ая (BOM) и три последних РВ (WS, Comment, BAD_BYTE) не возвращают token.
  1. В этой версии русские буквы не используются
     +прописать диапазоны русских букв для UTF-8 (см. гдок Unicode)
	 !!!Вля UTF-8 обработка ведётся только здесь СА об этом ничего не знает!!!
*/
/*%option main*/
%option noyywrap 
RCL	[АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ]
RSL	[абвгдеёжзийклмнопрстуфхцчшщъыьэюя]
LCL	[QWERTYUIOPASDFGHJKLZXCVBNM]
LSL	[qwertyuiopasdfghjklzxcvbnm]
DIGIT	[0-9]
Dot     [.]
%%
"\xE2\x88\x83" {/*EXISTS UTF-8*/ 	printf("%s",yytext); yylval=to_buff(yytext);return EXISTS;}
"\xE2\x88\x80" {/*FOR_ANY UTF-8*/ 	printf("%s",yytext); yylval=to_buff(yytext);return FOR_ANY;}
"\xc2\xac"     {/*NOT UTF-8*/ 		printf("%s",yytext); yylval=to_buff(yytext);return INFIX;}
"\xe2\x88\xa7" {/*AND UTF-8*/ 		printf("%s",yytext); yylval=to_buff(yytext);return INFIX;}
"\xe2\x88\xa8" {/*OR UTF-8*/ 		printf("%s",yytext); yylval=to_buff(yytext);return INFIX;}
"\xe2\x86\x92" {/*IMPLIES UTF-8*/ 	printf("%s",yytext); yylval=to_buff(yytext);return INFIX;}
"\xe2\x89\xa1" {/*EQUIV UTF-8*/ 	printf("%s",yytext); yylval=to_buff(yytext);return INFIX;}
"\xe2\x89\xa0" {/*Neq UTF-8*/ 		printf("%s",yytext); yylval=to_buff(yytext);return INFIX;}
"\xe2\x89\xa4" {/*Leq UTF-8*/ 		printf("%s",yytext); yylval=to_buff(yytext);return INFIX;}
"\xe2\x89\xa5" {/*Geq UTF-8*/ 		printf("%s",yytext); yylval=to_buff(yytext);return INFIX;}
"\xEF\xBB\xBF" {/*WS UTF-8 BOM*/ 	printf("%s",yytext); }
"="|"<"|">"|"+"|"-"|"\*"|"/"|"not"|"and"|"or"|"impl"|"eqv"|"neq" {printf("%s",yytext); yylval=to_buff(yytext);return INFIX;}
"." {/*Dot = [.]*/ 					printf("%s",yytext); yylval=to_buff(yytext);return Dot;}
"," {/*COMMA = [,]*/ 				printf("%s",yytext); yylval=to_buff(yytext);return COMMA;}
":" {/*COLON = [:]*/ 				printf("%s",yytext); yylval=to_buff(yytext);return COLON;}
"(" {/*l_p = [(]*/ 					printf("%s",yytext); yylval=to_buff(yytext);return l_p;}
")" {/*r_p = [)]*/ 					printf("%s",yytext); yylval=to_buff(yytext);return r_p;}
"!" {/*e_m = [!]*/ 					printf("%s",yytext); yylval=to_buff(yytext);return e_m;}
"?" {/*q_m = [?]*/ 					printf("%s",yytext); yylval=to_buff(yytext);return q_m;}
"Exs" {/*EXISTS = 'Ex'*/ 			printf("%s",yytext); yylval=to_buff(yytext);return EXISTS;}
"Any" {/*FOR_ANY = 'Any'*/ 			printf("%s",yytext); yylval=to_buff(yytext);return FOR_ANY;}
"Declaration" {/*Declaration*/ 		printf("%s",yytext); yylval=to_buff(yytext);return DECLARATION;}
"sort" {/*sort = 'sort'*/ 			printf("%s",yytext); yylval=to_buff(yytext);return sort;}
"constant" {/*constant*/ 			printf("%s",yytext); yylval=to_buff(yytext);return constant;}
"function" {/*function*/ 			printf("%s",yytext); yylval=to_buff(yytext);return function;}
"predicate" {/*predicate*/ 			printf("%s",yytext); yylval=to_buff(yytext);return predicate;}
"Axiom" {/*Axiom = 'Axiom'*/ 		printf("%s",yytext); yylval=to_buff(yytext);return Axiom;}
"Definition" {/*Definition*/ 		printf("%s",yytext); yylval=to_buff(yytext);return DEFINITION;}
"prime" {			 				printf("%s",yytext); yylval=to_buff(yytext);return PRIME;}
"infix" {			 				printf("%s",yytext); yylval=to_buff(yytext);return infix;}
"Add" {				 				printf("%s",yytext); yylval=to_buff(yytext);return Add;}
"to" {								printf("%s",yytext); yylval=to_buff(yytext);return to;}
"LA1" {/*LA1 = 'LA1'*/ 				printf("%s",yytext); yylval=to_buff(yytext);return LA1;}
"LA2" {/*LA2 = 'LA2'*/ 				printf("%s",yytext); yylval=to_buff(yytext);return LA2;}
"LA3" {/*LA3 = 'LA3'*/ 				printf("%s",yytext); yylval=to_buff(yytext);return LA3;}
"LA4" {/*LA4 = 'LA4'*/ 				printf("%s",yytext); yylval=to_buff(yytext);return LA4;}
"LA5" {/*LA5 = 'LA5'*/ 				printf("%s",yytext); yylval=to_buff(yytext);return LA5;}
"MP" {/*MP = 'MP'*/ 				printf("%s",yytext); yylval=to_buff(yytext);return MP;}
"Gen" {/*Gen = 'Gen'*/ 				printf("%s",yytext); yylval=to_buff(yytext);return Gen;}
"Proof" {/*Proof = 'Proof'*/ 		printf("%s",yytext); yylval=to_buff(yytext);return Proof;}
"Hypothesis" {/*Hypothesis*/ 		printf("%s",yytext); yylval=to_buff(yytext);return Hypothesis;}
"Theorem" {/*Theorem = 'Theorem'*/ 	printf("%s",yytext); yylval=to_buff(yytext);return Theorem;}
"functor" {/*functor = 'functor'*/ 	printf("%s",yytext); yylval=to_buff(yytext);return functor;}
"predicator" {/*predicator*/ 		printf("%s",yytext); yylval=to_buff(yytext);return predicator;}
({LCL}|{LSL})({LCL}|{LSL}|{DIGIT}|"_")* {/*Id = {Letter}({AlphaNumeric}|_)**/ 			printf("%s",yytext); yylval=to_buff(yytext); return Id;} 
[-+]?{DIGIT}+({Dot}{DIGIT}+)?  {/*Number !Величина сорта R.*/ 							printf("%s",yytext); yylval=to_buff(yytext); return Number;}
["][^"]*["]  {/*String*/			printf("%s",yytext); char str[1022]; strncpy(str,yytext+1,strlen(yytext)-2);/*добавляем Null:*/str[strlen(yytext)-2]=0;
														 yylval=to_buff(str); return String;}
[ \t\n]+ {/*WS пробелы и eol */		printf("%s",yytext);} 
"\-\-".*"\n" 					   {printf("%s",yytext); /*комментарий до конца строки */} 
.								   {printf("<LA BAD_BYTE=%s>",yytext); /*лексическая ошибка!!! - неизвестная буква (байт)*/}
%%
/**/