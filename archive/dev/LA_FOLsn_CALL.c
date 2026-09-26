/*first portion from SA!*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex (void); /*ЛА. объявление*/
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     QUANT = 258,
     DOT = 259,
     COMMA = 260,
     COLON = 261,
     l_p = 262,
     r_p = 263,
     l_cb = 264,
     r_cb = 265,
     e_m = 266,
     q_m = 267,
     DECLARATION = 268,
     PRIME = 269,
     DEFINITION = 270,
     FINSET = 271,
     FINSEQ = 272,
     FUNC = 273,
     TYPE = 274,
     Id = 275,
     Ide = 276,
     Number = 277,
     String = 278,
     Natural = 279
   };
int yylval; /*+?this global from SA(?) is pointer to token value in КУЧАю and used(?) by SA. But in SA spec count is 0!!!
				  when we use LA separatly we need not yylval*/
/*FROM YL_db.pgc-2 DUMMED*/
int to_buff(char* in, int l) /*было возврат char*. резервирует в куче l+1 байт. закатывает туда l байт начиная с in и добавляет в конец 00*/
{ return l;
}
/**/
#include "LA_FOLsn.c"
/*+?yytext is global?*/
int main (void)
{int ttype;
 ttype=yylex();
 while (ttype!=0) {printf ("[Token=%s, lng=%i, type=%i]\n",yytext,strlen(yytext),ttype);ttype=yylex();};
 exit(EXIT_SUCCESS);
}
