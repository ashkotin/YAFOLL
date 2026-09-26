/* задание на автономный сканер Y!L*/
%option main
%option noyywrap 
RCL	[АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ]
RSL	[абвгдеёжзийклмнопрстуфхцчшщъыьэюя]
LCL	[QWERTYUIOPASDFGHJKLZXCVBNM]
LSL	[qwertyuiopasdfghjklzxcvbnm]
DIGIT	[0-9]
Dot     [.]
%%
"\xE2\x88\x83" {/*EXISTS UTF-8*/ 	printf("$EXISTS$");}
"\xE2\x88\x80" {/*FOR_ANY UTF-8*/ 	printf("$FOR_ANY$");}
"\xc2\xac"     {/*NOT UTF-8*/ 		printf("$NOT$");}
"\xe2\x88\xa7" {/*AND UTF-8*/ 		printf("$AND$");}
"\xe2\x88\xa8" {/*OR UTF-8*/ 		printf("$OR$");}
"\xe2\x86\x92" {/*IMPLIES UTF-8*/ 	printf("$IMPLIES$");}
"\xe2\x89\xa1" {/*EQUIV UTF-8*/ 	printf("$EQUIV$");}
"\xe2\x89\xa0" {/*Neq UTF-8*/ 		printf("$Neq$");}
"\xEF\xBB\xBF" {/*WS UTF-8*/ 		printf("$WS BOM$");}
"=" {/*eq = [=]*/ 	printf("%s",yytext);}
"." {/*Dot = [.]*/ 	printf("%s",yytext);}
"," {/*COMMA = [,]*/ 	printf("%s",yytext);}
":" {/*COLON = [:]*/ 	printf("%s",yytext);}
"(" {/*l_p = [(]*/ 	printf("%s",yytext);}
")" {/*r_p = [)]*/ 	printf("%s",yytext);}
"!" {/*e_m = [!]*/ 	printf("%s",yytext);}
"?" {/*q_m = [?]*/ 	printf("%s",yytext);}
"+" {/*Plus = [+]*/ 	printf("%s",yytext);}
"-" {/*Minus = [-]*/ 	printf("%s",yytext);}
"\*" {/*Multiply =[*]*/ printf("%s",yytext);}
"Ex" {/*EXISTS = 'Ex'*/ 	printf("%s",yytext);}
"Any" {/*FOR_ANY = 'Any'*/ 	printf("%s",yytext);}
"not" {/*NOT = 'not'*/ 		printf("%s",yytext);}
"and" {/*AND = 'and'*/ 		printf("%s",yytext);}
"or" {/*OR = 'or'*/ 		printf("%s",yytext);}
"impl" {/*IMPLIES = 'impl'*/ 	printf("%s",yytext);}
"eqv" {/*EQUIV = 'eqv'*/ 	printf("%s",yytext);} 
"neq" {/*Neq    = 'neq'*/ 	printf("%s",yytext);}
"Declaration" {/*Declaration = 'Declaration'*/ 	printf("%s",yytext);}
"sort" {/*sort = 'sort'*/ 			printf("%s",yytext);}
"constant" {/*constant = 'constant'*/ 		printf("%s",yytext);}
"function" {/*function = 'function'*/ 		printf("%s",yytext);}
"predicate" {/*predicate = 'predicate'*/ 	printf("%s",yytext);}
"Axiom" {/*Axiom = 'Axiom'*/ 			printf("%s",yytext);}
"Definition" {/*Definition = 'Definition'*/ 	printf("%s",yytext);}
"LA1" {/*LA1 = 'LA1'*/ 	printf("%s",yytext);}
"LA2" {/*LA2 = 'LA2'*/ 	printf("%s",yytext);}
"LA3" {/*LA3 = 'LA3'*/ 	printf("%s",yytext);}
"LA4" {/*LA4 = 'LA4'*/ 	printf("LA4 %s\n",yytext);}
"LA5" {/*LA5 = 'LA5'*/ 	printf("LA5 %s\n",yytext);}
"MP" {/*MP = 'MP'*/ 	printf("MP %s\n",yytext);}
"Gen" {/*Gen = 'Gen'*/ 	printf("Gen %s\n",yytext);}
"Proof" {/*Proof = 'Proof'*/ 			printf("Proof %s\n",yytext);}
"Hypothesis" {/*Hypothesis = 'Hypothesis'*/ 	printf("Hypothesis %s\n",yytext);}
"Theorem" {/*Theorem = 'Theorem'*/ 		printf("Theorem %s\n",yytext);}
"functor" {/*functor = 'functor'*/ 		printf("%s",yytext);}
"predicator" {/*predicator = 'predicator'*/ 	printf("predicator %s\n",yytext);}
({LCL}|{LSL})({LCL}|{LSL}|{DIGIT}|"_")* {/*Id     = {Letter}({AlphaNumeric}|_)**/ 		printf("%s",yytext);} 
[-+]?{DIGIT}+({Dot}{DIGIT}+)?  {/*Number = [-+]?{Digit}+(Dot{Digit}+)? !Величина сорта r.*/ 	printf("%s",yytext);}
[ \t\n]+			{/*WS пробелы и eol */						printf("%s",yytext);} 
"\-\-".*"\n" {/*Comm комментарий до конца строки */						printf("%s",yytext);} 
.			{	/*лексическая ошибка!!! - неизвестная буква (байт)*/		printf("<%s>",yytext);}
%%
/**/