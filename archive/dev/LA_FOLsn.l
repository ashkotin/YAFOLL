/*task to the scanner Y!L*/
/*Scannaer transfer the input as output entirely to stdout.
  !!!All UTF-8 processing is carried out only here! SA knows nothing about this!!!
  BOM, WS, Comment do not return token. BAD_BYTE - error handler.
  1. In this version, Russian UTF-8 letters are allowed.
  2. ACTIONS:
  2.1. to_buff is used to store current token to heap. pointer to first char is set to yylval global var (Bison stack).
*/
/*%option main*/
%option noyywrap 
/*RU letters UTF-8 (see goo-doc Unicode)*/
RSL		"\xd1\x91"|("\xd0"([\xb0-\xbf]))|("\xd1"([\x80-\x8f]))
RCL		"\xd0\x81"|("\xd0"([\x90-\xaf]))
LSL		[qwertyuiopasdfghjklzxcvbnm]
LCL		[QWERTYUIOPASDFGHJKLZXCVBNM]
DIGI   	[1-9]
ZERO	[0]
US		[_]
DQ		"\x22"
DOT     [.]
MI		[-]
ws		[ ]
COMMA	[,]
COLON	[:]
l_p		[(]
r_p		[)]
l_cb	[{]
r_cb	[}]
e_m		[!]
q_m		[?]
EQ		[=]
LT		[<]
GT		[>]
PL		[+]
ST		[*]
DI		[/]
PCT		[%]
COUNT	[#]
TAB		"\x09"
EOL		"\x0A"
CR		"\x0D"
/*RE for BOM (Byte Order Mark - we consider that this is a TOKEN!) and UTF-8 special characters...*/
BOM		"\xEF\xBB\xBF"
EXISTS	"\xE2\x88\x83"
FOR_ANY	"\xE2\x88\x80"
SUM		"\xCE\xA3"
RED		"\xE2\x86\x93"
NOT		"\xc2\xac"
AND		"\xe2\x88\xa7"
OR		"\xe2\x88\xa8"
IMPLIES	"\xe2\x86\x92"
EQUIV	"\xe2\x89\xa1"
Neq		"\xe2\x89\xa0"
Leq		"\xe2\x89\xa4"
Geq		"\xe2\x89\xa5"
/*RE for grouping letters over already given ones*/
Lttr	{LCL}|{LSL}|{RCL}|{RSL}
DIGIT   {DIGI}|{ZERO}
QUANT 	{FOR_ANY}|{EXISTS}|{COUNT}|{SUM}|{RED}
FIX 	{NOT}|{AND}|{OR}|{IMPLIES}|{EQUIV}|{Neq}|{Leq}|{Geq}|{EQ}|{LT}|{GT}|{PL}|{MI}|{ST}|{DI}
/*END OF THE ALPHABET*/
WS 		({ws}|{TAB}|{EOL}|{CR})+
Comment {MI}{MI}.*{EOL}
TYPE	"String"|"Number"|"Natural"|"Ide"
DECLARATION "Declaration"
FINSET	"fset"
FINSEQ	"fseq"	
FUNC	"func"
DEFINITION "definition"
PRIME	"prime"
Id 		{FIX}|{Lttr}({Lttr}|{DIGIT}|{US})*
Ide 	{US}{Lttr}({Lttr}|{DIGIT}|{US})*
String 	{DQ}[^"]*{DQ}
NN  	{DIGIT}+
Natural {ZERO}|({DIGI}{NN}?)
RNp		{Natural}{DOT}{NN}
Number 	{MI}?{RNp}{PCT}?
%%
{BOM}		 					{/*UTF-8 BOM*/										printf("%s",yytext);fprintf(stderr,"|BOM");}
{WS} 							{/*WS: space, TAB, eol, and caridge return.*/		printf("%s",yytext);fprintf(stderr,"\n|WS");} 
{Comment}						{/*skiped comment to-with end of line.*/			printf("%s",yytext);fprintf(stderr,"\n%s|Comment",yytext);} 
{String}						{/*STRINGS: stored without surrounding quotes.*/	printf("%s",yytext);fprintf(stderr,"\n%s|String",yytext);yylval=to_buff(yytext+1,strlen(yytext)-2); return String;}
{Number}		  				{/*RATIONAL NUMBERS. percentage possible.*/			printf("%s",yytext);fprintf(stderr,"\n%s|Number",yytext);yylval=to_buff(yytext,strlen(yytext));return Number;}
{Natural}				 		{/*INTEGERS. the percentage will be discarded.*/	printf("%s",yytext);fprintf(stderr,"\n%s|Natural",yytext);yylval=to_buff(yytext,strlen(yytext));return Natural;}
{QUANT}	 						{/*QUANTIFIERS*/									printf("%s",yytext);fprintf(stderr,"\n%s|QUANT",yytext);yylval=to_buff(yytext,strlen(yytext));return QUANT;}
{DOT} 			 				{/*.*/												printf("%s",yytext);fprintf(stderr,"\n%s|DOT",yytext);yylval=to_buff(yytext,strlen(yytext));return DOT;}
{COMMA}							{/*,*/												printf("%s",yytext);fprintf(stderr,"\n%s|COMMA",yytext);yylval=to_buff(yytext,strlen(yytext));return COMMA;}
{COLON}							{/*:*/												printf("%s",yytext);fprintf(stderr,"\n%s|COLON",yytext);yylval=to_buff(yytext,strlen(yytext));return COLON;}
{l_p}  							{/*(*/												printf("%s",yytext);fprintf(stderr,"\n%s|l_p",yytext);yylval=to_buff(yytext,strlen(yytext));return l_p;}
{r_p} 							{/*)*/												printf("%s",yytext);fprintf(stderr,"\n%s|r_p",yytext);yylval=to_buff(yytext,strlen(yytext));return r_p;}
{l_cb}  						{/*{*/												printf("%s",yytext);fprintf(stderr,"\n%s|l_cb",yytext);yylval=to_buff(yytext,strlen(yytext));return l_cb;}
{r_cb} 							{/*}*/												printf("%s",yytext);fprintf(stderr,"\n%s|r_cb",yytext);yylval=to_buff(yytext,strlen(yytext));return r_cb;}
{e_m} 							{/*!*/												printf("%s",yytext);fprintf(stderr,"\n%s|e_m",yytext);yylval=to_buff(yytext,strlen(yytext));return e_m;}
{q_m} 							{/*?*/												printf("%s",yytext);fprintf(stderr,"\n%s|q_m",yytext);yylval=to_buff(yytext,strlen(yytext));return q_m;}
{DECLARATION}  					{/**/												printf("%s",yytext);fprintf(stderr,"\n%s|DECLARATION",yytext);yylval=to_buff(yytext,strlen(yytext));return DECLARATION;}
{FINSET} 						{/**/												printf("%s",yytext);fprintf(stderr,"\n%s|FINSET",yytext);yylval=to_buff(yytext,strlen(yytext));return FINSET;}
{FINSEQ}  						{/**/												printf("%s",yytext);fprintf(stderr,"\n%s|FINSEQ",yytext);yylval=to_buff(yytext,strlen(yytext));return FINSEQ;}
{FUNC}  						{/**/												printf("%s",yytext);fprintf(stderr,"\n%s|FUNC",yytext);yylval=to_buff(yytext,strlen(yytext));return FUNC;}
{DEFINITION}  					{/**/												printf("%s",yytext);fprintf(stderr,"\n%s|DEFINITION",yytext);yylval=to_buff(yytext,strlen(yytext));return DEFINITION;}
{PRIME} 			 			{/**/												printf("%s",yytext);fprintf(stderr,"\n%s|PRIME",yytext);yylval=to_buff(yytext,strlen(yytext));return PRIME;}
{TYPE}				 			{/**/												printf("%s",yytext);fprintf(stderr,"\n%s|TYPE",yytext);yylval=to_buff(yytext,strlen(yytext));return TYPE;}
{Id}							{/*IDENTIFIERS. including special letters.*/		printf("%s",yytext);fprintf(stderr,"\n%s|Id",yytext);yylval=to_buff(yytext,strlen(yytext));return Id;} 
{Ide}							{/*UR-ELEMENTS*/									printf("%s",yytext);fprintf(stderr,"\n%s|Ide",yytext);yylval=to_buff(yytext,strlen(yytext));return Ide;} 
.								{/*error: unknown token (byte)*/					printf("\n<LA BAD_BYTE BYTE.lng=%i, BYTE.HEX=%X, BYTE.s=%s>",strlen(yytext),*yytext,yytext); fprintf(stderr,"\n%s|BAD_TOKEN",yytext);} 
%%
/*Notes
  1. The C-action ({...) must start on the same line as the RE-rule!
  2. The IDs of the RE (sets of letters...) and lexical non-terminals can coincide - they are from different namespaces, namely: The C code is external to the LA processor, and the tokens used in it are declared in the SA :-)
*/