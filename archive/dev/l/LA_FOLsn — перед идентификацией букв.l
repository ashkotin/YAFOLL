/* задание на вызываемый сканер Y!L*/
/*вход выдаётся целиком на stdout.
  !!!Вся UTF-8 обработка ведётся только здесь! СА об этом ничего не знает!!!
  BOM, WS, Comment не возвращают token. BAD_STRING - обработчик ошибки.
  1. В этой версии русские буквы не используются
     +прописать диапазоны русских букв для UTF-8 (см. гдок Unicode)
*/
/*%option main*/
%option noyywrap 
LCL	[QWERTYUIOPASDFGHJKLZXCVBNM]
LSL	[qwertyuiopasdfghjklzxcvbnm]
DIGIT	[0-9]
Dot     [.]
%%
"\xEF\xBB\xBF" 						{printf("%s",yytext);/*UTF-8 BOM*/}
[ \t\n]+ 							{printf("%s",yytext);/*WS пробелы, TAB и eol */} 
"\-\-".*"\n" 					    {printf("%s",yytext); /*Comment - пропускаемый комментарий до конца строки */} 
["][^"]*["]  						{printf("%s",yytext); char str[1022]; strncpy(str,yytext+1,strlen(yytext)-2);/*add Null:*/str[strlen(yytext)-2]=0; yylval=to_buff(str); return String;}
[-+]?{DIGIT}+({Dot}{DIGIT}+)?  	    {printf("%s",yytext); yylval=to_buff(yytext); return Number;}
"\xE2\x88\x83" 						{printf("%s",yytext); yylval=to_buff(yytext);return EXISTS;/*EXISTS UTF-8*/}
"\xE2\x88\x80" 						{printf("%s",yytext); yylval=to_buff(yytext);return FOR_ANY;/*FOR_ANY UTF-8*/}
"." 			 					{printf("%s",yytext); yylval=to_buff(yytext);return Dot;}
","  								{printf("%s",yytext); yylval=to_buff(yytext);return COMMA;/*COMMA = [,]*/}
":"  								{printf("%s",yytext); yylval=to_buff(yytext);return COLON;/*COLON = [:]*/}
"("  								{printf("%s",yytext); yylval=to_buff(yytext);return l_p;}
")"  								{printf("%s",yytext); yylval=to_buff(yytext);return r_p;}
"!"  								{printf("%s",yytext); yylval=to_buff(yytext);return e_m;}
"?"  								{printf("%s",yytext); yylval=to_buff(yytext);return q_m;}
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
"\xc2\xac"|"\xe2\x88\xa7"|"\xe2\x88\xa8"|"\xe2\x86\x92"|"\xe2\x89\xa1"|"\xe2\x89\xa0"|"\xe2\x89\xa4"|"\xe2\x89\xa5"     {/* UTF-8*/
	/*NOT*/ /*AND*/		  /*OR*/		   /*IMPLIES*/    /*EQUIV*/		/*Neq*/		  /*Leq*/		/*Geq*/ 
									printf("%s",yytext); yylval=to_buff(yytext);return INFIX;}
"="|"neq"|"leq"|"geq"|"<"|">"|"+"|"-"|"\*"|"/"|"not"|"and"|"or"|"impl"|"eqv" 
									{printf("%s",yytext); yylval=to_buff(yytext);return INFIX;}
({LCL}|{LSL})({LCL}|{LSL}|{DIGIT}|"_")*	{printf("%s",yytext); yylval=to_buff(yytext);return Id;/*Id = {Letter}({AlphaNumeric}|_)**/ 			} 
.								   	{int lng=strlen(yytext); char ltt=*yytext; printf("<LA BAD_STRING lng=%i, lttHEX=%X, val=%s>",lng,ltt,yytext); /*ошибка: - неизвестная буква (байт)*/}
%%
/*характеристики
 2 счёных РВ (WS, Comment) и строка BOM допускаются, но не передаются СА.
 31 лнт (32 return но INFIX возвращается дважды!)
 Из 31-го:
 - 3 имеют счётные РВ: String, Number, Id.
 - 1 имеет конечное множество строк: INFIX.
 - 27 - синглетоны!
 */