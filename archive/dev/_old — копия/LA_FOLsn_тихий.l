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
"\xE2\x88\x83" {/*EXISTS UTF-8*/ 	return EXISTS;}
"\xE2\x88\x80" {/*FOR_ANY UTF-8*/ 	return FOR_ANY;}
"\xc2\xac"     {/*NOT UTF-8*/ 		return NOT;}
"\xe2\x88\xa7" {/*AND UTF-8*/ 		return AND;}
"\xe2\x88\xa8" {/*OR UTF-8*/ 		return OR;}
"\xe2\x86\x92" {/*IMPLIES UTF-8*/ 	return IMPLIES;}
"\xe2\x89\xa1" {/*EQUIV UTF-8*/ 	return EQUIV;}
"\xe2\x89\xa0" {/*Neq UTF-8*/ 		return Neq;}
"\xEF\xBB\xBF" {/*WS UTF-8*/ 		return WS BOM;}
"=" {/*eq = [=]*/ 	return ;}
"." {/*Dot = [.]*/ 	return ;}
"," {/*COMMA = [,]*/ 	return ;}
":" {/*COLON = [:]*/ 	return ;}
"(" {/*l_p = [(]*/ 	return ;}
")" {/*r_p = [)]*/ 	return ;}
"!" {/*e_m = [!]*/ 	return ;}
"?" {/*q_m = [?]*/ 	return ;}
"+" {/*Plus = [+]*/ 	return ;}
"-" {/*Minus = [-]*/ 	return ;}
"\*" {/*Multiply =[*]*/ return ;}
"Ex" {/*EXISTS = 'Ex'*/ 	return ;}
"Any" {/*FOR_ANY = 'Any'*/ 	return ;}
"not" {/*NOT = 'not'*/ 		return ;}
"and" {/*AND = 'and'*/ 		return ;}
"or" {/*OR = 'or'*/ 		return ;}
"impl" {/*IMPLIES = 'impl'*/ 	return ;}
"eqv" {/*EQUIV = 'eqv'*/ 	return ;} 
"neq" {/*Neq    = 'neq'*/ 	return ;}
"Declaration" {/*Declaration = 'Declaration'*/ 	return ;}
"sort" {/*sort = 'sort'*/ 			return ;}
"constant" {/*constant = 'constant'*/ 		return ;}
"function" {/*function = 'function'*/ 		return ;}
"predicate" {/*predicate = 'predicate'*/ 	return ;}
"Axiom" {/*Axiom = 'Axiom'*/ 			return ;}
"Definition" {/*Definition = 'Definition'*/ 	return ;}
"LA1" {/*LA1 = 'LA1'*/ 	return ;}
"LA2" {/*LA2 = 'LA2'*/ 	return ;}
"LA3" {/*LA3 = 'LA3'*/ 	return ;}
"LA4" {/*LA4 = 'LA4'*/ 	return LA4;}
"LA5" {/*LA5 = 'LA5'*/ 	return LA5;}
"MP" {/*MP = 'MP'*/ 	return MP;}
"Gen" {/*Gen = 'Gen'*/ 	return Gen;}
"Proof" {/*Proof = 'Proof'*/ 			return Proof;}
"Hypothesis" {/*Hypothesis = 'Hypothesis'*/ 	return Hypothesis;}
"Theorem" {/*Theorem = 'Theorem'*/ 		return Theorem;}
"functor" {/*functor = 'functor'*/ 		return ;}
"predicator" {/*predicator = 'predicator'*/ 	return predicator;}
({LCL}|{LSL})({LCL}|{LSL}|{DIGIT}|"_")* {/*Id     = {Letter}({AlphaNumeric}|_)**/ 		return ;} 
[-+]?{DIGIT}+({Dot}{DIGIT}+)?  {/*Number = [-+]?{Digit}+(Dot{Digit}+)? !Величина сорта r.*/ 	return ;}
[ \t\n]+			{/*WS пробелы и eol */						return ;} 
"\-\-".*"\n" {/*Comm комментарий до конца строки */						return ;} 
.			{	/*лексическая ошибка!!! - неизвестная буква (байт)*/		return <%s>",yytext);}
%%
/**/