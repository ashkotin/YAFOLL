/* Processed by ecpg (11.1) */
/* These include files are added by the preprocessor */
#include <ecpglib.h>
#include <ecpgerrno.h>
#include <sqlca.h>
/* End of automatic include section */

#line 1 "testECPG.pgc"
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
void print_sqlca(){
 /*далее копия из https://www.postgresql.org/docs/11/ecpg-errors.html  */
    fprintf(stderr, "==== sqlca ====\n");
    fprintf(stderr, "sqlcode: %ld\n", sqlca.sqlcode);
    fprintf(stderr, "sqlerrm.sqlerrml: %d\n", sqlca.sqlerrm.sqlerrml);
    fprintf(stderr, "sqlerrm.sqlerrmc: %s\n", sqlca.sqlerrm.sqlerrmc);
    fprintf(stderr, "sqlerrd: %ld %ld %ld %ld %ld %ld\n", sqlca.sqlerrd[0],sqlca.sqlerrd[1],sqlca.sqlerrd[2],
                                                          sqlca.sqlerrd[3],sqlca.sqlerrd[4],sqlca.sqlerrd[5]);
    fprintf(stderr, "sqlwarn: %d %d %d %d %d %d %d %d\n", sqlca.sqlwarn[0], sqlca.sqlwarn[1], sqlca.sqlwarn[2],
                                                          sqlca.sqlwarn[3], sqlca.sqlwarn[4], sqlca.sqlwarn[5],
                                                          sqlca.sqlwarn[6], sqlca.sqlwarn[7]);
    fprintf(stderr, "sqlstate: %5s\n", sqlca.sqlstate);
    fprintf(stderr, "===============\n");
}
int main(){
 int rc;
 struct tm *newtime; time_t ltime;
 /* exec sql begin declare section */
    
 
#line 22 "testECPG.pgc"
 int ni , l ;
/* exec sql end declare section */
#line 23 "testECPG.pgc"

 /*ECPGdebug(1,stderr);*/
 { ECPGconnect(__LINE__, 0, "YL" , NULL, NULL , NULL, 0); }
#line 25 "testECPG.pgc"
 print_sqlca();
 printf ("\nConnected. sqlcode:%ld.",sqlca.sqlcode);ltime=time(NULL);newtime=localtime(&ltime);printf("\nTime point: %s",asctime(newtime));
 fprintf(stderr,"\nbegin:delete from dt");
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "delete from dt", ECPGt_EOIT, ECPGt_EORT);}
#line 28 "testECPG.pgc"
  print_sqlca();
 fprintf(stderr,"\nend:delete from dt");
 { ECPGdisconnect(__LINE__, "CURRENT");}
#line 30 "testECPG.pgc"
  print_sqlca();
 printf ("\nDisconnected. sqlcode:%ld.",sqlca.sqlcode);ltime=time(NULL);newtime=localtime(&ltime);printf("Time point: %s",asctime(newtime));
}
