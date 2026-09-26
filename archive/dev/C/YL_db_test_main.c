#include "YL_db.c"
int main()
{int rc;
/*ECPGdebug(1,stderr);*/
if (connect()!=0) goto bad; printf ("Connected.\n");
if (sort_add("TV")==0) printf ("Сорт %s добавлен!\n","TV"); else printf("Сорт %s же есть!","TV");
if (sort_add("TV")==0) printf ("Сорт %s добавлен!\n","TV"); else printf("Сорт %s же есть!","TV");
if (commit()!=0) goto bad;
rc = EXIT_SUCCESS;
badr:
disconnect();
printf ("Disconnected.\n");
exit(rc);

bad:
printf("Unexpected respond from DBMS! Check it!\n");
printf("sqlca.sqlcode=%i, sqlca.sqlstate=%s.\n",sqlca.sqlcode,sqlca.sqlstate);
printf("sqlca.sqlerrm.sqlerrmc=%s.\n",sqlca.sqlerrm.sqlerrmc);
rc = EXIT_FAILURE;
goto badr;
}

