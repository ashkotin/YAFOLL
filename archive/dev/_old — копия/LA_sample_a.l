/* шаблон автономного сканера */
%option main
%option noyywrap 
RCL	[јЅ¬√ƒ≈®∆«»… ЋћЌќѕ–—“”‘’÷„ЎўЏџ№Ёёя]
RSL	[абвгдеЄжзийклмнопрстуфхцчшщъыьэю€]
LCL	[QWERTYUIOPASDFGHJKLZXCVBNM]
LSL	[qwertyuiopasdfghjklzxcvbnm]
DIGIT	[0-9]
%%
"„ичиковым"			{/*русское им€ собственное*/ 					printf("RUS_NWF %s\n",yytext);} 
{RCL}({RSL}|"\'")*("-"{RCL}?({RSL}|"\'")+)* {/*русска€ заглавна€ инкрипци€ с ударением */ 	printf("RUS_CWF %s\n",yytext);} 
{RSL}({RSL}|"\'")*("-"{RSL}({RSL}|"\'")+)* {/*русска€ прописна€ инкрипци€ с ударением */ 	printf("RUS_SWF %s\n",yytext);} 
{LCL}{LSL}*("-"{LCL}?{LSL}+)* 	{/*латинска€ заглавна€ инкрипци€ */				printf("LAT_CWF %s\n",yytext);} 
{LSL}+("-"{LSL}+)* 	{/*латинска€ прописна€ инкрипци€ */					printf("LAT_SWF %s\n",yytext);} 
{LCL}+{DIGIT}* 		{/* идентификатор */							printf("ID %s\n",yytext);}			
[ \n]+			{/* пробелы и eol (в LAout сводим к одному)*/				printf("WS %s\n",yytext);} 		
"."|"!"|"?"|","|"\-"	{/* отдельно сто€щий образующий */					printf("SSD %s\n",yytext);} 
"\-\-".*"\n" {/* комментарий до конца строки */					printf("Comm %s",yytext);} 
.			{							printf("Unrecognized character: <%s>\n",yytext);}
%%
/**/