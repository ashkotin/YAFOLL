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
"=" {/*eq = [=]*/ 	printf("eq %s\n",yytext);}
"." {/*Dot = [.]*/ 	printf("Dot %s\n",yytext);}
"," {/*COMMA = [,]*/ 	printf("COMMA %s\n",yytext);}
":" {/*COLON = [:]*/ 	printf("COLON %s\n",yytext);}
"(" {/*l_p = [(]*/ 	printf("l_p %s\n",yytext);}
")" {/*r_p = [)]*/ 	printf("r_p %s\n",yytext);}
"!" {/*e_m = [!]*/ 	printf("e_m %s\n",yytext);}
"?" {/*q_m = [?]*/ 	printf("q_m %s\n",yytext);}
"+" {/*Plus = [+]*/ 	printf("Plus %s\n",yytext);}
"-" {/*Minus = [-]*/ 	printf("Minus %s\n",yytext);}
"\*" {/*Multiply =[*]*/ printf("Multiply %s\n",yytext);}
"Ex" {/*EXISTS = 'Ex'*/ 	printf("EXISTS %s\n",yytext);}
"Any" {/*FOR_ANY = 'Any'*/ 	printf("FOR_ANY %s\n",yytext);}
"not" {/*NOT = 'not'*/ 		printf("NOT %s\n",yytext);}
"and" {/*AND = 'and'*/ 		printf("AND %s\n",yytext);}
"or" {/*OR = 'or'*/ 		printf("OR %s\n",yytext);}
"impl" {/*IMPLIES = 'impl'*/ 	printf("IMPLIES %s\n",yytext);}
"eqv" {/*EQUIV = 'eqv'*/ 	printf("EQUIV %s\n",yytext);} 
"neq" {/*Neq    = 'neq'*/ 	printf("Neq %s\n",yytext);}
"Declaration" {/*Declaration = 'Declaration'*/ 	printf("Declaration %s\n",yytext);}
"sort" {/*sort = 'sort'*/ 	printf("sort %s\n",yytext);}
"constant" {/*constant = 'constant'*/ 	printf("constant %s\n",yytext);}
"function" {/*function = 'function'*/ 	printf("function %s\n",yytext);}
"predicate" {/*predicate = 'predicate'*/ 	printf("predicate %s\n",yytext);}
"Axiom" {/*Axiom = 'Axiom'*/ 	printf("Axiom %s\n",yytext);}
"Definition" {/*Definition = 'Definition'*/ 	printf("Definition %s\n",yytext);}
"LA1" {/*LA1 = 'LA1'*/ 	printf("LA1 %s\n",yytext);}
"LA2" {/*LA2 = 'LA2'*/ 	printf("LA2 %s\n",yytext);}
"LA3" {/*LA3 = 'LA3'*/ 	printf("LA3 %s\n",yytext);}
"LA4" {/*LA4 = 'LA4'*/ 	printf("LA4 %s\n",yytext);}
"LA5" {/*LA5 = 'LA5'*/ 	printf("LA5 %s\n",yytext);}
"MP" {/*MP = 'MP'*/ 	printf("MP %s\n",yytext);}
"Gen" {/*Gen = 'Gen'*/ 	printf("Gen %s\n",yytext);}
"Proof" {/*Proof = 'Proof'*/ 	printf("Proof %s\n",yytext);}
"Hypothesis" {/*Hypothesis = 'Hypothesis'*/ 	printf("Hypothesis %s\n",yytext);}
"Theorem" {/*Theorem = 'Theorem'*/ 	printf("Theorem %s\n",yytext);}
"functor" {/*functor = 'functor'*/ 	printf("functor %s\n",yytext);}
"predicator" {/*predicator = 'predicator'*/ 	printf("predicator %s\n",yytext);}
{LCL}+{DIGIT}+ {/*Id     = {Letter}({AlphaNumeric}|_)**/ 	printf("Id %s\n",yytext);} 
[-+]?{DIGIT}+({Dot}{DIGIT}+)?  {/*Number = [-+]?{Digit}+(Dot{Digit}+)? !Величина сорта r.*/ 	printf("Number %s\n",yytext);}
[ \n]+			{/* пробелы и eol */				printf("WS %s\n",yytext);} 
"\-\-".*"\n" {/* комментарий до конца строки */					printf("Comm %s",yytext);} 
.			{	printf("Unrecognized character: <%s>\n",yytext);}
%%
/**/