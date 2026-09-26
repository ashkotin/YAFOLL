/* шаблон сканера вызываемого из bison
out:
 stdout - почти исходный текст,
 LAout  - текст формируемый сканером.Файл должен быть объявлен в задании СА.
*/
%option noyywrap /*Это не проверялось, но должно заменить <<EOF>> и задание yywrap в конце*/
/*Примеры множеств букв*/
RCL	[АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ]
RSL	[абвгдеёжзийклмнопрстуфхцчшщъыьэюя]
LCL	[QWERTYUIOPASDFGHJKLZXCVBNM]
LSL	[qwertyuiopasdfghjklzxcvbnm]
DIGIT	[0-9]
%%
/*Примеры РВ-множеств и их обработки.Возврат лексического нт или значения цепочки обязателен!*/
"Чичиковым"			{/*русское имя собственное*/ 				fprintf(LAout,"%s",yytext);	printf("%s",yytext);return RUS_NWF;} 
{RCL}({RSL}|"\'")*("-"{RCL}?({RSL}|"\'")+)* {/*русская заглавная инкрипция с ударением */ fprintf(LAout,"%s",yytext);	printf("%s",yytext);return RUS_CWF;} 
{RSL}({RSL}|"\'")*("-"{RSL}({RSL}|"\'")+)* {/*русская прописная инкрипция с ударением */ fprintf(LAout,"%s",yytext);	printf("%s",yytext);return RUS_SWF;} 
{LCL}{LSL}*("-"{LCL}?{LSL}+)* 	{/*латинская заглавная инкрипция */			fprintf(LAout,"%s",yytext);	printf("%s",yytext);return LAT_CWF;} 
{LSL}+("-"{LSL}+)* 	{/*латинская прописная инкрипция */			fprintf(LAout,"%s",yytext);	printf("%s",yytext);return LAT_SWF;} 
{LCL}+{DIGIT}* 		{/* идентификатор */					fprintf(LAout,"%s",yytext);	printf("%s",yytext);return ID;}			
{RCL}"."		{/* русский инициал */					fprintf(LAout,"%s",yytext);	printf("%s",yytext);return RUS_I;} 
{LCL}"."		{/* латинский инициал */				fprintf(LAout,"%s",yytext);	printf("%s",yytext);return LAT_I;} 
[ \n]+			{/* пробелы и eol (в LAout сводим к одному)*/		fprintf(LAout," ");		printf("%s",yytext);return WS;} 		
"\""|"("|")"|";"|":"	{/* отделитель */					fprintf(LAout,"|");		printf("%s",yytext);return *yytext;} 
"."|"!"|"?"|","|"\-"	{/* отдельно стоящий образующий */			fprintf(LAout,"|");		printf("%s",yytext);return *yytext;} 
"..."			{/* знакоформа omission */				fprintf(LAout,"|");		printf("%s",yytext);return OSF;} 
"!.."|"?.."		{/* знакоформа omission group */			fprintf(LAout,"|");		printf("%s",yytext);return O_SF;} 
/*<<EOF>>			 return 0;   /* 0 == EOF for yyparse. */
.			{printf("Unrecognized character: <%s>\n",yytext); exit(0);}
%%
/* called by yylex on EOF */
/*int yywrap(void) {return 1;} /*<>0 нужен чтобы yylex активизировал <<EOF>>*/
FILE *LAout; /* файл выдачи ЛА для выделения цепочек слов */ /*ЭТО НЕ ПРОВЕРЯЛОСЬ!!!!!!!!!!!!!!!!!!!!!!!!!!*/