/* Processed by ecpg (11.1) */
/* These include files are added by the preprocessor */
#include <ecpglib.h>
#include <ecpgerrno.h>
#include <sqlca.h>
/* End of automatic include section */

#line 1 "YL_db.pgc"
/*Группа функций работы с БД YL... 
First version. Begin. 27.06.2013. Alex Shkotin. alex.shkotin@gmail.com
*/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
/*немного констант*/
#define YL_NODE_OD 0 /*зачение flg - узел не надо обрабатывать*/
#define YL_NODE_DO 1 /*зачение flg - узел надо обработать*/
#define YL_NODE_DONE 2 /*зачение flg - узел обработан*/
#define YL_NODE_POSTPONED 3 /*зачение flg - обработка узла отложена*/
#define YL_DB_DT_DTS_v_LEN 121 /*длина v в БД (!!!в UTF-8 буквах)*/
#define YLsbl YL_DB_DT_DTS_v_LEN*3+1 /*длина Си-буфера строк для колонки v БД (с учётом китайского без учёта музыкального;-)*/
/*#define YL_DB_DT_id_LEN 21*/ /*длина id в dt (!!!в UTF-8 буквах)*/
/*#define YLid YL_DB_DT_id_LEN*3+1*/ /*длина Си-буфера строк для колонки id БД (с учётом китайского без учёта музыкального;-)*/
#define YL_STRING_BUF_LEN 1023+1 /*размер буфера сериализации терма*/
#define YL_EQUIV_SIGN "=" /*встроенный в код знак для тождества - единственная полиморфа*/
/*глобальные переменные*/
/* exec sql begin declare section */
       
    /*Это буфер для всех строк БД и сериализации терма*/
    /*Это буфер для малых строк БД*/
    /*Это буфер для малых строк БД*/
    /*Это буфер для малых строк БД*/
    /*Это буфер для малых строк БД*/
    /*Это буфер для малых строк БД*/

#line 20 "YL_db.pgc"
 int wi , wi1 , wi2 , wi3 ;
 
#line 21 "YL_db.pgc"
 char wc [ YL_STRING_BUF_LEN ] ;
 
#line 22 "YL_db.pgc"
 char wc1 [ YLsbl ] ;
 
#line 23 "YL_db.pgc"
 char wc2 [ YLsbl ] ;
 
#line 24 "YL_db.pgc"
 char wc3 [ YLsbl ] ;
 
#line 25 "YL_db.pgc"
 char wc4 [ YLsbl ] ;
 
#line 26 "YL_db.pgc"
 char wc5 [ YLsbl ] ;
/* exec sql end declare section */
#line 27 "YL_db.pgc"

/*отладка*/
void print_sqlca(){
    printf("==== sqlca ====\n");
    printf("sqlcode: %ld\n", sqlca.sqlcode);
    printf("sqlerrm.sqlerrml: %d\n", sqlca.sqlerrm.sqlerrml);
    printf("sqlerrm.sqlerrmc: %s\n", sqlca.sqlerrm.sqlerrmc);
    printf("sqlerrd: %ld %ld %ld %ld %ld %ld\n", sqlca.sqlerrd[0],sqlca.sqlerrd[1],sqlca.sqlerrd[2], sqlca.sqlerrd[3],sqlca.sqlerrd[4],sqlca.sqlerrd[5]);
    printf("sqlwarn: %d %d %d %d %d %d %d %d\n", sqlca.sqlwarn[0], sqlca.sqlwarn[1], sqlca.sqlwarn[2], sqlca.sqlwarn[3], sqlca.sqlwarn[4], sqlca.sqlwarn[5], sqlca.sqlwarn[6], sqlca.sqlwarn[7]);
    printf("sqlstate: %5s\n", sqlca.sqlstate);
    printf("===============\n");
}
/*наши функции СУБД*/
int connect() /*порт сервера обычно 5432. Но 26.03.14(тоши) у нас там 64-сервер(9.2), а 32-сер(9.3) на 5433 (впрочем см. pgAdmin)*/{
/* EXEC SQL CONNECT TO YL@127.0.0.1:5433 USER postgres/postgres; */
 { ECPGconnect(__LINE__, 0, "YL" , NULL, NULL , NULL, 0); }
#line 42 "YL_db.pgc"
 
 return sqlca.sqlcode;
}
int commit(){
 { ECPGtrans(__LINE__, NULL, "commit");}
#line 46 "YL_db.pgc"
 
 return sqlca.sqlcode;
}
int disconnect(){
 { ECPGdisconnect(__LINE__, "CURRENT");}
#line 50 "YL_db.pgc"
 
 return sqlca.sqlcode;
}
void YL_abort(char *msg){
 printf("\n<ABORT> %s: UNEXPECTED sqlcode!\n",msg); print_sqlca();printf("</ABORT>"); exit(EXIT_FAILURE);
}
/*динамический (кучный;-) буфер строки...*/
char* to_buff(char* in, int l) /*резервирует в куче l+1 байт. закатывает туда l байт начиная с in и добавляет в конец 00*/
{char* str_buff=malloc(l+1); if(str_buff==NULL) {printf("\n!to_buff: malloc cann't get %i bytes. Abort!",l+1);exit(EXIT_FAILURE);};
 strncpy(str_buff,in,l); /*add Null:*/str_buff[l]=0;
 return str_buff;
}
/***YAFOLL***/
/*ЛИСТИКИ Y!L*/
int fill_array(char* pth,int pthI[21])/*ОП. возвращает массив номеров по строке номеров.*/{
 /*Нулевой элемент массива - реальное к-во элементов! управление - RC*/
 /*проще считать "." терминатором, а условие конца массива целых - 00 после него.*/
  /*выделив очередное целое на него надо натравить а 0-терминирован уже pth!*/
  char* c_p=pth/*указатель на обрабатываемую букву*/; char* t_p/*указатель на терминатор*/;
  /*int wi;*/ int i=1; /*DEBUG printf("\nfill_array begins with pth=(%s)",pth);*/
  /*шаг обработки*/
 loop:
  t_p=strchr(c_p,'.');
  if (t_p==0) /*нет терминатора*/ return 1; if (t_p==c_p) /*терминатор в первой позиции - нет числа*/ return 2;
  pthI[i]=atoi(c_p);/*съест до терминатора*/ /*DEBUG printf("\n pthI[%i]=%i",i,pthI[i]);*/
  c_p=t_p+1;
  if(*c_p==0) {pthI[0]=i; /*DEBUG printf("\n pthI[0]=%i\nfill_array ends.",pthI[0]);*/ return 0;} else {i=i+1; goto loop;};
}
/***семантические таблицы /СТ/. возможно все кроме dt, dts***/
int e_exists_q(char *s, char *t/*out - type*/)/*СТ. поиск s среди эт. возвращает тип и RC: 0 - нашли один, 1 - не нашли, 2 - нашли несколько.*/{
 int dbg=0;/*0 - не дебагить*/
 /*сколько их?*/
 strcpy(wc,s); 
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from entities where id = $1 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 83 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("e_exists_q-s_count");
 if (wi==0) return 1/*Не нашли*/;
 if (wi==1) {/*сущее ровно одно*/
  { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select type from entities where id = $1 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 86 "YL_db.pgc"
 if(dbg) printf("\n!e_exists_q!DEBUG!after SELECT: s=<%s> wc1=<%s>.",s,wc1);
 strcpy(t,wc1); return 0;}
 /*сущее есть и не одно. предусловие: это может быть только функция - оно обеспечивается при заполнении entities*/
 /*возвращаем тип func*/
 strcpy(t,"func"); return 2;
}
int Sget_tid(char *id)/*СТ. возвращает по Id сущего его атрибут tid.*/{
 /*!!!предусловие: сущее есть и одно!!!*/
 strcpy(wc,id);
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select tid from entities where id = $1 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 95 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("Sget_tid-select");
 return wi1;
}
/***ДРВ***/
void node_put_v(char* id, char* v) /*ДРВ. закатывает узлу v*/{
 /*id - id из-узла (где v)*/
 strcpy(wc1,id); strcpy(wc,v);
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dt set v = $1  where id = $2 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 102 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("node_put_v-update");
 commit(); return;
}
char* node_get_v(char* id)/*ДРВ. возвращает указатель на значение v данного узла (id).*/{
 strcpy(wc1,id);
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select v from dt where id = $1 ", 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 107 "YL_db.pgc"
  if (sqlca.sqlcode!=0) YL_abort("node_get_v-sel_v");
 return &wc[0];
}
void get_attr(int ac,char* id,char* pth,char* val)/*ДРВ. Возвращает атрибут номер ac узла найденного вниз от id по пути pth*/{
 /*ЛИБО abort - такого узла на конце пути нет. Если нет узла с id, abort!*/
 /*ac: 1 - rid, 2 - v, 3 - id*/
 char cid[22] /*ид текущего узла от которого шагаем*/; strcpy(cid,id); 
 int dbg=0/*управление отладочными сообщениями*/;
 if (dbg==1) printf("\n get_attr begins with ac=(%i) id=(%s) pth=(%s)\n",ac,id,pth);
 int pth_l/*длина пути*/; int pthI[21]/*путь массивом*/; int rc=fill_array(pth,pthI); 
 if (rc!=0) {printf("\n<:-(get_attr: fill_array returns rc=%i. Abort!>",rc);exit(EXIT_FAILURE);};
 pth_l=pthI[0];
 if (pth_l==1 && pthI[1]==0) {strcpy(wc,id); goto get;};
 int i; for (i=1;i<pth_l+1;i++) {/*шагнуть*/
 strcpy(wc1,cid); wi=pthI[i];
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select id from dt where up = $1  and irn = $2 ", 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 122 "YL_db.pgc"

 if (sqlca.sqlcode==0) /*дитя есть*/ strcpy(cid,wc);
 else /*дитя нет*/ {printf("\n!get_attr: Child #%i from dt_id %s in path %s is absent!\n",i,id,pth); YL_abort("get_attr-id");};
 };/*в wc id целевого дитя*/
 get: 
 if (ac==1) {
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select rid from dt where id = $1 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 128 "YL_db.pgc"

 if (sqlca.sqlcode==0) strcpy(val,wc1); else /*дитя нет*/ YL_abort("get_attr-rid");}
 else
 if (ac==2) {
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select v from dt where id = $1 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 132 "YL_db.pgc"
 
 if (sqlca.sqlcode==0) strcpy(val,wc1); else /*дитя нет*/ YL_abort("get_attr-v");}
 else /*3...:-) возвращаем id*/ strcpy(val,wc);
 if (dbg==1) printf("\n get_attr ends with v=(%s)\n",val);
 return;
}
char* crt_node(char* sid,char* rid,char* v)/*ДРВ. возвращает указатель на рабочую переменную с id созданного узла ДРВ.*/{
 /*для узла левой части правила нужны sid,rid, а для лнт в правой sid,v.*/
 int dbg=0/*управление отладочными сообщениями*/;
 if (dbg==1) printf("\n!crt_node!DEBUG!begin sid=%s, rid=%s, v=%s!",sid,rid,v);
 /*предусловие: длина v не больше YLsbl-1*/
 if (strlen(v)>(YLsbl-1)) {printf("\ncrt_node-precond failed: v length = %i > C-buff length minus 1 = %i",strlen(v),(YLsbl-1));
  YL_abort("crt_node-precond");
 };
 /*получаем свободный номер в wi*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select fnn from system where id = 'YL'", ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 147 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("crt_node-fnn_select");
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update system set fnn = fnn + 1", ECPGt_EOIT, ECPGt_EORT);}
#line 148 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("crt_node-fnn_update");
 sprintf(wc1,"%010i",wi); /*формируем ид- узла*/
 /*+2do: перехватывать sql-код -400: слишком много utf-8 букоф, т.к. Си-шно отследить сложно!*/
 strcpy(wc2,sid); strcpy(wc3,rid); strcpy(wc4,v);
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "insert into dt ( id , sid , rid , v ) values ( $1  , $2  , $3  , $4  )", 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(wc2),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(wc3),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(wc4),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 152 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("crt_node-insert");
 commit(); if (dbg==1) printf(" !crt_node!DEBUG!end dt_id=%s!",wc1);
 return &wc1[0];
}
#include "YL_db__SA_call.c"
void get_min_id(char* sid,char* id)/*ДРВ. Возвращает в id минимальный ид узлов с заданным sid, если таких нет - abort*/{
 strcpy(wc1,sid);
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select min ( id ) from dt where sid = $1 ", 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 159 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("get_min_id-select_id");
 strcpy(id,wc); return;
}
void get_chld_id(int chn,char* pid,char* id)/*ДРВ. Возвращает в id ид узла ребёнка номер chn, для родителя с ид - pid, если такого нет - id=""*/{
 strcpy(wc1,pid); wi=chn;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select id from dt where up = $1  and irn = $2 ", 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 164 "YL_db.pgc"

 if (sqlca.sqlcode==0) {strcpy(id,wc); return;} /*дитя есть*/
 if (sqlca.sqlcode==100) {strcpy(id,""); return;} /*дитя нет*/
 YL_abort("get_chld_id");
}
void get_nodes(char* r_id/*in*/)/*ДРВ. собирает узлы поддерева с корнем r_id в таблицу _w (ТН)*/{
 /*1.1. почистить ТН и поместить в ТН корень с флажком "не обработан".*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "delete from _w", ECPGt_EOIT, ECPGt_EORT);}
#line 171 "YL_db.pgc"
 if (sqlca.sqlcode!=0 && sqlca.sqlcode!=100) YL_abort("get_nodes-del");
 wi=atoi(r_id);
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "insert into _w ( nid , flg ) values ( $1  , 0 )", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 173 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("get_nodes-ins");
 /*1.2. если необработанных узлов нет то СТОП.*/
 loop: 
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from _w where flg = 0", ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 176 "YL_db.pgc"
 if (wi==0) return; /*Нет*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select min ( nid ) from _w where flg = 0", ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 177 "YL_db.pgc"
 /*ЭТО: НЕ РАБОТАЕТ!!!: if (sqlca.sqlcode==100) return; = min возвращает -2147483648!!!*/
 /*1.3. для не обработанного узла: добавить на него ссылающихся с флажком не_обр, а его пометить обработанным. Идти на 1.2.*/
 /*printf("\n!get_nodes!loop!wi=%i",wi);*/
 sprintf(wc,"%010i",wi); /*формируем ид- узла*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "insert into _w ( nid ) select cast ( id as integer ) from dt where up = $1 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 181 "YL_db.pgc"
 if (sqlca.sqlcode!=0 && sqlca.sqlcode!=100) YL_abort("get_nodes-ins-2");
 /*printf("\n!get_nodes!update!wi=%i",wi);*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update _w set flg = 1 where nid = $1 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 183 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("get_nodes-update");
 goto loop;
 }
int get_sig_P(char* sig_f)/*ДРВ. подсчитывает к-во rid=sig_eF узлов в поддереве под sig_f.*/{
 /*sig_f - предполагается ид узла sig_f из объявления. Возвращает количество правил sig_eF в поддереве: 0 - ОК для WFC*/
 /*0. собираем узлы поддерва в _w.*/
 get_nodes(sig_f);
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from dt t , _w w where cast ( t . id as integer ) = w . nid and t . rid = 'sig_eF'", ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 190 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("get_sig_P-sel-cou");
 return wi;
}
/*ДРВ. Сем обработчики*/
int def_chk_fp(char* dt_id)/*ДРВ. все фоп должны быть различны и не должны совпадать с именами элементов теории. (deff-4) возващает RC=0,1,2*/{
 /*dt_id - ид узла ДРВ с Id_list_bch.*/
 /*Проверяет подсчётом, что все фоп различны и не должны совпадать с именем элемента теории.*/
 /*подсчитываем количество [Id] узлов на 3-ом уровне от узла Id_list_bch*/
 strcpy(wc1,dt_id);
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from dt id , dt idl , dt b , dt bch where id . up = idl . id and idl . up = b . id and b . up = bch . id and bch . id = $1 ", 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 199 "YL_db.pgc"
  if (sqlca.sqlcode!=0) YL_abort("def_chk_fp-sel1");
 int fn=wi;
 /*подсчитываем количество различных v-значений у [Id] узлов на 3-ом уровне от узла Id_list_bch*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( distinct ( id . v ) ) from dt id , dt idl , dt b , dt bch where id . up = idl . id and idl . up = b . id and b . up = bch . id and bch . id = $1 ", 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 202 "YL_db.pgc"
  if (sqlca.sqlcode!=0) YL_abort("def_chk_fp-sel2");
 if (fn!=wi) {printf("\n!def_chk_fp!ERROR: Some formal parameters are the same!WFC(deff-4)");return 1;}
 /*подсчитываем к-во пересечений с именами элементов теории*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from dt id , dt idl , dt b , dt bch , entities en where id . up = idl . id and idl . up = b . id and b . up = bch . id and id . v = en . id and bch . id = $1 ", 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 205 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("def_chk_fp-sel3");
 if (wi!=0) {printf("\n!def_chk_fp!ERROR: Some formal parameters have element's of theory names!WFC(deff-4)"); return 2;};
 return 0;
}
int check_sig_eI(char* sig_f)/*ДРВ. проверяет WFC(sig_eI-1).*/{
 /*sig_f - ид узла sig_f объявления. Возвращает RC: 0 - ОК*/
 /*0. собираем узлы поддерва в _w. flg у всех будет 1.*/
 get_nodes(sig_f);
 /*1. выставляем флаг в 0 у тех у кого sid='Id'*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update _w set flg = 0 from dt t where cast ( t . id as integer ) = nid and t . sid = 'Id'", ECPGt_EOIT, ECPGt_EORT);}
#line 214 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("check_sig_eI-update");
 /*2. перебираем и v каждого смотрим через e_exists_q*/
 char t[22]/*тип проверяемого сущего*/; char msg[122]; int cnid /*номер текущего узла*/; char cv[YLsbl]/*v текущего узла*/;
 int err_flg=0;/*фиксирует наличие ошибок при проверке в цикле*/
 loop: 
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from _w where flg = 0", ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 219 "YL_db.pgc"
 if (wi==0) goto end; /*Нет*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select min ( nid ) from _w where flg = 0", ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 220 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("check_sig_eI-min");
 cnid=wi;
 /*получаем v.*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select t . v from dt t , _w w where cast ( t . id as integer ) = w . nid and w . nid = $1 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 223 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("check_sig_eI-sel");
 strcpy(cv,wc);
 /*проверяем*/
 if (e_exists_q(cv,t)!=0) {sprintf(msg,"\ncheck_sig_eI:!ERROR! There is no such an entity: %s!",cv); printf("%s",msg); err_flg=1; goto next;}; 
 if (strcmp(t,"sort")!=0) {sprintf(msg,"\ncheck_sig_eI:!ERROR! %s is not a sort but %s!",cv,t); printf("%s",msg); err_flg=1;}; 
 next: 
 wi=cnid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "delete from _w where nid = $1 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 230 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("check_sig_eI-delete");
 goto loop;
 end: return err_flg;
}
/***ЛЕС***/
int scrt_node(int tid,char* sid,char* rid,char* v)/*Лес. возвращает указатель на id созданного узла дерева tid.*/{
 /*для узла левой части правила нужны sid,rid, а для лнт в правой sid,v.*/
 /*получаем свободный номер в wi*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select fnn from system where id = 'YL'", ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 238 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("scrt_node-fnn_select");
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update system set fnn = fnn + 1", ECPGt_EOIT, ECPGt_EORT);}
#line 239 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("scrt_node-fnn_update");
 wi1=tid;
 /*+?2do: перехватывать sql-код -400: слишком много utf-8 букоф, т.к. Си-шно отследить сложно!*/
 strcpy(wc2,sid); strcpy(wc3,rid); strcpy(wc4,v);
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "insert into dts ( tid , nid , sid , rid , v ) values ( $1  , $2  , $3  , $4  , $5  )", 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(wc2),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(wc3),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(wc4),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 243 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("scrt_node-insert");
 commit(); return wi;
}
void st_del(int tid)/*ЛЕС. удаляет дерево из леса*/{
 int dbg=0;
 wi=tid; /*printf("\n-st_del.DEBUG.in.tid=%i.",tid);*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "delete from dts where tid = $1 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 249 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("st_del-delete");
 commit(); if(dbg!=0) printf("\n<st_del msg='.DEBUG.after commit' tid='%i'/>",tid);
 return;
}
void sget_attr(int ac,int tid,int id,char* pth,char* val)/*Лес. Возвращает атрибут номер ac узла дерева tid найденного вниз от id по пути pth*/{
 /*ЛИБО abort - такого узла на конце пути нет. Если нет узла с id, abort!*/
 /*ac: 1 - rid, 2 - v (возвращаются в val), 3 - id(возвращается в val как строка), 4 - sid*/
 int cid /*ид текущего узла от которого шагаем*/; cid=id; 
 /*printf("\n!DEBUG! sget_attr begins with ac=(%i) tid=(%i) id=(%i) pth=(%s).",ac,tid,id,pth);*/
 int pth_l/*длина пути*/; int pthI[21]/*путь массивом*/; int rc=fill_array(pth,pthI); 
 if (rc!=0) {printf("\n!sget_attr: fill_array returns rc=%i. Abort!",rc);exit(EXIT_FAILURE);};
 pth_l=pthI[0];
 wi3=tid;
 if (pth_l==1 && pthI[1]==0) {wi1=id; goto get;};/*wc->wi1*/
 int i; for (i=1;i<pth_l+1;i++) {/*шагнуть*/
 wi2=cid; wi=pthI[i];/*wc1->wi2*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select nid from dts where tid = $1  and up = $2  and irn = $3 ", 
	ECPGt_int,&(wi3),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 265 "YL_db.pgc"

 if (sqlca.sqlcode==0) /*дитя есть*/ cid=wi1; else /*дитя нет*/ {printf("\n!sget_attr: Child #%i from tid=%i, nid=%i in path %s is absent!\n",i,tid,id,pth); YL_abort("sget_attr-id");};
 };/*в cid id целевого дитя*/
 get: 
 if (ac==1) {
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select rid from dts where tid = $1  and nid = $2 ", 
	ECPGt_int,&(wi3),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 270 "YL_db.pgc"

 if (sqlca.sqlcode==0) strcpy(val,wc1); else /*дитя нет*/ YL_abort("sget_attr-rid");}
 else
 if (ac==4) {
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select sid from dts where tid = $1  and nid = $2 ", 
	ECPGt_int,&(wi3),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 274 "YL_db.pgc"

 if (sqlca.sqlcode==0) strcpy(val,wc1); else /*дитя нет*/ YL_abort("sget_attr-sid");}
 else
 if (ac==2) {
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select v from dts where tid = $1  and nid = $2 ", 
	ECPGt_int,&(wi3),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 278 "YL_db.pgc"
 
 if (sqlca.sqlcode==0) strcpy(val,wc1); else /*дитя нет*/ {printf("\nsget_attr(ac=%i tid=%i id=%i pth=%s) POINT dts.tid=%i dts.nid=%i.",ac,tid,id,pth,wi3,wi1);YL_abort("sget_attr-v");};}
 else /*3...:-) возвращаем id*/ sprintf(val,"%i",cid);/*грубовато, но ведь приведение к String;-)*/
 /*printf("\n!DEBUG! sget_attr ends with val=(%s)",val);*/
 return;
}
int sget_up(int tid,int nid)/*Лес. возвращает nid папы. 0 - нет (up=Null)*/{
 /*printf("\n!DEBUG! sget_up begins with tid=(%i) nid=(%i).",tid,nid);*/
  wi=tid; wi1=nid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select coalesce ( up , 0 ) from dts where tid = $1  and nid = $2 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 287 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sget_up-select-up");
 return wi2;
}
int sget_irn(int tid,int nid)/*Лес. возвращает irn узла*/{
 wi=tid; wi1=nid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select irn from dts where tid = $1  and nid = $2 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 292 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sget_irn-select");
 return wi2;
}
int sget_nid(int tid,int nid,char* pth)/*Лес. Возвращает атрибут nid узла дерева tid найденного вниз от nid по пути pth*/{
 char cw[123]/*рабочая*/;
 /*получаем строчный nid целевого*/sget_attr(3,tid,nid,pth,cw);
 return atoi(cw);
}
int sget_flg(int tid,int nid,char* pth)/*Лес. Возвращает атрибут flg узла дерева tid найденного вниз от nid по пути pth*/{
 /*получаем nid целевого*/wi1=sget_nid(tid,nid,pth); wi=tid; 
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select flg from dts where tid = $1  and nid = $2 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 302 "YL_db.pgc"
 if (sqlca.sqlcode!=0) /*дитя нет*/ YL_abort("sget_flg-select");
 return wi2;
}
int sget_flg2(int tid,int nid,char* pth)/*Лес. Возвращает атрибут flg2 узла дерева tid найденного вниз от nid по пути pth*/{
 /*получаем nid целевого*/wi1=sget_nid(tid,nid,pth); wi=tid; 
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select flg2 from dts where tid = $1  and nid = $2 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 307 "YL_db.pgc"
 if (sqlca.sqlcode!=0) /*дитя нет*/ YL_abort("sget_flg2-select");
 return wi2;
}
int sget_ref(int tid,int nid,char* pth)/*Лес. Возвращает атрибут ref(NULL->0) узла дерева tid найденного вниз от nid по пути pth*/{
 /*printf("\n!sget_ref!DEBUG! in tid=%i nid=%i pth='%s'.",tid,nid,pth);*/
 /*получаем nid целевого*/wi1=sget_nid(tid,nid,pth); wi=tid; 
 /*printf("\n!sget_ref!DEBUG! point #1 tid=%i nid=%i pth='%s' wi1=%i.",tid,nid,pth,wi1);*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select coalesce ( ref , 0 ) from dts where tid = $1  and nid = $2 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 314 "YL_db.pgc"
 if (sqlca.sqlcode!=0) /*дитя нет*/ YL_abort("sget_ref-select");
 return wi2;
}
int sget_type(int tid,int nid,char* pth)/*Лес. Возвращает атрибут type узла дерева tid найденного вниз от nid по пути pth*/{
 /*получаем nid целевого*/wi1=sget_nid(tid,nid,pth); wi=tid; 
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select coalesce ( type , 0 ) from dts where tid = $1  and nid = $2 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 319 "YL_db.pgc"
 if (sqlca.sqlcode!=0) /*дитя нет*/ YL_abort("sget_type-select");
 return wi2;
}
void sget_sid(int tid,int nid,char* pth,char* sid)/*Лес. Возвращает атрибут sid узла дерева tid найденного вниз от nid по пути pth*/{
 int dbg=0;
 if(dbg!=0) printf("\n!sget_sid!DEBUG!IN. tid=%i, nid=%i, pth='%s'!",tid,nid,pth);
 sget_attr(4,tid,nid,pth,sid);
 if(dbg!=0) printf("\n!sget_sid!DEBUG!OUT. sid='%s'!",sid);
 return;
}
void sget_v(int tid,int nid,char* pth,char* v)/*Лес. Возвращает атрибут v узла дерева tid найденного вниз от nid по пути pth*/{
 int dbg=0;
 if(dbg!=0) printf("\n!sget_v!DEBUG!IN. tid=%i, nid=%i, pth='%s'!",tid,nid,pth);
 sget_attr(2,tid,nid,pth,v);
 if(dbg!=0) printf("\n!sget_v!DEBUG!OUT. sid='%s'!",v);
 return;
}
void sget_rid(int tid,int nid,char* pth,char* rid)/*Лес. Возвращает атрибут rid узла дерева tid найденного вниз от nid по пути pth*/{
 int dbg=0;
 if(dbg!=0) printf("\n!sget_rid!DEBUG!IN. tid=%i, nid=%i, pth='%s'!",tid,nid,pth);
 sget_attr(1,tid,nid,pth,rid);
 if(dbg!=0) printf("\n!sget_rid!DEBUG!OUT. sid='%s'!",rid);
 return;
}
int sget_strt(int tid)/*Лес. возвращает nid корня дерева по его tid*/{
 wi=tid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select nid from dts where tid = $1  and up is null", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 345 "YL_db.pgc"
  if (sqlca.sqlcode!=0) YL_abort("sget_strt-nid");
 return wi1;
}
/*СТ+Лес*/
int Sget_prime(char *id)/*СТ+Лес. возвращает для функции атрибут prime: 0 - нет, 1 - да.*/{
 /*!!!не проверяет что обратились с функцией - это предусловие корректной работы!!!*/
 int ftid=Sget_tid(id); int fnid=sget_strt(ftid); char frid[22]; sget_rid(ftid,fnid,"1.",frid);
 if((strcmp(frid,"Dcl_prm")==0) || (strcmp(frid,"Dcl_prmfC")==0)) return 1;
 return 0;
}
/**/
void flag_subtree(int tid,int nid)/*Лес. выделяет в дереве поддерево узла nid помечая его узлы 1 а остальные узлы дерева - 0*/{
 /*printf("\n!DEBUG! flag_subtree begins with tid=(%i) nid=(%i).",tid,nid);*/
 /*tid - дерево, nid - корень поддерева*/
 /*установить в tid flg=0.*/
 wi=tid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set flg = 0 where tid = $1 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 361 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("flag_subtree-update-flg-0");
 int cnid=nid;/*текущий обрабатываемый узел*/
 loop:
 /*установить cnid.flg=1.*/
 wi=tid; wi1=cnid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set flg = 1 where tid = $1  and nid = $2 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 366 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("flag_subtree-update-flg-1-root");
 /*найти в дереве узел (У1) с flg=0 ссылающийся на узел с flg=1.*/
 /*если такого нет return.*/
 wi=tid; 
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from dts ch , dts p where ch . tid = p . tid and ch . up = p . nid and ch . tid = $1  and ch . flg = 0 and p . flg = 1", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 370 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("flag_subtree-select-count");
 if (wi1==0) return;/*кончились или не начинались*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select min ( ch . nid ) from dts ch , dts p where ch . tid = p . tid and ch . up = p . nid and ch . tid = $1  and ch . flg = 0 and p . flg = 1", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 372 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("flag_subtree-select-min");
 /*назначить У1 cnid.*/
 cnid=wi1;
 goto loop;
}
void flag2_subtree(int tid,int nid) /*Лес. выделяет в дереве поддерево узла nid помечая его узлы flg2=1 а остальные узлы дерева - flg2=0*/{
 /*tid - дерево, nid - корень поддерева*/
 /*установить в tid flg2=0.*/
 /*printf("\n!flag2_subtree!DEBUG!IN tid=%i, nid=%i.",tid,nid);*/
 wi=tid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set flg2 = 0 where tid = $1 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 382 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("flag2_subtree-update-flg-0");
 int cnid=nid;/*текущий обрабатываемый узел*/
 loop:
 /*установить cnid.flg=1.*/
 /*printf("\n!flag2_subtree!DEBUG!loop tid=%i, cnid=%i.",tid,cnid);*/
 wi=tid; wi1=cnid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set flg2 = 1 where tid = $1  and nid = $2 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 388 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("flag2_subtree-update-flg-1-root");
 /*найти в дереве узел (У1) с flg2=0 ссылающийся на узел с flg2=1.*//*если такого нет return.*/
 wi=tid; 
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from dts ch , dts p where ch . tid = p . tid and ch . up = p . nid and ch . tid = $1  and ch . flg2 = 0 and p . flg2 = 1", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 391 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("flag2_subtree-select-count");
 if (wi1==0) return;/*кончились или не начинались*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select min ( ch . nid ) from dts ch , dts p where ch . tid = p . tid and ch . up = p . nid and ch . tid = $1  and ch . flg2 = 0 and p . flg2 = 1", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 393 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("flag2_subtree-select-min");
 /*назначить У1 cnid.*/
 cnid=wi1;
 goto loop;
}
int get_qua(int tid, int snid)/*Лес. возвращает nid терма квантора либо 0 - не нашёл*/{
 /*tid - ид дерева предложения, snid - стартовый узел Id/trmi*/ 
 char Id_1[YLsbl]/*значение Id-1 при очередном кванторе*/; char crid[22]/*значение текущего rid*/;char iv[YLsbl]/*значение Id.v нашего Id/trmi*/;
 char csid[YLsbl]/*значение sid текущего узла.*/;
 int cnid=snid/*текущий узел на пути вверх. начинаем с Id/trmi*/; 
 int dbg=0;
 /*получаем Id.v (его мы ищем)*/sget_v(tid,snid,"0.",iv); if(dbg==1) printf("\n!get_qua: DEBUG! start tid=%i, snid=%i, iv='%s'.",tid,snid,iv);
 /*Шаг вверх к trmi-узлу.*/  if(dbg==1) printf("\n!get_qua: DEBUG! before step up tid=%i, cnid=%i.",tid,cnid); cnid=sget_up(tid,cnid);
 /*пока текущий узел - term обрабатываем его и шагаем вверх.*/
 do 
 {/*получаем rid*/ sget_rid(tid,cnid,"0.",crid);
  /*если узел ква*/
  if (strcmp(crid,"trma")==0 || strcmp(crid,"trme")==0 || strcmp(crid,"trmc")==0 || strcmp(crid,"trms")==0) {/*l_p _Q_ Id COLON Id term r_p*/
   /*!узел - ква!*/
   /*получаем Id-1.v*/ sget_v(tid,cnid,"3.",Id_1);   if(dbg==1) printf("\n!get_qua: DEBUG! sget_v gives Id_1='%s'.",Id_1);
   /*если совпадают вернуть cnid.*/ if(strcmp(iv,Id_1)==0) return cnid;
  };
  /*!ква но не тот либо не квантор!*/
  /*Шаг вверх.*/  if(dbg==1) printf("\n!get_qua: DEBUG! step up tid=%i, cnid=%i.",tid,cnid); cnid=sget_up(tid,cnid);
 /*получаем sid*/ sget_sid(tid,cnid,"0.",csid);if(dbg==1) printf("\n!get_qua: DEBUG! new csid='%s'.",csid);}
 while (strcmp(csid,"term")==0 || strcmp(csid,"TermList")==0);
 /*обработали все term и не нашли*/ if(dbg==1) printf("\n!get_qua: DEBUG! return not found!"); return 0;
}

int sget_fp(int tid, int nid) /*Лес. возвращает ид узла форм-пар в заголовке или 0 - не найден, -n - найдено n>1*/{
 /*tid - ид дерева определения, nid ид узла Id/trmi - предполагаемого вхождения фп*/
 /*!!!Предполагается что дерево фп выделено флагом flg2=1!!!*/
 int Ilb/*как заглушка*/; char iv[YLsbl] /*значение Id*/;
 sget_v(tid,nid,"0.",iv);
 wi=tid; strcpy(wc,iv);
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from dts where tid = $1  and flg2 = 1 and sid = 'Id' and v = $2 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 428 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sget_fp-select-count");
 if (wi1>1 || wi1==0) return -wi1;/*таких фп много или нет*/
 /*нашли ровно один. получаем nid*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select nid from dts where tid = $1  and flg2 = 1 and sid = 'Id' and v = $2 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 431 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sget_fp-select-nid");
 return wi1;
}
void flag2_fps(int tid)/*Лес. в предложении tid дерево фп выделяется флагом flg2*/{
 /*получить корень списка фп. Идём от корня предложения (у него up - Null) путь="1.5." и мы в Id_list_bch*/
 int Ilb/*nid Id_list_bch*/;
 /*получаем ид узла предложения*/
 int st_nid=sget_strt(tid);
 /*получаем nid Id_list_bch*/
 Ilb=sget_nid(tid,st_nid,"1.5.");
 /*Выделяем флагом-2 поддерево от Id_list_bch.*/
 flag2_subtree(tid,Ilb);
 return;
}
int get_pcm(char* iv)/*Лес. pcm - carrier member. Ищет в `(fmca) Statement : e_m Ide Id e_m` является ли iv элементом основы/сорта.*/{
 /*iv - значение Ide проверяемого на эо*/
 /*Возвращает tid предложения введения эо либо 0*/
 /*ДРВ-алгоритм:ищем в лесу среди st.rid='fmca' И "2.".v=iv*/
 strcpy(wc,iv);
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select s . tid from dts s , dts c where c . tid = s . tid and c . up = s . nid and s . rid = 'fmca' and c . v = $1  and c . irn = 2", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 450 "YL_db.pgc"

 if (sqlca.sqlcode==0) return wi1;
 if (sqlca.sqlcode==100) return 0;
 YL_abort("get_pcm-select");
}
void sput_rid(int tid,int nid,char* v)/*Лес. назначает узлу rid*/{
 wi=tid; wi1=nid; strcpy(wc,v);
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set rid = $1  where tid = $2  and nid = $3 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 457 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sput_rid-update");
}
void sput_v(int tid,int nid,char* v)/*Лес. назначает узлу v*/{
 wi=tid; wi1=nid; strcpy(wc,v);
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set v = $1  where tid = $2  and nid = $3 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 461 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sput_v-update");
}
void sput_ref(int tid,int nid,int ref)/*Лес. назначает узлу ref*/{
 wi=tid; wi1=nid; wi2=ref;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set ref = $1  where tid = $2  and nid = $3 ", 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 465 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sput_ref-update");
}
void sput_irn(int tid,int nid,int v)/*Лес. назначает узлу irn*/{
 wi=tid; wi1=nid; wi2=v;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set irn = $1  where tid = $2  and nid = $3 ", 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 469 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sput_irn-update");
}
void sput_type(int tid,int nid,int type)/*Лес. назначает узлу type*/{
 wi=tid; wi1=nid; wi2=type;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set type = $1  where tid = $2  and nid = $3 ", 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 473 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sput_type-update");
}
void sput_up(int tid,int nid,int v)/*Лес. назначает узлу up*/{
 wi=tid; wi1=nid; wi2=v;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set up = $1  where tid = $2  and nid = $3 ", 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 477 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sput_up-update");
}
void sput_flg(int tid,int nid,int flg)/*Лес. назначает узлу flg*/{
 wi=tid; wi1=nid; wi2=flg;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set flg = $1  where tid = $2  and nid = $3 ", 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 481 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sput_flg-update");
}
void sput_p_flg(int tid,int nid,int flg)/*Лес. делает up и назначает flg родителю*/{
 int pid=sget_up(tid,nid)/*получаем папу*/;
 wi=tid; wi1=pid; wi2=flg;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set flg = $1  where tid = $2  and nid = $3 ", 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 486 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sput_p_flg-update");
}
void sput_p_type(int tid,int nid,int ref,int type)/*Лес. делает up и назначает ref, type родителю*/{
 int pid=sget_up(tid,nid)/*получаем папу*/;
 wi=tid; wi1=pid; wi2=ref; wi3=type;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set ref = $1  , type = $2  where tid = $3  and nid = $4 ", 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi3),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 491 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sput_p_type-update");
}
int type_trmi(int tid, int nid, int mod){/*Лес. первичная типизация Id/trmi и trmi узлов с Id.flg=1. свопер и их trmi типизируются в <0,0>, полиморфа - <Null,Null>
 предусловия: а) Общие WFC терма выполнены - ошибок не может быть:-) б) фп в голове уже типизированы.*/
 /*tid - ид дерева предложения, nid - ид корня терма. после обработки Id-узла и ап их flg всегда в 2. mod нужен для фп. возвращает к-во свопер не привязанных к фп, т.е. ошибочных*/
 /*Обработка см. таблицу ТермТиО в Реализация и root*/
 char iv[YLsbl]/*значение Id...*/;char wv[YLsbl]/*рабочая*/;char t[22]/*тип обнаруженного эт*/; int refv/*значение ref узла либо код ошибки (<0)*/; 
 int typev=0/*nid узла типа (сорта или сига)*/;
 int cnid/*текущий обрабатываемый Id-узел*/;int typep/*тип родителю*/;int qnid/*nid trmQ узла для связанной переменной*/; 
 int fvn=0/*к-во свопер*/;
 if(mod==2)/*терм определения*//*выделяем поддерево форм-пар (через flg2).*/flag2_fps(tid);
 loop:
 wi=tid; /*strcpy(wc,"Id"); strcpy(wc1,"trmi");*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from dts ch , dts p where ch . tid = p . tid and ch . up = p . nid and ch . flg = 1 and ch . tid = $1  and ch . sid = 'Id' and p . rid = 'trmi'", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 504 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("type_trmi-select-count");
 if (wi1==0) goto end;/*кончились или не начинались*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select min ( ch . nid ) from dts ch , dts p where ch . tid = p . tid and ch . up = p . nid and ch . flg = 1 and ch . tid = $1  and ch . sid = 'Id' and p . rid = 'trmi'", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 506 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("type_trmi-select-min");
 cnid=wi1; 
 /*обработка очередного узла*/
 /*получаем v.Id*/sget_v(tid,cnid,"0.",iv);
 /*проверяем наличие значения Id среди элементов теории*/
 int exiRC=e_exists_q(iv,t);
 if (exiRC!=1)/*есть в эт!*/ {if (exiRC==0){/*Id один. привязываем*/
  /*получаем tid декларации из entities!!!*/refv=Sget_tid(iv);
  /*получаем type для func: nid сигнатуры в предложении декларации.*/
  /*получаем nid корня дерева предл*/
  int r_nid=sget_strt(refv); char path[111]/*путь к узлу*/; strcpy(path,"1.3."); 
  typev=sget_nid(refv,r_nid,path);
  /*назначаем тип родителю*/  sput_p_type(tid,cnid,refv,typev);sput_p_flg(tid,cnid,2);
  goto fin;
  } else {/*полиморфа: оставляем Null!!!*//*printf("\n!type_trmi!DEBUG! %s is a polymorphic func!",iv);*/ goto conti;};
 };
 /*не элемент теории*/
 /*проверяем на связанность квантором*/
 qnid=get_qua(tid,cnid);
 if(qnid!=0)/*квантор нашёлся*/{refv=0; typev=qnid; /*получаем nid сорта (5-ый)*/ typep=sget_nid(tid,typev,"5.");
   /*назначаем тип родителю*/ sput_p_type(tid,cnid,tid,typep);sput_p_flg(tid,cnid,2);
 goto fin;};
 if(mod==2){/*проверяем на связанность фп*//*получаем ссылку на фп в голове либо 0*/int fpnid=sget_fp(tid,cnid); 
  if(fpnid>0)/*фп нашёлся*/{refv=fpnid; typev=0;
   /*получаем type из фп его надо занести родителю.*/typep=sget_type(tid,fpnid,"0.");
   /*назначаем тип родителю*/ sput_p_type(tid,cnid,tid,typep);  sput_p_flg(tid,cnid,2);
  goto fin;};
 };
 /*свободная переменная даже в терме определения (если мы в нём;-)*/
 if(mod==2) printf("\n!type_trmi!ERROR! Free var '%s'(%i,%i) not assigned to formal parameter! WFC(trmi-3)",iv,tid,cnid); 
 else printf("\n!type_trmi!ERROR! Free var '%s'(%i,%i) is not allowed! WFC(st-11-1)",iv,tid,cnid); 
 fvn=fvn+1; typev=0; refv=0;  /*назначаем тип родителю*/  sput_p_type(tid,cnid,refv,typev);sput_p_flg(tid,cnid,2);
 fin:/*заносим ref, type*/sput_ref(tid,cnid,refv);sput_type(tid,cnid,typev);
 conti:/*заносим flg - обработан*/sput_flg(tid,cnid,2);
 goto loop;
 end:return fvn;
}
int check_entity_sort(char* iv){/*проверяет что строка - предметный сорт. возвращает RC: 0 - ОК, 1 - не эт, 2 - не сорт, 3 - не предметный.*/
 /*проверяем наличие значения Id среди элементов теории*/
 char t[22]/*рабочая: сначала тип обнаруженного эт, за тем rid*/;
 if (e_exists_q(iv,t)!=0)/*не элемент теории*/return 1;
 /*есть в эт!*/
 if (strcmp(t,"sort")!=0) return 2;
 /*Id допустим. проверяем что сорт предметный*/
 /*получаем  из entities tid и по нему rid ребё: у РВ он Dcl-2*/
 int tid=Sget_tid(iv); int nid=sget_strt(tid); sget_rid(tid,nid,"1.",t);
 if (strcmp(t,"Dcl-2")==0)/*сорт РВ*/return 3;
 /*ОК*/
 return 0;	
}
int WFC_trmQ_1(int tid) /*Лес. проверка WFC(trmQ-1),т.е. Id=(trma, trme)\5 - с флагом 1: проверяет что Id сорт и предметный. Возвращает: 0 - ОК, -N - к-во ошибок*/{
 char iv[YLsbl]/*рабочая*/;char t[22]/*тип обнаруженного эт*/; int RC=0/*0 либо счётчик ошибок (<0)*/;int rc;
 int cnid/*текущий обрабатываемый узел*/;
 /*критерий отбора под флагом терма: sid='Id', irn=5! +$$$это не хорошая оптимизация основанная на том что во ВСЕЙ КСГ больше нет Id с номером 5!!!*/
 wi=tid;
 /* declare WFC_trmQ_1 cursor for select nid from dts where flg = 1 and tid = $1  and sid = 'Id' and irn = 5 */
#line 561 "YL_db.pgc"

 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "declare WFC_trmQ_1 cursor for select nid from dts where flg = 1 and tid = $1  and sid = 'Id' and irn = 5", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 562 "YL_db.pgc"
if (sqlca.sqlcode!=0) YL_abort("WFC_trmQ_1-OPEN");
 /* exec sql whenever not found  goto  cend ; */
#line 563 "YL_db.pgc"

 loop:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "fetch WFC_trmQ_1", ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 565 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 565 "YL_db.pgc"

 cnid=wi1; 
 /*обработка очередного узла*/
 /*получаем v - значение Id*/sget_v(tid,cnid,"0.",iv);
 rc=check_entity_sort(iv);
 /*проверяем наличие значения Id среди элементов теории*/
 if(rc==1){/*не элемент теории*/printf("\n!WFC_trmQ_1: ERROR! Id '%s' is not a sort! WFC(trmQ-1)",iv); RC=RC-1; goto loop;};
 /*есть в эт!*/
 if(rc==2) {printf("\n!WFC_trmQ_1: ERROR! Id %s is already used for %s and not for sort! WFC(trmQ-1)",iv,t); RC=RC-1;goto loop;};
 /*Id допустим. проверяем что сорт предметный*/
 if(rc==3)/*сорт РВ*/{printf("\n!WFC_trmQ_1: ERROR! Id '%s' is RE-sort re=(%s) - forbidden! WFC(trmQ-1)",iv,wc1); RC=RC-1;goto loop;};
 if(rc!=0)/*!!!рассогласованность Сиф*/{printf("\n!WFC_trmQ_1: ABORT! Bad rc=%i from check_entity_sort!",rc); exit(EXIT_FAILURE);};
 /*ОК*/
 goto loop;
 cend:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "close WFC_trmQ_1", ECPGt_EOIT, ECPGt_EORT);}
#line 580 "YL_db.pgc"

 /* exec sql whenever not found  continue ; */
#line 581 "YL_db.pgc"

 return RC;
}
int WFC_trmQ_2(int tid,int mod) /*Лес. проверка 2-х(!)WFC для ква-пер под флагом 1. под флагом - терм! Возвращает: 0 - ОК, -N - к-во ошибок*/{
 char iv[YLsbl]/*рабочая*/;char t[22]/*тип обнаруженного эт*/; int RC=0/*0 либо код ошибки (<0)*/;
 int cnid/*текущий обрабатываемый узел*/;
 /*критерий отбора под флагом терма: rid родителя: trme или trma, irn=3, т.е. ква-пер!*/
 wi=tid;
 /* declare WFC_trmQ_2 cursor for select c . nid from dts c , dts p where c . up = p . nid and p . tid = $1  and c . tid = $2  and ( p . rid = 'trme' or p . rid = 'trma' ) and c . flg = 1 and c . irn = 3 */
#line 589 "YL_db.pgc"

 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "declare WFC_trmQ_2 cursor for select c . nid from dts c , dts p where c . up = p . nid and p . tid = $1  and c . tid = $2  and ( p . rid = 'trme' or p . rid = 'trma' ) and c . flg = 1 and c . irn = 3", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 590 "YL_db.pgc"
if (sqlca.sqlcode!=0) YL_abort("WFC_trmQ_2-OPEN");
 /* exec sql whenever not found  goto  cend ; */
#line 591 "YL_db.pgc"

 loop:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "fetch WFC_trmQ_2", ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 593 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 593 "YL_db.pgc"

 cnid=wi1; 
 /*обработка очередного узла*/
 /*получаем v - значение Id*/sget_v(tid,cnid,"0.",iv);
 /*для КСт - ошибка:мы в КСт нашли квантор*/if(mod==4) {printf("\n!WFC_trmQ_2:ERROR! Id '%s' is not a function in FMt! WFC(fmt-2)",iv); RC=RC-1; goto loop;};
 /*проверяем наличие значения Id среди элементов теории*/
 if (e_exists_q(iv,t)==1)/*не элемент теории*/goto loop;
 /*есть в эт!*/ printf("\n!WFC_trmQ_2:ERROR! Id '%s' is already used for %s - forbidden! WFC(trmQ-2)",iv,t); RC=RC-1;
 goto loop;
 cend:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "close WFC_trmQ_2", ECPGt_EOIT, ECPGt_EORT);}
#line 603 "YL_db.pgc"

 /* exec sql whenever not found  continue ; */
#line 604 "YL_db.pgc"

 return RC;
}
int WFC_deff_7(int tid) /*Лес. проверка WFC(deff-7),т.е. что фп употреблён. Возвращает: 0 - ОК, -N - к-во ошибок*/{
 char iv[YLsbl]/*рабочая*/;char t[22]/*тип обнаруженного эт*/; int RC=0/*0 либо код ошибки (<0)*/;
 int cnid/*текущий обрабатываемый узел*/;int pid/*папа текущего*/;
 /*надо обойти все Id/Id_List/Id_List_bch и для каждого: найти trmi\1 на него ссылающиеся: ref=nid-фп, type=0. 
   !!!ref может случайно совпасть с (id декларации для эт поэтому нужен type=0!*/
 wi=tid;
 /* declare WFC_deff_7 cursor for select c . nid from dts c , dts p , dts pp , dts ppp where c . up = p . nid and p . up = pp . nid and pp . up = ppp . nid and c . tid = $1  and p . tid = $2  and pp . tid = $3  and ppp . tid = $4  and c . sid = 'Id' and ppp . rid = '#Id_list_bch' */
#line 614 "YL_db.pgc"

 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "declare WFC_deff_7 cursor for select c . nid from dts c , dts p , dts pp , dts ppp where c . up = p . nid and p . up = pp . nid and pp . up = ppp . nid and c . tid = $1  and p . tid = $2  and pp . tid = $3  and ppp . tid = $4  and c . sid = 'Id' and ppp . rid = '#Id_list_bch'", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 615 "YL_db.pgc"
if (sqlca.sqlcode!=0) YL_abort("WFC_deff_7-OPEN");
 /* exec sql whenever not found  goto  cend ; */
#line 616 "YL_db.pgc"

 loop:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "fetch WFC_deff_7", ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 618 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 618 "YL_db.pgc"

 cnid=wi1; 
 /*обработка очередного узла*/
 /*получаем v - значение Id*/sget_v(tid,cnid,"0.",iv);
 /*проверяем что у него есть УПОТРЕБЛЕНИЯ. !!!Считается что ссылка во вхождения уже занесена в Id/trmi: ref=cnid and type=0!!!*/
 wi=tid; wi2=cnid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from dts ch , dts p where ch . tid = $1  and p . tid = $2  and ch . up = p . nid and ch . sid = 'Id' and p . rid = 'trmi' and ch . ref = $3  and ch . type = 0", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 625 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 625 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("WFC_deff_7-select-count-1");
 if (wi1==0) /*никто не ссылается!*/{printf("\n!WFC_deff_7:ERROR! form-par '%s' has no usage! WFC(deff-7)",iv);RC=RC-1;};
 goto loop;
 cend:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "close WFC_deff_7", ECPGt_EOIT, ECPGt_EORT);}
#line 629 "YL_db.pgc"

 /* exec sql whenever not found  continue ; */
#line 630 "YL_db.pgc"

 return RC;
}
int WFC_trmQ_3(int tid) /*Лес. проверка WFC(trmQ-3),т.е. Id=(trma, trme)\3 - с флагом 1: проверяет что есть употребления. Возвращает: 0 - ОК, -N - к-во ошибок*/{
 char iv[YLsbl]/*рабочая*/;char t[22]/*тип обнаруженного эт*/; int RC=0/*0 либо код ошибки (<0)*/;
 int cnid/*текущий обрабатываемый узел*/;int pid/*папа текущего*/;
 wi=tid;
 /* declare WFC_trmQ_3 cursor for select c . nid from dts c , dts p where c . up = p . nid and p . tid = $1  and c . tid = $2  and ( p . rid = 'trme' or p . rid = 'trma' ) and c . flg = 1 and c . irn = 3 */
#line 637 "YL_db.pgc"

 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "declare WFC_trmQ_3 cursor for select c . nid from dts c , dts p where c . up = p . nid and p . tid = $1  and c . tid = $2  and ( p . rid = 'trme' or p . rid = 'trma' ) and c . flg = 1 and c . irn = 3", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 638 "YL_db.pgc"
if (sqlca.sqlcode!=0) YL_abort("WFC_trmQ_3-OPEN");
 /* exec sql whenever not found  goto  cend ; */
#line 639 "YL_db.pgc"

 loop:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "fetch WFC_trmQ_3", ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 641 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 641 "YL_db.pgc"

 cnid=wi1; 
 /*обработка очередного узла*/
 /*получаем v - значение Id*/sget_v(tid,cnid,"0.",iv);
 /*проверяем что у него есть УПОТРЕБЛЕНИЯ. !!!Считается что ссылка во вхождения уже занесена и занесена в type!!!*/
 pid=sget_up(tid,cnid)/*получаем папу*/;
 wi=tid; wi2=pid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from dts ch where ch . tid = $1  and ch . sid = 'Id' and ch . type = $2 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 648 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 648 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("WFC_trmQ_3-select-count-1");
 if (wi1==0) /*никто не ссылается!*/{printf("\n!WFC_trmQ_3:ERROR! Id '%s' has no usage! WFC(trmQ-3)",iv);RC=RC-1;};
 goto loop;
 cend:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "close WFC_trmQ_3", ECPGt_EOIT, ECPGt_EORT);}
#line 652 "YL_db.pgc"

 /* exec sql whenever not found  continue ; */
#line 653 "YL_db.pgc"

 return RC;
}
void type_Ide(int tid, int nid, char* sort){/*мы в узле _trmRE!!! дообработка значения Ide: если оно привязано к предметному сорту, то в sort возвращается его ид*/
 char iv[YLsbl]/*значение Ide...*/;
 /*получаем v.Ide*/sget_v(tid,nid,"1.",iv);
 /*получаем предметный сорт*/
 int mtid=get_pcm(iv);
 if(mtid==0)return/*это сэо!*/;
 /*мы в !!-предложении приписывания эо сорту*/
 /*получаем nid корня предл*/ int r_nid=sget_strt(mtid);
 /*получаем v сорта (3-ый ребё)*/ sget_v(mtid,r_nid,"3.",iv);
 /*возвращаем сорт*/ strcpy(sort,iv); 
 return; 
}
void type__trmRE(int tid){/*Лес. типизация узлов правила _trmRE (вида нт0:нт1|нт2...)
 в рамках выделенного (flg=1) терма дерева tid*/
 /*проверяем что _trmRE есть в терме. нет - возврат. 
 есть: для каждого флажкового _trmRE ищем в entities сорт=.sid первого (и единственного!) ребё: 
 нет - ABORT - после проверки WFC он должен быть(!), есть - берём его tid и nid узла с Id сорта 
  и закатываем их в ref,type _trmRE, выставляя флаг в 2.
  !!!Доп обработка Ide: если значение приписано предметному сорту s, то тип s!*/
 int stid/*дерево декларации сорта=.\sid*/;
 int type/*nid Id сорта=.\sid*/;char sid[22]; int cnid;/*nid текущего _trmRE узла*/
 wi=tid; 
 /*курсор по узлам с rid=_trmRE. получаем nid очередного*/
 /* declare type__trmRE cursor for select nid from dts where tid = $1  and rid = '_trmRE' and flg = 1 */
#line 679 "YL_db.pgc"

 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "declare type__trmRE cursor for select nid from dts where tid = $1  and rid = '_trmRE' and flg = 1", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 680 "YL_db.pgc"
if (sqlca.sqlcode!=0) YL_abort("type__trmRE-OPEN");
 /* exec sql whenever not found  goto  cend ; */
#line 681 "YL_db.pgc"

 loop:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "fetch type__trmRE", ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 683 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 683 "YL_db.pgc"

 cnid=wi1;
 /*получаем sid ребё. он же обычно - ид сорта*/
 sget_sid(tid,cnid,"1.",sid);type_Ide(tid,cnid,sid)/*возможная коррекция сорта Ide*/;
 stid=Sget_tid(sid)/*дерево декларации сорта*/;
 int snid=sget_strt(stid)/*его корень*/;
 /*получить в type - nid Id сорта*/type=sget_nid(stid,snid,"1.2.");
 /*заносим ref,type и выставляем флаг - обработан.*/
 wi=tid; wi1=stid; wi2=type;wi3=cnid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set ref = $1  , type = $2  , flg = 2 where tid = $3  and nid = $4  and rid = '_trmRE' and flg = 1", 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi3),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);
#line 692 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 692 "YL_db.pgc"
 
 if (sqlca.sqlcode!=0 && sqlca.sqlcode!=100) YL_abort("type_trmn-update");
 goto loop;
 cend:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "close type__trmRE", ECPGt_EOIT, ECPGt_EORT);}
#line 696 "YL_db.pgc"

 /* exec sql whenever not found  continue ; */
#line 697 "YL_db.pgc"

 return;
}
void trmi_deflag(int tid)/*Лес. устанавливает флаг у не обработанных trmi узлов в обработан*/{
 wi=tid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set flg = 2 where tid = $1  and rid = 'trmi' and flg = 1", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 702 "YL_db.pgc"
 if (sqlca.sqlcode!=0 && sqlca.sqlcode!=100) YL_abort("trmi_deflag-update");
}
int flg_all_done_q(int tid,int nid)/*Лес. выдаёт ответ на вопрос: у детей узла (tid,nid) значение flg у всех YL_NODE_DONE? 0 - нет, 1 - да*/{
 /*получаем к-во детей*/
 wi=tid; wi1=nid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from dts where tid = $1  and up = $2 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi3),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 707 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("flg_all_done_q-select-1");
 int chn=wi3;
 /*получаем к-во YL_NODE_DONE детей*/
 wi=tid; wi1=nid; wi2=YL_NODE_DONE;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from dts where tid = $1  and up = $2  and flg = $3 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi3),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 711 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("flg_all_done_q-select-2");
 int chn_=wi3;
 /*printf("\n!flg_all_done_q!DEBUG!before return. tid=%i, nid=%i, chn=%i.",tid,nid,chn);*/
 if (chn==chn_) return 1; else return 0;
}
int sget_chn(int tid, int id)/*Лес. возвращает количество детей данного узла (id) в данном дереве (tid).*/{
 wi=tid; wi1=id;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from dts where up = $1  and tid = $2 ", 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 718 "YL_db.pgc"
  if (sqlca.sqlcode!=0) YL_abort("sget_chn-sel_count");
 /*DEBUG*//*printf("\n(sget_chn)before return. tid=%i, nid=%i, chn=%i.",tid,id,wi2);*/
 return wi2;
}
int sget_chi(int tid,int nid,int i)/*Лес. выдаёт ид i-ого ребё учитывая изврат TermList*/{
 char sid[22];char cw[123]/*рабочая*/; int chi/*номер ребё в irn*/;
 /*получить sid*/sget_sid(tid,nid,"0.",sid); 
 if(strcmp(sid,"TermList")==0) {/*получить к-во дет*/int chn=sget_chn(tid,nid); chi=i-1-chn;} else chi=i;
 sprintf(cw,"%i.",chi)/*путь к ребё*/;
 return(sget_nid(tid,nid,cw));
}
int scmp_trs(int tid1,int nid1,int tid2,int nid2,int ln)/*Лес. сравнение двух поддеревьев: строение и равенство значений sid, v*/{
 /*возвращает RC: 0 - OK*//*ln - номер уровня вызова - задавать - 1. для отладки.*/
 /*сравнить атрибуты У1 У2*/
 /*printf("\n!scmp_trs!DEBUG!in. ln=%i! tid1=%i, nid1=%i, tid2=%i, nid2=%i.",ln,tid1,nid1,tid2,nid2);*/
 char v1[YLsbl];char v2[YLsbl]; sget_v(tid1,nid1,"0.",v1); sget_v(tid2,nid2,"0.",v2); if(strcmp(v1,v2)!=0) return 11;
 char sid1[22]; char sid2[22];sget_sid(tid1,nid1,"0.",sid1); sget_sid(tid2,nid2,"0.",sid2); if(strcmp(sid1,sid2)!=0) return 12;
 /*кп1=get_chn(У1). кп2=get_chn(У2). если кп1<>кп2 return 2.*/int cn1=sget_chn(tid1,nid1); int cn2=sget_chn(tid2,nid2); if(cn1!=cn2) return 2;
 /*если кп1=0 return 0.*/ if(cn1==0) return 0;
 int ch1i; int ch2i; int RC;
 int i;for(i=1;i<cn1+1;i++){
  ch1i=sget_chi(tid1,nid1,i); ch2i=sget_chi(tid2,nid2,i);
  RC=scmp_trs(tid1,ch1i,tid2,ch2i,ln+1); if(RC!=0) return RC;
 };
 return 0;
}
int sget_fpt(int tid,int nid,int i)/*Лес. выдаёт ид узла типа элемента сигнатуры под i-ым sig_e*/{
  char cw[123]/*рабочая*/; 
  /*получаем rid*/sprintf(cw,"%i.",i)/*путь к ребё*/;sget_rid(tid,nid,cw,cw)/*rid*/;
  if(strcmp(cw,"sig_eF")==0) {sprintf(cw,"%i.2.",i)/*путь к типу*/; return(sget_nid(tid,nid,cw));}
  else if(strcmp(cw,"sig_eI")==0) {sprintf(cw,"%i.1.",i)/*путь к типу*/; return(sget_nid(tid,nid,cw));}
  else/*!!!попадание сюда означет необрабатываемый rid!*/{printf("\n!sget_fpt: Unknown rid='%s'. Abort!",cw);exit(EXIT_FAILURE);};
}
void sprt_subtreeL(int tid, int nid)/*Лес. выдаёт исходный текст поддерева: печатает (v) листьев заданного узла в порядке irn. строка обрамляется*/{
 int chi/*nid i-ого ребё*/; char v[YLsbl]; char sid[22];
 int chn=sget_chn(tid,nid); 
 int dbg=0;
 if (dbg==1) printf("\n sprt_subtreeL(tid=%i nid=%i).",tid,nid);
 if(chn==0) {sget_v(tid,nid,"0.",v); sget_sid(tid,nid,"0.",sid); 
  if(strcmp(sid,"String")==0) printf(" \"%s\"",v); else printf(" %s",v);
  if (dbg==1) printf("\n sprt_subtreeL RETURN");
  return;
 };
 /*есть дети*/
 int i; for (i=1;i<chn+1;i++){/*обработать i-ого*/
  chi=sget_chi(tid,nid,i); sprt_subtreeL(tid,chi);
 };
 if (dbg==1) printf("\n sprt_subtreeL RETURN");
 return;
}
void sprt_subtreeLD(int tid, int nid){/*Лес. выдаёт дамп поддерева: xml-элемент (sid) со всей атрибутикой узла*/
 int chi/*nid i-ого ребё*/; char sid[22]; int up; char rid[22]; char v[YLsbl]; int irn; int ref; int flg; int flg2; int type;
  sget_sid(tid,nid,"0.",sid); up=sget_up(tid,nid); sget_rid(tid,nid,"0.",rid); sget_v(tid,nid,"0.",v); irn=sget_irn(tid,nid); 
  ref=sget_ref(tid,nid,"0."); flg=sget_flg(tid,nid,"0."); flg2=sget_flg2(tid,nid,"0."); type=sget_type(tid,nid,"0.");
 int chn=sget_chn(tid,nid); 
 /*запев*/printf("<%s tid='%i' nid='%i' up='%i' rid='%s' v='%s' irn='%i' ref='%i' type='%i' flg='%i' flg2='%i'",sid,tid,nid,up,rid,v,irn,ref,type,flg,flg2);
 if(chn==0) {printf("/>"); return;} else printf(">");
 /*есть дети*/
 int i; for (i=1;i<chn+1;i++){/*обработать i-ого*/
  chi=sget_chi(tid,nid,i); sprt_subtreeLD(tid,chi);
 };printf("</%s>",sid);return;
}
void sprt_treeLD(int tid){/*Лес. выдаёт дамп дерева: xml-элемент (sid) со всей атрибутикой узла*/
 /*получаем корень дерева*/ int rt=sget_strt(tid);
 sprt_subtreeLD(tid,rt);
}
void fm_strcmp(char* arg1, char* arg2, char* res){/*сравнивает две строки на тождество и возвращает _True|_False*/
 if(strcmp(arg1,arg2)==0) strcpy(res,"_True"); else strcpy(res,"_False");
 return;
}
int fm_cmpVal(char* arg1, char* arg2, char* s){/*сравнивает две строки как величины сорта s. 
 возвращает как strcmp: 0 - равны, >0 - первое больше, <0 - первое меньше*/
 /*printf("\n!fm_cmpVal!DEBUG!arg1='%s', arg2='%s', s='%s'.",arg1,arg2,s);*/
 /*if(strcmp(s,"Number")==0) {float n1=atof(arg1);float n2=atof(arg2); if(n1>n2) return 1;if(n1<n2) return -1; return 0;};*/
 if((strcmp(s,"Number")==0) || (strcmp(s,"Year")==0)) {float n1=strtod(arg1,NULL);float n2=strtod(arg2,NULL); if(n1>n2) return 1;if(n1<n2) return -1; return 0;};
 return strcmp(arg1,arg2);
}
void fm_req(char* arg1, char* arg2, char* res){/*сравнивает две строки типа Number, Year на равенство и возвращает _True|_False*/
 if(fm_cmpVal(arg1,arg2,"Number")==0) strcpy(res,"_True"); else strcpy(res,"_False");
 return;
}
void fm_rlt(char* arg1, char* arg2, char* res){/*сравнивает две строки типа Number, Year на меньше и возвращает _True|_False*/
 if(fm_cmpVal(arg1,arg2,"Number")<0) strcpy(res,"_True"); else strcpy(res,"_False");
 return;
}
void fm_t2s(int tid, int nid, char* s)/*Лес. сериализует в строку s v листьев заданного узла в порядке irn. строчные значения обрамляются*/{
 int chi/*nid i-ого ребё*/; char v[YLsbl]; char sid[22]; char V[YLsbl+3]/*накопитель текущей строки*/;
 int chn=sget_chn(tid,nid); /*printf("\n!fm_t2s!DEBUG!tid=%i, nid=%i, s='%s' chn=%i.",tid,nid,s,chn);*/
 if(chn==0) {sget_v(tid,nid,"0.",v); sget_sid(tid,nid,"0.",sid); 
  if(strcmp(sid,"String")==0) sprintf(V," \"%s\"",v); else sprintf(V," %s",v); strcat(s,V); return;
 };
 /*есть дети*/
 int i; for (i=1;i<chn+1;i++){/*обработать i-ого*/
  chi=sget_chi(tid,nid,i); fm_t2s(tid,chi,s);
 };
}
void trm_t2s(int tid, int nid, char* s){/*Лес. trmf-узел при первом входе? в конец(!) строки s сериализует v детей в порядке irn. строчные значения обрамляются*/
 /*алгоритм:
  -если значение в v есть выдаём значение с пробелом _обрамляя_ строку! !!!0-строка для String не должна считаться отсутствием значения!!!
  <значения нет>
  -если узел trmf, то выдаём trm_t2s(<его терм-1>) + trm_t2s(<его терм-лист>) --!!!как вызов ф-и
  -ошибка - падаем.
*/int dbg=0;
 int chi/*nid i-ого ребё*/; char v[YLsbl]; char rid[22]; char V[YLsbl+1]/*накопитель текущей строки*/;
 sget_rid(tid,nid,"0.",rid); sget_v(tid,nid,"0.",v)/*!!!не предполагаем что "" есть обязательно отсутствие значения (для строк это не так)*/;
	int ref=sget_ref(tid,nid,"0."); int type=sget_type(tid,nid,"0.");/*получили ссылку на тип значения текущего узла*/
	char sid[22];sget_sid(ref,type,"0.",sid);char vt[22];sget_v(ref,type,"0.",vt);
	if(dbg!=0) printf("\n!trm_t2s!DEBUG!point-1. sid='%s' vt='%s' v='%s' rid='%s'.",sid,vt,v,rid);
	if((strcmp(sid,"Id")==0)&&(strcmp(vt,"String")==0)&&(strcmp(rid,"trmf")!=0)) {sprintf(V," \"%s\"",v);strcat(s,V); return;};
 if(v[0]!=0) {sprintf(V," %s",v); strcat(s,V); return;};
 /*значения нет*/
	if(dbg!=0) printf("\n!trm_t2s!DEBUG!point-2. no value. rid='%s'.",rid);
 if(strcmp(rid,"trmf")==0) {/*term l_p TermList r_p*/
  int t1_id/*id вершины терма-1*/; /*получаем корень терма-1*/ t1_id=sget_nid(tid,nid,"1.");
   trm_t2s(tid,t1_id,s); strcat(s," (");
   int TL_id/*id вершины TermList*/; /*получаем корень TermList*/ TL_id=sget_nid(tid,nid,"3.");
   int chn=sget_chn(tid,TL_id)/*количество детей*/;
   if(chn==0) strcat(s," ");
   else {int i; for (i=1;i<chn+1;i++){/*обработать i-ого*/ chi=sget_chi(tid,TL_id,i); trm_t2s(tid,chi,s);};};
   strcat(s," )"); return;
 };
 /*узел не trmf*/printf("\n!trm_t2s:node tid=%i, nid=%i, rid=%s has NO VALUE. Abort!",tid,nid,rid);exit(EXIT_FAILURE);
}
void trm_cl_trmf_v(int tid, int nid){/*Лес. узел терма. назначает v="" у всех trmf узлов вниз от заданного узла.*/
 /*алгоритм: обходим поддерево. если узел trmf назначаем v в "".*/
 int chi/*nid i-ого ребё*/; char v0[1]=""/*назначаемое значение*/; char rid[22];
 int chn=sget_chn(tid,nid)/*количество детей*/; if(chn==0) return;
 sget_rid(tid,nid,"0.",rid);
 if(strcmp(rid,"trmf")==0) sput_v(tid,nid,v0);
 /*обработать детей*/
 int i; for (i=1;i<chn+1;i++){/*обработать i-ого*/ chi=sget_chi(tid,nid,i); trm_cl_trmf_v(tid,chi);};
 return;
}
int sys_get_ntn(){/*возвращает номер для нового дерева в лесу и накручивает счётчик.*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select ftrn from system where id = 'YL'", ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 852 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sys_get_ntn-sel");
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update system set ftrn = ftrn + 1 where id = 'YL'", ECPGt_EOIT, ECPGt_EORT);}
#line 853 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sys_get_ntn-upd");
 int ntn=wi1;
 return ntn/*номер нового дерева в хранилище*/;
} 
int st_clone(int tid){/*делает копию дерева в лесу и возвращает его tid*/
 wi1=sys_get_ntn()/*получаем номер нового дерева*/; wi2=tid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "insert into dts ( tid , nid , up , sid , rid , v , irn , ref , type ) select $1  , nid , up , sid , rid , v , irn , ref , type from dts where tid = $2 ", 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 859 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("st_clone-ins");
 return wi1;/*возвращаем номер клона*/
}
int cpin_subtree(int tid1,int nid1,int tid2,int flg){/*алес(Z). копирует поддерево (пд1) в дерево д2, устанавливая БД-flg в flg-параметр. возвращет новый nid корня пд. up корня смысла не имеет!*/
 /*Замечание-2. В Р-реализации у нас 4 фундаментальных колонки поддерживающих всё строение (Лес упор-дер): tid, nid, up, irn. 
   Но реализация такова, что состав остальных атрибутов Р-модели задействован! Поэтому (Z)!
 *//*printf("\n!cpin_subtree!DEBUG!IN tid1=%i, nid1=%i, tid2=%i, flg=%i.",tid1,nid1,tid2,flg);*/
 /*выделить пд1 флагом flg2 but flg*/flag2_subtree(tid1,nid1);
 /*а)Скопировать пд1 в д2.*/
 /*а1)Получить DELTA. Если макс(д2.nid) < мин(пд1.nid), то DELTA - 0; иначе DELTA = макс(д2) - мин(пд1)+1.
   Получая при копировании к nid +DELTA каждый узел из пд1 не пересечётся с узлами д2.*/
 /*Получить макс(д2.nid)*/wi1=tid2;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select max ( nid ) from dts where tid = $1 ", 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 871 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("cpin_subtree-s-max");
 int M2=wi;
 /*Получить мин(пд1.nid)*/wi1=tid1;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select min ( nid ) from dts where tid = $1  and flg2 = 1", 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 874 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("cpin_subtree-s-min");
 int m1=wi; int DELTA;
 if(M2<m1) DELTA=0; else DELTA=M2-m1+1;
 /*(а1*/
 /*копируем выставляя flg*/wi=DELTA; wi1=tid1; wi2=tid2;wi3=flg;/*DELTA идёт в nid и up сохраняя строение в-себе-дерева. Конечно up корня смысла не имеет*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "insert into dts ( tid , nid , up , sid , rid , v , irn , ref , type , flg ) select $1  , nid + $2  , up + $3  , sid , rid , v , irn , ref , type , $4  from dts where tid = $5  and flg2 = 1", 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi3),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 879 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("cpin_subtree-ins-sel");
 /*(а*/
 return nid1+DELTA;
}
void del_subtree(int tid,int nid){/*удаляет поддерево помечая его flg2*/
 /*printf("\n!del_subtree!DEBUG!IN tid=%i, nid=%i.",tid,nid);*/
 /*выделить пд флагом flg2*/flag2_subtree(tid,nid);
 wi1=tid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "delete from dts where tid = $1  and flg2 = 1", 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 887 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("del_subtree-delete"); 
 return;
}
void subst_stree(int tid1,int nid1,int tid2,int nid2, int flg){/*подставляет поддерево (пд1) с flg на место поддерева (пд2).*/
 /*Замечание-1. Мы работаем с упорядоченными деревьями. На графах можно считать что упорядочены стрелки и тем самым переподключения стрелки достаточно для сохранения структуры упор-дер. 
   Замечание-2. В Р-реализации у нас 4 фундаментальных колонки поддерживающих всё строение (Лес упор-дер): tid, nid, up, irn. 
   Но реализация такова, что состав остальных атрибутов Р-модели задействован! Поэтому (Z)!
 *//*printf("\n!subst_stree!DEBUG! begin tid1=%i",tid1);*/
 /*Скопировать пд1 в д2.*/int nnid1=cpin_subtree(tid1,nid1,tid2,flg);
 /*Переставить нач стрелки из корня пд2 к корню копии пд1. Здесь лишь дублируем - удаление довершит.*/
 int st2up=sget_up(tid2,nid2); int st2irn=sget_irn(tid2,nid2); sput_up(tid2,nnid1,st2up);  sput_irn(tid2,nnid1,st2irn);
 /*Удалить пд2.*/del_subtree(tid2,nid2);
 return;
}
int deff_subst(int tid){/*подставляет определения ф-й в термах (без фиксов) заданного предложения.*/
 int dbg=0;
 /*возвращает к-во приведений определений, 0 - не было.*/
 /*!Мы в терме без фиксов! Это важно, т.к. мы ищем аргумент только в TermList! 
 Реализ. Флажкование в принимающем дереве (tid): flg=1 - перебираемые Id для поиска подстановки, 
 flg=2 - КТО (копия терма определения).*/
 int RC=0; int cnid/*текущий узел начала обработки (УНО) - ид узла*/; int cnid_up/*значение его ап*/; int pid/*ид папы*/; int gpid/*ид деда*/;
 char ww[123]=""/*рабочая для rid nid*/; char t[22]/*тип проверяемого*/; 
 char Idv[YLsbl]/*значение Id ф-и*/; 
 if(dbg!=0) {printf("\n!deff_subst!DEBUG! begin tid=%i\n",tid); sprt_treeLD(tid);};
 /*Выделяем флагом все Id в предложении. Замечание. Все Id это много (в т.ч. это за пределами термов, 
 но они отсекутся критерием).*/
 /*flg=0 на всём дереве*/wi=tid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set flg = 0 where tid = $1 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 914 "YL_db.pgc"
  if (sqlca.sqlcode!=0) YL_abort("deff_subst-upd-flg-0");
 strcpy(wc,"Id");
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set flg = 1 where tid = $1  and sid = $2 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 916 "YL_db.pgc"
 
 if(sqlca.sqlcode==100) {printf("\n!deff_subst! term has no Id at all!");return 0/*могут быть термы без Id*/;}; if(sqlca.sqlcode!=0) YL_abort("deff_subst-upd-flg-1");
 int tnid/*идуз терма странс определения*/; int Ilbch_nid/*nid Id_list_bchстранс определения*/; 
 int ttid/*идд странс определения*/;
 int subnid /*корень заменяемого терма*/; int fpgn/*количество групп фп*/; 
 int defstc/*корень копии поддерева определения в дереве подстановки*/;
 /*цикл*/
 loopcnid: wi1=tid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from dts where tid = $1  and flg = 1", 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 924 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("deff_subst-select-count-1");
 if(wi==0) goto end;
  { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select min ( nid ) from dts where tid = $1  and flg = 1", 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 926 "YL_db.pgc"
 if(sqlca.sqlcode!=0) YL_abort("deff_subst-sel-min"); 
  cnid=wi; 
  /*(КУНО) Критерий узла начала обработки (УНО). 
  УНО это Id узел: Id.up.rid='trmi' и Id.up.up.rid='trmf' и не форм-пар и Id.v есть ф-я с определением.
  Получаем для УНО: Idv, ttid - дерево странс определения, tnid - корень терма определения.*/
  /*получаем значение Id:+У:только для отладки!!!*/sget_v(tid,cnid,"0.",Idv);
  /*получаем id родителя*/pid=sget_up(tid,cnid); /*получаем его rid*/ sget_rid(tid,pid,"0.",ww); if(strcmp(ww,"trmi")!=0) goto next;
  /*получаем id деда*/gpid=sget_up(tid,pid); /*получаем его rid*/ sget_rid(tid,gpid,"0.",ww); if(strcmp(ww,"trmf")!=0) goto next;
  /*проверяем что не форм-пар*/ if (sget_type(tid,cnid,"0.")==0) goto next;  
  if (dbg!=0)  printf("\n!deff_subst!DEBUG! begin-1: tid,cnid=%i,%i.",tid,cnid);
  /*проверяем что есть определение: получаем у Id ref - tid декларации. смотрим в ней есть ли определение: это же st-1\Dcl-5!!!*/
  int dtid=sget_ref(tid,cnid,"0.")/*tid исходника декларации*/;
  if (dbg!=0)  printf("\n!deff_subst!DEBUG! before drtnid=sget_strt(dtid):dtid=%i.",dtid);
  int drtnid=sget_strt(dtid)/*nid корня, пока исходника*/;
  /*получаем rid его ребё*/ sget_rid(dtid,drtnid,"1.",ww); if(strcmp(ww,"Dcl-5")!=0) {/*printf("\n!deff_subst!DEBUG!got function without def! Idv value is <%s>",Idv);*/goto next;}
  /*определение есть!*/ 
  RC=RC+1; /*printf("\n!deff_subst!DEBUG! loop! function with def found: cnid=%i Id=%s.",cnid,Idv);*/
  /*б) Получение указателя на терм определения в странс-предложении:*/
  /*б1) получаем ttid, drtnid*/ ttid=sget_ref(dtid,drtnid,"0.");
  if (dbg!=0)  printf("\n!deff_subst!DEBUG! before drtnid=sget_strt(ttid):ttid=%i.",ttid);
  drtnid=sget_strt(ttid)/*nid корня теперь в странс!*/;
  /*б2) получаем  tnid (он 7-ой), Ilbch_nid (он 5-ый). */ tnid=sget_nid(ttid,drtnid,"1.7."); /*получаем Ilbch_nid*/ Ilbch_nid=sget_nid(ttid,drtnid,"1.5.");
  /*Определение. Узел подстановки (subnid) - корень заменяемого терма. 
  Усмотрение. Пусть fpgn - количество групп фп (к-во детей узла Id_list_bch). 
  Место узла подстановки (subnid): subnid на fpgn+1 выше УНО. 
  Док-во. Один ап - до term(trmi) дальше столько апов по term(trmf) сколько групп фп в определении.
  Вычисляем fpgn и получаем subnid.*/
  /*(0-ф-и) технически у нас fpgn=0 и до trmf надо делать дополнительный шаг, т.к. один ап это только trmi!*/
  fpgn=sget_chn(ttid,Ilbch_nid); subnid=cnid; int j;for(j=1;j<fpgn+2;j++) subnid=sget_up(tid,subnid);
  /*0-ф*/if(fpgn==0)subnid=sget_up(tid,subnid);
  /*printf("\n!deff_subst!DEBUG! after fpgn. fpgn=%i subnid=%i.",fpgn,subnid);*/
  /*Копируем терм определения в tid.*/defstc=cpin_subtree(ttid,tnid,tid,2)/*это КОРЕНЬ КОПИИ ТЕРМА ОПРЕДЕЛЕНИЯ (КТО) - и 2 его flg!*/;
  /*Подключаем его корень к дереву так же как subnid.*/
  int st2up=sget_up(tid,subnid); int st2irn=sget_irn(tid,subnid); sput_up(tid,defstc,st2up);  sput_irn(tid,defstc,st2irn);
  /*Для каждого фп в Id_list_bch (пусть текущий - fpnid) Реал: два счётчика: группа, в группе. 
  {Находим для fpnid в tid корень подставляемого терма (strnid) и подставляем(!) его на место _каждого_ вхождения фп в defstc.}*/
  /*реал. первый счётчик - по группам фп, второй - внутри фп.*/
  /*ид текущего trmf*/int cfnid=gpid/*nid первой группы - ид деда*/;
  if(fpgn!=0)for(j=1;j<fpgn+1;j++){/*j - номер группы фп*/
   /*получаем ид j-того Id_list*/int cIl_nid=sget_chi(ttid,Ilbch_nid,j)/*это пока Id_list_b*/; cIl_nid=sget_nid(ttid,cIl_nid,"2.");
   /*получаем к-во фп в группе*/int cgfpn=sget_chn(ttid,cIl_nid);
   int k;for(k=1;k<cgfpn+1;k++){/*k - номер фп в группе*/
    /*получаем ИД K-ТОГО ФП*/int cfp_nid=sget_chi(ttid,cIl_nid,k);
	/*находим терм подстановки (ФАКТИЧЕСКИЙ ПАРАМЕТР - factnid). мы в j-ой группе (её trmf в cfnid) и параметр k-ый.*/
	int factnid=sget_nid(tid,cfnid,"3.")/*это пока #trml*/; factnid=sget_chi(tid,factnid,k);
   loopfp:/*ищем в копии терма определения ссылку на текущий фп(type=0)*/wi1=tid; wi2=cfp_nid;
    { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from dts where tid = $1  and ref = $2  and flg = 2 and type = 0", 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 972 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("deff_subst-select-count-2");
	if(wi==0) goto nextfp;
    { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select min ( nid ) from dts where tid = $1  and ref = $2  and flg = 2 and type = 0", 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 974 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("deff_subst-select-fpp");
    int fpp=wi/*узел Id фп*/;fpp=sget_up(tid,fpp)/*теперь это его терм*/;
	/*подставляем факт вместо фп*/subst_stree(tid,factnid,tid,fpp,0);
	goto loopfp;
    nextfp:;
   };
   /*сдвигаем текущий trmf*/cfnid=sget_up(tid,cfnid);
  };
  /*Удаляем терм subnid.*/del_subtree(tid,subnid);
  goto loopcnid;
 next: 
  /*снимаем флаг*/wi=tid; wi1=cnid;
  { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set flg = 0 where tid = $1  and nid = $2 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 986 "YL_db.pgc"
 if(sqlca.sqlcode!=0) YL_abort("deff_subst-upd-flg-0");
 goto loopcnid;
 /*кончились.*/
 end:
 commit(); printf("\n<deff_subst msg='RESULT'>"); int srt=sget_strt(tid); sprt_subtreeL(tid,srt); printf("\n</deff_subst>");
 printf("\n!deff_subst! end subst number=%i",RC);/*sprt_subtreeLD(tid,srt);*/
 return RC;
}
int infx_subst(int tid);/*из-за ссылки вперёд в st_trans ниже*/
int st_trans_fix(int tid){/*делает клон заданного предложения и приведение фик-вызовов клона.*/
 /*возвращает tid клона.*/
 /*клонируется заданное предложение.*/int cn=st_clone(tid);
 /*В ref корней размещаются ссылки.*/int rt=sget_strt(tid); sput_ref(tid,rt,cn); rt=sget_strt(cn); sput_ref(cn,rt,tid);
 /*в клоне транслируются фикс-вызовы.*/
 int RC1=infx_subst(cn);
 /*printf("\n<st_trans msg='RESULT!DEBUG!'>");sprt_subtreeLD(tid,rt); printf("\n</st_trans>");*/
 return cn;
}
int st_store(char* st_id/*in*/) /*ДРВ2ЛЕС. копирует поддерево (корень - st_id) в хранилище деревом (возвращает номер tr_id)*/{
 int tr_id/*out*/;
 /*1. Вызвать Получить узлы поддерева (вход:узел корня предложения, выход: ТН (_w)). */
 get_nodes(st_id);/*в _w узлы поддерева*/
 /*2. Поместить поддерево в хранилище: получить номер дерева.*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select ftrn from system where id = 'YL'", ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 1009 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("st_store-sel");
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update system set ftrn = ftrn + 1", ECPGt_EOIT, ECPGt_EORT);}
#line 1010 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("st_store-upd");
 tr_id=wi1/*номер дерева в хранилище*/;
 loop: /*кроме корня остальное и остальные перекачиваются без изменений.*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from _w", ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 1013 "YL_db.pgc"
 if (wi==0) goto end; /*Нет*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select min ( nid ) from _w", ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 1014 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("st_store-min");
 /*записи дрв ТН узлов закатать в хранилище. --Это должно быть правильное дерево само-по-себе!*/
 sprintf(wc,"%010i",wi); /*формируем ид- узла*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "insert into dts ( tid , nid , up , sid , rid , v , irn ) select $1  , $2  , cast ( up as integer ) , sid , rid , v , irn from dt where id = $3 ", 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1017 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("st_store-ins-dts");
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "delete from _w where nid = $1 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1018 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("st_store-delete");
 goto loop;
 end: /*Обработка нового корня: up, irn = Null.*/
 wi=atoi(st_id);
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set up = default , irn = default where tid = $1  and nid = $2 ", 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1022 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("st_store-update");
 commit();
 printf("\n<st_store Tree='%i' msg='added'>\n",tr_id); sprt_subtreeL(tr_id,wi);printf("\n</st_store>");
 return tr_id;  
}
int check_prfx_call(int tidd,int sig_arg,int ref,int type)/*Лес. проверяет согласованность декларации и точки вызова для префикса*/{
 /*(tidd,sig_arg) - узел sig_arg вызываемой ф-и, (ref,type) - узел типа фактического параметра*/
 /*возвращает RC: 0 - ОК, 1 - к-во фоп ф-и не 1, 2 - типы не подходят.*/
 int cfpt/*узел типа текущего фоп*/;
 /*получаем к-во фоп параметров*/int fpn=sget_chn(tidd,sig_arg);
 if(fpn!=1) return 1;
 /*сравниваем типы детей*/
 cfpt=sget_fpt(tidd,sig_arg,1)/*получаем узел типа фоп*/;
 /*сравниваем деревья типов*/int RC=scmp_trs(tidd,cfpt,ref,type,1); 
 if(RC==0) return 0;
 return 2;
}
int check_infx_call(int tidd,int sig_arg,int tidc1,int term1,int tidc2,int term2)
 /*Лес. проверяет согласованность декларации и точки вызова для инфикса*/{
 /*(tidd,sig_arg) - узел sig_arg вызываемой ф-и, (tidc1,term1) (tidc2,term2) - узлы  типа фактических параметров*/
 /*возвращает RC т.к. для много инфикса возможны варианты: 0 - ОК, 1 - к-во фп ф-и не 2, 2 - тип первого не подходят, 3 - тип второго не подходят.*/
 /*!!!разработчику: в этом коде остатки кодирования для вставления relax проверки типов*/
 int cfpt/*узел типа текущего фп*/;
 /*получаем к-во фп параметров*/int fpn=sget_chn(tidd,sig_arg);
 if(fpn!=2) return 1;
 /*сравниваем типы детей*/
 /*получаем nid детей и длинные ссылки на их типы*/
 cfpt=sget_fpt(tidd,sig_arg,1)/*получаем узел типа фп №1*/;
 /*сравниваем деревья типов первой пары*/int RC=scmp_trs(tidd,cfpt,tidc1,term1,1); 
 if(RC==0) goto cont1;
 return 2;
 cont1:cfpt=sget_fpt(tidd,sig_arg,2)/*получаем узел типа фп №2*/;
 /*сравниваем деревья типов второй пары*/RC=scmp_trs(tidd,cfpt,tidc2,term2,1); 
 if(RC==0) goto cont2;
 return 3;
 cont2:return 0;
}
int check_Ide_relax(int fotid,int fonid,int fatid,int fanid){/*проверяет допустимость несовпадения типов:
 возвращает RC: 0 - OK == первый длинный тип - предметный сорт И второй длинный тип - Ide
 */
 int dbg=0;
 if(dbg!=0) printf("\n!check_Ide_relax!DEBUG!begin fotid=%i, fonid=%i, fatid=%i, fanid=%i.",fotid, fonid, fatid, fanid); 
 /*проверяем что факт-пар - Ide*/
 char sid[22];sget_sid(fatid,fanid,"0.",sid);if(strcmp(sid,"Id")!=0) return 1;/*тип не сорт*/
 char v[YLsbl];sget_v(fatid,fanid,"0.",v);if(strcmp(v,"Ide")!=0) return 2;/*сорт не 'Ide'*/
 /*тип факт-пар - Ide*/ 
 sget_sid(fotid,fonid,"0.",sid);if(strcmp(sid,"Id")!=0) return 3;/*тип не сорт*/
 sget_v(fotid,fonid,"0.",v);/*сорт форм-пар*/
 if(check_entity_sort(v)!=0) return 4;/*тип не предметный сорт*/
 return 0;
}
int WFC_trmf(int tidd,int sig_f,int tidc,int TermList){/*Лес. проверяет все trmf проверки: 
 допустимость декларации и согласованность её и точки вызова*/
 /*возвращает RC: 0 - ОК, 1 - нарушено trmf-11, 2 - нарушено trmf-21, 3 - нарушено trmf-22*/
 /*!!!Согласованность типов структурная и по Id, кроме случая relax (см. док)!*/
 int dbg=0;
 if(dbg!=0) printf("\n!WFC_trmf!DEBUG!begin tidd=%i, sig_f=%i, tidc=%i, TermList=%i.",tidd, sig_f, tidc, TermList); 
 char cw[123]/*рабочая nid и путь*/;int sig_arg;char sid[22];
 int cfpt/*узел типа текущего фп*/; int ccvref/*дерево типа текущего факт пар*/; int ccvtype/*узел типа текущего факт пар*/; int RC;
 /*WFC(trmf-11)*/
 /*получаем sid типа term'а вызова*/ sget_sid(tidd,sig_f,"0.",sid);
 if(strcmp(sid,"sig_f")!=0) {printf("\n!WFC_trmf: ERROR - term-1 of type(%i,%i) must be functional but type.sid='%s', WFC(trmf-11)!",tidd,sig_f,sid);return(1);};
 /*WFC(trmf-21)*/
 /*получаем nid sig_arg*/ sig_arg=sget_nid(tidd,sig_f,"1."); 
 /*обрабатываем детей двух родителей: sig_arg и TermList*/
 /*получаем и сравниваем к-во параметров*/int fpn=sget_chn(tidd,sig_arg); int cpn=sget_chn(tidc,TermList);
 if(fpn!=cpn) {printf("\n!WFC_trmf:Number of fact and formal parameters must be the same but fpn=%i, cpn=%i, WFC(trmf-21)!",fpn,cpn); return(2);};
 /*WFC(trmf-22)*/
 /*сравниваем типы детей*/
 int i; for (i=1;i<fpn+1;i++){/*обработать i-ых*/
  /*получаем nid очередных детей и длинные ссылки на их типы*/
  /*У sig_arg ребё всегда sig="sig_e", а если его rid="sig_eF", то sig_f в 2., а если rid="sig_eI", то Id в 1.*/
  cfpt=sget_fpt(tidd,sig_arg,i)/*получаем узел типа форм-п*/;
  /*получаем длинную ссылку типа факт пар*/
  sprintf(cw,"%i.",i-1-cpn)/*путь к ребё*/;ccvref=sget_ref(tidc,TermList,cw);ccvtype=sget_type(tidc,TermList,cw);
  /*сравниваем деревья типов*/
  RC=scmp_trs(tidd,cfpt,ccvref,ccvtype,1);
  if(RC!=0) 
  {if(check_Ide_relax(ccvref,ccvtype,tidd,cfpt)!=0)
   {printf("\n!WFC_trmf:Types of fact and formal parameters do not match: (tidd=%i,cfpt=%i), (ccvref=%i,ccvtype=%i), RC=%i, WFC(trmf-22)!",tidd,cfpt,ccvref,ccvtype,RC);
   printf("\n!WFC_trmf:form-pars:");sprt_subtreeL(tidd,cfpt);
   printf("\n!WFC_trmf:fact-pars:");sprt_subtreeL(ccvref,ccvtype);
   return(3);};};
 };
 return(0);
}
int sget_pf(char* Id,int ref,int type)/*Лес. полиморфизм ид ф-и. по Id и заказанному длинному типу аргумента возвращает tid подходящей декларации*/{
 /*ф-я должна быть унарик и тип аргумента должен быть (ref,type). если не находим возвращаем 0, что не может быть tid!
   то что ф-я единственная обеспечивается проверками при добавлении в полиморфу*/
 int ftid=0/*tid декларации ф-и*/;char cw[123]/*рабочая*/;int sig_arg/*nid в декларации ф-и*/;
 strcpy(wc,Id);
 /*логика курсора: мы перебираем в entites декларации заданной функции и надо получить tid и обработать*/
 /*!!!пред-условие - Id - функция!!!*/
 /* declare cprf cursor for select tid from entities where id = $1  */
#line 1115 "YL_db.pgc"

 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "declare cprf cursor for select tid from entities where id = $1 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1116 "YL_db.pgc"
if (sqlca.sqlcode!=0) YL_abort("sget_pf-OPEN");
 /* exec sql whenever not found  goto  cend ; */
#line 1117 "YL_db.pgc"

 loop: 
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "fetch cprf", ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 1119 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 1119 "YL_db.pgc"

 /*обрабатываем очередного претендента: совпадает ли тип аргумента с нашим?*/
 ftid=wi;/*получаем nid sig_arg от st это "1.3.1."*/int strt=sget_strt(ftid);sig_arg=sget_nid(ftid,strt,"1.3.1.");
 /*унарик проверяется там*/
 int RC=check_prfx_call(ftid,sig_arg,ref,type); if(RC==0) goto end/*нашли подходящий*/;
 goto loop;
 cend:
 /*не нашли подходящего.*/ftid=0;
 end:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "close cprf", ECPGt_EOIT, ECPGt_EORT);}
#line 1128 "YL_db.pgc"

 /* exec sql whenever not found  continue ; */
#line 1129 "YL_db.pgc"

 return ftid;
}
int sget_if(char* fId,int ref1,int type1,int ref2,int type2)/*Лес. полиморфизм ид ф-и бинарика. по ид возвращает его ф-ю (tid её декларации) ЛИБО -9*/{
 /*ф-я должна быть бинарик и типы аргументов должны быть (ref1,type1) (ref2,type2). если не находим - возвращаем -9 (типа RC)!*/
 int ftid=0/*tid декларации ф-и*/;char cw[123]/*рабочая*/;int sig_arg;
 /*!ищем ф-и приписанные ид и выбираем подходящего типа аргументов*/
 strcpy(wc,fId);
 /* declare cinf cursor for select tid from entities where id = $1  */
#line 1137 "YL_db.pgc"

 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "declare cinf cursor for select tid from entities where id = $1 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1138 "YL_db.pgc"
if (sqlca.sqlcode!=0) YL_abort("sget_if-OPEN");
 /* exec sql whenever not found  goto  cend ; */
#line 1139 "YL_db.pgc"

 loop: 
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "fetch cinf", ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 1141 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 1141 "YL_db.pgc"

 /*обрабатываем очередного претендента: совпадает ли тип аргумента с нашим? получаем tid ф-и*/
 ftid=wi;/*получаем sig_arg от st - "1.3.1."*/int strt=sget_strt(ftid); sig_arg=sget_nid(ftid,strt,"1.3.1.");
 /*бинарик проверяется там*/
 int RC=check_infx_call(ftid,sig_arg,ref1,type1,ref2,type2); if(RC==0) goto end;
 goto loop;
 cend:/*не нашли.*/ftid=-9;
 end:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "close cinf", ECPGt_EOIT, ECPGt_EORT);}
#line 1149 "YL_db.pgc"

 /* exec sql whenever not found  continue ; */
#line 1150 "YL_db.pgc"

 return ftid;
}
int Sget_poly(char* fId,int tid,int TermList,int* ref,int* type){/*типизация функции "="*/
 /*по fId - ид ф-и-полиморфы и узлу <tid,TermList> с типизированными членами, возвращает длинную ссылку <ref,type> на sig_f подходящей декларации И RC=0 - OK.*/
 /*!!!ТОЛЬКО ДЛЯ =!!!*/
 if(strcmp(fId,YL_EQUIV_SIGN)!=0) {printf("\n!Sget_poly!ERROR!Polymorpha is allowed only for '%s'!(WFC_POLY)",YL_EQUIV_SIGN);return 2;};/*+!!!это очень поздно!!!*/
 /*проверяем что в TermList аргумента 2. +!!!это можно было сделать раньше!*/
 /*получаем к-во аргументов*/int arn=sget_chn(tid,TermList);
 if(arn!=2) {printf("\n!Sget_poly!ERROR!Polymorpha is allowed only for binary but '%s' has %i args!",fId,arn);return 1;}
 /*получаем типы аргументов и вызываем sget_if.  см. код для WFC_trmf:похоже нумерация детей у TermList отрицательная!!! 
  т.е. в пути надо указывать "-2." для первого и "-1." для второго!!!*/
 /*получаем ref,type фап-1*/int t1ref=sget_ref(tid,TermList,"-2."); int t1type=sget_type(tid,TermList,"-2.");
 /*получаем ref,type фап-2*/int t2ref=sget_ref(tid,TermList,"-1."); int t2type=sget_type(tid,TermList,"-1.");
 /*получаем tid декл ф-и .*/int tidd=sget_if(fId,t1ref,t1type,t2ref,t2type);
 if(tidd<0)/*не найден!*/{
  /*!!!наследование предм-сортами равенства Ide*/
  printf("\n!Sget_poly!DEBUG!POINT-1");
  /*проверяем что тип аргументов один и тот же.*/if(t1ref!=t2ref || t1type!=t2type) goto fend;
  printf("\n!Sget_poly!DEBUG!POINT-2");
  /*проверяем что узел типа имеет sid="Id" т.е. сорт.*/char cw[123]/*рабочая*/;sget_sid(t1ref,t1type,"0.",cw);if(strcmp(cw,"Id")!=0) goto fend;
  printf("\n!Sget_poly!DEBUG!POINT-3");
  /*проверяем что сорт предметный = rid предложения должен быть соответствующий.*/int rnid=sget_strt(t1ref);sget_rid(t1ref,rnid,"1.",cw);if(strcmp(cw,"Dcl-1")!=0) goto fend;
  printf("\n!Sget_poly!DEBUG!POINT-4");
  /*ищем в entities и возвращаем tid рав для Ide.*//*!!!Ide есть т.к. иначе не было бы предм-сортов НО у него может не быть рав!!!*/
  /*!!!нам нужна длинная ссылка на сорт Ide чтобы по ней sget_if нашёл его рав!!! = получаем из entities tid декл сорта Ide (это ref) и далее nid узла с ид сорта (это type)*/
  int etid=Sget_tid("Ide"); int ert=sget_strt(etid); int t3type=sget_nid(etid,ert,"1.2.");
  /*получаем tid декл рав для Ide.*/tidd=sget_if(YL_EQUIV_SIGN,etid,t3type,etid,t3type);
  /*!!!если рав для Ide нет - стандартная ошибка - не нашли!!!*/
  if(tidd>0) goto end; else {/*для сообщения об ошибке;-)*/t1ref=etid;t2ref=etid;t1type=t3type;t2type=t3type;};
  fend:/*возвращаем код ошибки!*/ 
  printf("\n!Sget_poly: ERROR! There is no binary function for Id '%s' with these arg_types!WFC(trmin-2)",fId);
  printf("\n!Sget_poly:arg-1 type:");sprt_subtreeL(t1ref,t1type);
  printf("\n!Sget_poly:arg-2 type:");sprt_subtreeL(t2ref,t2type);
 return 1;}; 
 /*возвращаем ссылку на sig_f*/
 end:*ref=tidd; int drt=sget_strt(tidd); *type=sget_nid(tidd,drt,"1.3.");
 /*printf("\n!Sget_poly!DEBUG!return ref=%i, type=%i!",*ref,*type);*/
 return 0;	
}
int type_tt_step(int tid,int rnid/*корень терма*/)/*Лес. шаг обработки до типизации term-узлов у которых справа в правиле есть term и все дети обработаны а они - нет*/{
 /*возвращает RC: количество обработанных, 0 может означать и обнаружена ошибка*/
 /*логика значений flg: 
   мы начинаем с уже размеченного начального состояния дерева: YL_NODE_OD - не надо обрабатывать и <YL_NODE_DO> - надо обработать, 
   и выставляем в <YL_NODE_DONE> - обработан. 
 #define YL_NODE_OD 0 значение flg - узел не надо обрабатывать
 #define YL_NODE_DO 1 значение flg - узел надо обработать
 #define YL_NODE_DONE 2 значение flg - узел обработан
  Схема алгоритма. в целом мы обрабатываем крону дерева необработанных:-)
 перебираем курсором и подсчитываем term-узлы с YL_NODE_DO. если НЕТ то RC=0.
 Если найден и все дети обработаны то обрабатываем и выставляем DONE.
 если нет обработчика rid то ошибка.
 если есть ошибка то сообщение, ref в -1* и RC=0. 
 */
 char cw[YLsbl]/*рабочая v...*/; char rid[22]; char prid[22]; char sid[22]; char* msgw/*на сообщение об ошибке*/; int RC;
 wi1=tid;  wi2=YL_NODE_DO; int tcount=0 /*счётчик попавших в курсор*/;
 /* declare type_tt_step_Curs cursor for select nid from dts where tid = $1  and sid = 'term' and flg = $2  */
#line 1206 "YL_db.pgc"

 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "declare type_tt_step_Curs cursor for select nid from dts where tid = $1  and sid = 'term' and flg = $2 ", 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1207 "YL_db.pgc"
if (sqlca.sqlcode!=0) YL_abort("type_tt_step_Curs-OPEN");
 /* exec sql whenever not found  goto  cend ; */
#line 1208 "YL_db.pgc"

 loop:/*получаем очередной с flg=YL_NODE_DO.*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "fetch type_tt_step_Curs", ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 1210 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 1210 "YL_db.pgc"

 /*обработка*/tcount=tcount+1;
 int tnid=wi/*ид узла term0*/; /*получаем его rid*/ sget_rid(tid,tnid,"0.",rid); 				/*printf("\n!type_tt!DEBUG!node begin. tid=%i, tnid=%i, rid='%s'!",tid,tnid,rid);*/
 if(strcmp(rid,"trmf")==0) /*term l_p TermList r_p*/{				/*printf("\n!type_tt!DEBUG! tree for trmf:");sprt_subtreeLD(tid,rnid);*/
  /*получаем flg term-1*/int flg=sget_flg(tid,tnid,"1."); if(flg!=YL_NODE_DONE)/*term-1 не готов*/  goto loop;
  /*Все дети TermList обработаны?*/
  /*получаем nid TermList*/ int TermList=sget_nid(tid,tnid,"3.");
  flg=flg_all_done_q(tid,TermList); if(flg!=1)/*TermList не готов*/ goto loop;
  /*можно обрабатывать*/
  /*получаем ref,type term-1*/int t1ref=sget_ref(tid,tnid,"1."); int t1type=sget_type(tid,tnid,"1.");
  if(WFC_trmf(t1ref,t1type,tid,TermList)!=0){sput_ref(tid,tnid,-10);  return 0;};
  /*назначаем term0 тип результата term-1*/
  int t0type=sget_fpt(t1ref,t1type,3)/*мы в sig_f поэтому нужен тип 3-его ребёнка*/;sput_ref(tid,tnid,t1ref); sput_type(tid,tnid,t0type);
  /*нормальное завершение обработки.*/ 
  sput_flg(tid,tnid,YL_NODE_DONE); 
  goto loop;
 };
 if(strcmp(rid,"trmi")==0) /*trmi:Id*/{/*!!!ВАЖНО:считаем что обрабатываем полиморфу равенства, т.е. это единственный случай когда trmi мог оказаться не обработанным на шаге типизации по детям!!!*/
  /*единственный допустимый случай: trmi на месте вызова ф-и, т.е. trmi/trmf, т.е. trmf: term\'trmi' l_p TermList r_p.*/
  /*получаем ап*/int pnid=sget_up(tid,tnid); /*получаем rid папы*/ sget_rid(tid,pnid,"0.",prid); char fId[YLsbl]/*ид ф-и*/;/*получаем ид ф-и*/sget_v(tid,tnid,"1.",fId);
  if(strcmp(prid,"trmf")!=0) {/*ошибка: полиморфа разрешена только как вызов ф-и*/printf("\n!type_tt: ERROR! term-1(%i,%i) polymorph func '%s' must be called!WFC(eq-1)",tid,tnid,fId); 
  sput_ref(tid,tnid,-11); return 0;};
  /*?Все дети TermList обработаны?*/
  int TermList=sget_nid(tid,pnid,"3."); int flg=flg_all_done_q(tid,TermList); if(flg!=1)/*trmf не готов*/ goto loop;
  /*можно обрабатывать:поиск в entities для полиморфы по типам детей подходящей декларации И типизация.*/
  int t1ref; int t1type;   /*t1ref, t1type - длинная ссылка на выявленный sig_f*/
  if(Sget_poly(fId,tid,TermList,&t1ref,&t1type)!=0){sput_ref(tid,tnid,-12); /*return 0;*/ goto trmi_end;};
  /*назначаем term0 длинный тип*/sput_ref(tid,tnid,t1ref); sput_type(tid,tnid,t1type);
  /*назначем тип \Id - так требует ТермТиО:*/int cnid=sget_nid(tid,tnid,"1.");/*назначаем Id длинный тип*/sput_ref(tid,cnid,t1ref); sput_type(tid,cnid,t1type);
  /*нормальное завершение обработки.*/ 
  trmi_end:sput_flg(tid,tnid,YL_NODE_DONE); 
  goto loop;
 };
 if(strcmp(rid,"trma")==0 || strcmp(rid,"trme")==0 || strcmp(rid,"trmc")==0 || strcmp(rid,"trms")==0) /*l_p <Q> Id COLON Id term r_p*/
 {/*получаем flg term-1*/int flg=sget_flg(tid,tnid,"6.");
  if(flg!=YL_NODE_DONE)/*term-1 не готов*/  goto loop;
  /*можно обрабатывать*/
  /*получаем ref,type term-1*/int t1ref=sget_ref(tid,tnid,"6."); int t1type=sget_type(tid,tnid,"6.");
  /*Это должен быть предметный сорт*/
  /*получаем sid типа*/sget_sid(t1ref,t1type,"0.",cw);
  if(strcmp(cw,"Id")!=0) {printf("\n!type_tt: ERROR! term-1(%i,%i) must be a sort type but term-1 sid='%s'!WFC(trmQ-4)",tid,tnid,cw); 
  sput_ref(tid,tnid,-13); return 0;};
  /*если sid=Id то это сорт - ничего другого в типе быть не может.*/
  /*получаем имя сорта*/sget_v(t1ref,t1type,"0.",cw);
  /*у количества сорт term-1 должен быть TV*/
  if(strcmp(rid,"trmc")==0 && strcmp(cw,"TV")!=0) {printf("\n!type_tt: ERROR! term-1(%i,%i) must have a sort TV but term-1 sort='%s'!WFC(trmc-1)",tid,tnid,cw); 
   sput_ref(tid,tnid,-14); return 0;};
  /*у суммы сорт term-1 должен быть Number*/
  if(strcmp(rid,"trms")==0 && strcmp(cw,"Number")!=0) {printf("\n!type_tt: ERROR! term-1(%i,%i) must have a sort Number but term-1 sort='%s'!WFC(trms-1)",tid,tnid,cw); 
   sput_ref(tid,tnid,-15); return 0;};
  /*назначаем тип term-0: у количества сорт term-0 должен быть Number у остальных тот же что у term-1*/
  if(strcmp(rid,"trmc")==0){/*получить длинную ссылку на сорт Number и закатать в t1ref,t1type*/
  /*проверяем что Number есть*/char Etype[21]/*тип сущего*/; int RCc=e_exists_q("Number",Etype);
  if(RCc!=0 || strcmp(Etype,"sort")!=0) {printf("\n!type_tt: ERROR! sort Number is absent or wrong!WFC(trms-2)"); 
   sput_ref(tid,tnid,-16); return 0;};
 /*получаем tid*/int stid=Sget_tid("Number"); 
  /*получаем nid Id сорта*/int rnid=sget_strt(stid);t1ref=stid; t1type=sget_nid(stid,rnid,"1.2.");
  };
  sput_ref(tid,tnid,t1ref); sput_type(tid,tnid,t1type);
  /*нормальное завершение обработки.*/ 
  sput_flg(tid,tnid,YL_NODE_DONE); 
  goto loop;
 };
 /*если нет обработчика то сообщаем об ошибке.*/ printf("\n!type_tt msg='!!!!!!!!!!!!!!!!!!!!!!!!!!SERROR!!!!!!!!!!!!!!!!!!!!!!!!!! for term (%i,%i) no code for rid='%s'!",tid,tnid,rid);
 sput_ref(tid,tnid,-14); return 0;
 cend:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "close type_tt_step_Curs", ECPGt_EOIT, ECPGt_EORT);}
#line 1276 "YL_db.pgc"

 /* exec sql whenever not found  continue ; */
#line 1277 "YL_db.pgc"

 commit();
 printf("\n!type_tt_step!return tcount=%i!",tcount);
 return tcount/*возвращаем количество обработанных*/;
}
void type_tt(int tid,int rnid/*корень терма*/)/*Лес. монитор обработчика типизации term-узлов у которых справа в правиле есть term*/{
 while(type_tt_step(tid,rnid)!=0);
}
int st_has_err(int tid)/*Лес. есть ли ошибки зафиксированные в ref в flg=YL_NODE_DONE узлах*/{
 /*возвращает мин значение ref. Null->0. наличие ошибок возврат <0*/
 /*!!!все ref могут быть Null, например если для "=" обработка отложена;-)*/
 wi=tid; wi2=YL_NODE_DONE;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select min ( coalesce ( ref , 0 ) ) from dts where tid = $1  and flg = $2 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 1289 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("st_has_err-select-min");
 return wi1;
}
int trm_viss(int tid, int nid, char* tp){/*у trmf-узла проверяет вид значения. возвращает:тип простого значения в tp и RC: 0 - тип значения терма простой, 1 - ф-я.*/
 /*получаем ref+type - ссылка на sig_e узел (тип результата). если у него sid=Id то рез-т простой, если - sig_f - сложный, иначе сист-ош!*/
 int ref=sget_ref(tid,nid,"0."); int type=sget_type(tid,nid,"0."); char sid[22]="";/*получаем sid*/sget_sid(ref,type,"0.",sid);
 if(strcmp(sid,"Id")==0) {sget_v(ref,type,"0.",tp); return 0;}; if(strcmp(sid,"sig_f")==0) return 1;
 /*сист-ош!*/printf("\n!trm_viss: sid='%s' is wrong! Abort! (tid=%i nid=%i ref=%i type=%i)",sid,tid,nid,ref,type);exit(EXIT_FAILURE);
}
int fm_chkt(int tid,int nid){/*дополнительные проверки терма на КСт (мода 4). код ошибки в ref*/
 /*КСт: trmf-терм(здесь) без кванторов, фиксов(не здесь) и свободных переменных, идентификаторы функций которого первичны.*/
 /*остальные проверки см. ОЯ*/
 /*переформулировка на ДРВ: корень должен иметь rid: trmf...*/
 char rid[22]="";
 /*получаем rid*/sget_rid(tid,nid,"0.",rid);
 if(strcmp(rid,"trmf")!=0) {printf("\n!fm_chkt:bad root term rid (%s) for FMt term. WFC(fmt-1)",rid); return -1;};
 return 0;
}
int fm_chkv(int tid,int nid){/*дополнительные проверки терма на КСз (мода 6). код ошибки в ref*/
 /*КСз: простое значение (эо, строка, число...) или идентификатор первичной ф-и*/
 /*здесь проверяется: корень может иметь rid: _trmRE, trmi. Остальные проверки в trmi_ideb.*/
 char rid[22]="";/*получаем rid*/sget_rid(tid,nid,"0.",rid);
 if(strcmp(rid,"_trmRE")!=0 && strcmp(rid,"trmi")!=0) {printf("\n!fm_chkv:bad term rid (%s) for FMv. WFC(fmta-2)",rid); return -1;};
 /*!приемлемость Id проверяется в trmi_ideb*/
 return 0;
}
int sget_argN(int tid, int nid){/*возвращает к-во аргументов trmi ребё - ф-и.*/
 /*получаем длинную ссылку на тип, т.е. sig_f*/
 int ref=sget_ref(tid,nid,"0."); int type=sget_type(tid,nid,"0.");
 /*получаем nid sig_arg*/int sa_nid=sget_nid(tid,nid,"1.");
 return sget_chn(tid,sa_nid);
}
int WFC_trmi(int tid,int nid, int mod){/*проверяет все WFC trmi в том числе модовые. Сообщает каждый случай нарушения. Возвращает 0 - ОК, нарушений нет; -N - нарушения есть (N их к-во).*/
 int cnid/*nid текущего ребё*/;char iv[YLsbl]/*рабочая*/;char t[22]/*тип обнаруженного эт*/; int RC=0; int exiRC;
 wi=tid;
 /* declare cur1 cursor for select ch . nid from dts ch , dts p where ch . tid = p . tid and ch . up = p . nid and ch . flg = 1 and ch . tid = $1  and ch . sid = 'Id' and p . rid = 'trmi' */
#line 1324 "YL_db.pgc"

 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "declare cur1 cursor for select ch . nid from dts ch , dts p where ch . tid = p . tid and ch . up = p . nid and ch . flg = 1 and ch . tid = $1  and ch . sid = 'Id' and p . rid = 'trmi'", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1325 "YL_db.pgc"
if (sqlca.sqlcode!=0) YL_abort("WFC_trmi-OPEN");
 /* exec sql whenever not found  goto  cend ; */
#line 1326 "YL_db.pgc"

 loop: /*получаем nid Id-узла*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "fetch cur1", ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 1328 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 1328 "YL_db.pgc"

 cnid=wi1; 
 /*обрабатываем очередной Id*/
 /*получаем v.Id*/sget_v(tid,cnid,"0.",iv);
 /*проверяем наличие значения Id среди элементов теории*/
 exiRC=e_exists_q(iv,t);
 if (exiRC!=1) {/*есть в эт!*/
  if (strcmp(t,"func")!=0) {printf("\n!WFC_trmi: ERROR! Id '%s' is from theory and must be function but '%s'! WFC(trmi-1)",iv,t); RC=RC-1;goto loop;};
   /*для КСт и КСз проверяем на первичность*/
  if(mod==4 || mod==6) {/*проверяем флаг первичности*/
  if (exiRC==0){
   if(Sget_prime(iv)!=1) {printf("\n!WFC_trmi: ERROR! function %s is not prime and can not be in FM-term! WFC(fmt-3)",iv);RC=RC-1;goto loop;};
  }else{printf("\n!WFC_trmi:!WARNING! function %s is polymorphic! WFC(fmt-3) postponed!!!",iv);};
  };
 goto loop;};
 /*не элемент теории*/
 /*если мы в модельном терме то - ошибка!!!*/
 if(mod==4 || mod==6) {printf("\n!WFC_trmi: ERROR! Id '%s'(%i,%i) is not a function in FM term! WFC(fmt-2)",iv,tid,cnid);RC=RC-1; goto loop;};
 goto loop;
 cend:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "close cur1", ECPGt_EOIT, ECPGt_EORT);}
#line 1348 "YL_db.pgc"

 /* exec sql whenever not found  continue ; */
#line 1349 "YL_db.pgc"

 return RC;
}
int FIX_get_arity(char* fix){/*возвращает х-ку фикса: 0 - не приписан, 1 приписан только унарикам, 2 приписан только бинарикам, 3 - и тем и другим*/
 int ftid=0/*tid декларации ф-и*/;char cw[123]/*рабочая*/;int sig_arg;int chn; int un=0; int bin=0;
 strcpy(wc,fix);
 /* declare FIX_get_arity cursor for select ref_f from infixes where v = $1  */
#line 1355 "YL_db.pgc"

 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "declare FIX_get_arity cursor for select ref_f from infixes where v = $1 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1356 "YL_db.pgc"
if (sqlca.sqlcode!=0) YL_abort("FIX_get_arity-OPEN");
 /* exec sql whenever not found  goto  cend ; */
#line 1357 "YL_db.pgc"

 loop: 
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "fetch FIX_get_arity", ECPGt_EOIT, 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 1359 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 1359 "YL_db.pgc"

 /*получаем tid ф-и*/ftid=Sget_tid(wc1);
 /*получаем nid sig_arg: от st это "1.3.1."*/int strt=sget_strt(ftid);sig_arg=sget_nid(ftid,strt,"1.3.1.");
 /*получаем к-во детей*//*предполагаем что арность может быть только 1 или 2*/
 chn=sget_chn(ftid,sig_arg); if(chn==1) un=1;else bin=2;
 goto loop;
 cend:/*перебрали всех. разбираемся с арностью*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "close FIX_get_arity", ECPGt_EOIT, ECPGt_EORT);}
#line 1366 "YL_db.pgc"

 /* exec sql whenever not found  continue ; */
#line 1367 "YL_db.pgc"

 return un+bin;
}
int WFC_trmie(int tid,int nid, int mod){/*проверяет WFC _trmRE-Ide. 
 Сообщает каждый случай нарушения. Возвращает 0 - ОК, нарушений нет; -N - нарушения есть (N их к-во).*/
 int cnid/*nid текущего ребё*/;char iv[YLsbl]/*рабочая*/; int RC=0; int mtid;
 wi=tid;
 /* declare cur2 cursor for select ch . nid from dts ch , dts p where ch . tid = p . tid and ch . up = p . nid and ch . flg = 1 and ch . tid = $1  and ch . sid = 'Ide' and p . rid = '_trmRE' */
#line 1375 "YL_db.pgc"

 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "declare cur2 cursor for select ch . nid from dts ch , dts p where ch . tid = p . tid and ch . up = p . nid and ch . flg = 1 and ch . tid = $1  and ch . sid = 'Ide' and p . rid = '_trmRE'", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1376 "YL_db.pgc"
if (sqlca.sqlcode!=0) YL_abort("WFC_trmie-OPEN");
 /* exec sql whenever not found  goto  cend ; */
#line 1377 "YL_db.pgc"

 loop: /*получаем nid Ide узла*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "fetch cur2", ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 1379 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 1379 "YL_db.pgc"

 cnid=wi1; 
 /*обрабатываем очередной Ide*/
 /*получаем v.Ide*/sget_v(tid,cnid,"0.",iv);
 mtid=get_pcm(iv);
 if(mtid==0)/*сорт для эо не нашёлся*/
 {printf("\n!WFC_trmie: WARNING! Ide '%s'(%i,%i) is not assigned to sort!WFW(_trmRE-2)",iv,tid,cnid); goto loop;};
 /*если мы в терме определения, замкнутой формуле, то узел - ошибка!*/
 if(mod==2 || mod==3) 
 {printf("\n!WFC_trmie:ERROR! Ide '%s'(%i,%i) is not allowed in term mode=%i! WFC(_trmRE-Ide)",iv,tid,cnid,mod); RC=RC-1;
 goto loop;};
 goto loop;
 cend:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "close cur2", ECPGt_EOIT, ECPGt_EORT);}
#line 1392 "YL_db.pgc"

 /* exec sql whenever not found  continue ; */
#line 1393 "YL_db.pgc"

 return RC;
}
int WFC__trmRE(int tid){/*Лес. проверка _trmRE-1 в рамках выделенного терма дерева tid*/
 /*проверяем что _trmRE-узлы есть: нет - возврат 0, есть - для каждого ищем в entities сорт=.\sid:
 нет - возврат -N (к-во _trmRE без сорта), есть - возврат 0*/
 int RC=0;int cnid/*текущий _trmRE*/;char sid[22];char t[22];
 wi=tid; 
 /*курсор по узлам с rid=_trmRE. получаем nid очередного*/
 /* declare WFC__trmRE cursor for select nid from dts where tid = $1  and rid = '_trmRE' and flg = 1 */
#line 1402 "YL_db.pgc"

 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "declare WFC__trmRE cursor for select nid from dts where tid = $1  and rid = '_trmRE' and flg = 1", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1403 "YL_db.pgc"
if (sqlca.sqlcode!=0) YL_abort("WFC__trmRE-OPEN");
 /* exec sql whenever not found  goto  cend ; */
#line 1404 "YL_db.pgc"

 loop:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "fetch WFC__trmRE", ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 1406 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 1406 "YL_db.pgc"

 cnid=wi1;
 /*получаем sid ребё*/
 sget_sid(tid,cnid,"1.",sid);
 if (e_exists_q(sid,t)==1){printf("\n!WFC__trmRE:can not work with %s as this sort is absent WFC(_trmRE-1)!",sid); RC=RC-1;goto loop;};
 if (strcmp(t,"sort")!=0){printf("\n!WFC__trmRE:can not work with %s as this is not a sort but %s WFC(_trmRE-1)!",sid,t); RC=RC-1;goto loop;};
 /*ОК*/
 goto loop;
 cend:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "close WFC__trmRE", ECPGt_EOIT, ECPGt_EORT);}
#line 1415 "YL_db.pgc"

 /* exec sql whenever not found  continue ; */
#line 1416 "YL_db.pgc"

 return RC;
}
char* term_proc(int tid, int nid, int mod)/*Лес. полная обработка в лесу корневого терма: WFC, идентификация, связывание, типизация значащих узлов*/{
 /*tid - ид дерева, nid - ид в дереве узла вершины корневого терма, 
   mod - мода обработки: 2 - терм определения ф-и, 3 - замкнутая формула, 4 - КСт, 5 - терм запроса, 6 - КСз.*/
 /*возврат - указатель на сообщение, нулевое - ОК. Ошибки ищются в обработанных узлах с ref<0*/
 /*!!!это собственно диспетчер обработчиков!!!*/
 /*!!!в flag_subtree один раз выставляется flg - флаг обработки: на все узлы терма - 1, остальные узлы дерева - 0. 
  обработчики не пересекаются по узлам, постепенно заменяя флаг узлов терма с 1 - "обработать" на 2 - "обработан"*/
 /*!!!хороший узел получает ref>0 (trmQ_3 заносит 0), ошибочный <0, если обработка задержана остаётся Null*/
 static char msg[256]=""; int mref=0/*мин значение ref ЛИБО код ошибки (<0) от WFC*/; int fvN/*к-во свопер в терме*/;
 int dbg=0; if (dbg!=0) printf("\n!term_proc!DEBUG!begin tid=%i nid=%i mod=%i.",tid,nid,mod);
 /*выделяем дерево терма*/ flag_subtree(tid,nid);
 /*!!!блок проверок обязательных и модовых требований к терму.*/
 /*"первая волна": ничего не меняют в дрв. накапливаем к-во ошибок (все возвращают их со знаком минус)*/
 mref=(WFC_trmi(tid,nid,mod)+WFC_trmie(tid,nid,mod)+WFC__trmRE(tid)+WFC_trmQ_1(tid)+WFC_trmQ_2(tid,mod));
 /*усиленные проверки МОД*/
 if (mod==4) /*КСт*/ mref=mref+fm_chkt(tid,nid);
 if (mod==6) /*КСз*/ mref=mref+fm_chkv(tid,nid);
 /*если были WFC нарушения "первой волны" то обработка не делается*/ if(mref!=0) goto fina;
 /*!!!обработка*/
 /*типизация Id/trmi и trmi*/ fvN=type_trmi(tid,nid,mod); if(fvN>0)  goto fina;/*printf("\n!term_proc!DEBUG!after type_trmi fixN=%i fvN=%i.",fixN,fvN);*/
 /*проверка использования переменных при кванторах*/ if(WFC_trmQ_3(tid)<0) goto fina;
 /*проверка использования фп*/ if (mod==2 && WFC_deff_7(tid)<0) goto fina;
 /*типизация _trmRE узлов*/type__trmRE(tid); 
 /*всеобщая типизация term: обработка и типизация sid=term, flg=1. пропускаем если ошибки уже есть!*/ 
 mref=st_has_err(tid); if(mref>=0) type_tt(tid,nid);
 /*ЗАВЕРШЕНИЕ ОБРАБОТКИ*/
 /*есть ли ошибки?*/
 /*получить  в mref мин значение ref среди flg=YL_NODE_DONE. Если ошибки были то ref<0 у некоторых узлов терма, т.е. где-то в предложении!*/
 mref=st_has_err(tid); /*printf("\nterm_proc: DEBUG mref=%i.",mref);*/
 /*если mref>=0 вернуть 0-сообщение*/
 if (mref>=0) {msg[0]=0;goto end;}; 
 /*если mref<0 сообщить*/
 fina:sprintf(msg,"!term_proc: term (%i,%i) has an error:%i!",tid,nid,mref);
 end:if (dbg!=0) printf("\n!term_proc!DEBUG!end mref=%i msg='%s'.",mref,msg);
 return &msg[0];
}
void type_fpl(int tid,int Ilr,int sigf_t,int sa,int n)/*Лес. типизирует фп одного конкретного ()-списка <tid,Ilr> по декларации <sigf_t,sa=sig_arg>*/{
 /*у нас есть два семейства детей одинаковой длины (n). i-ому ребёнку Id_list (Ilr) надо ref=sigf_t, type=<от i-ого реба sig_arg (sa) добраться до sig_f или Id!>*/
 char cw[123]/*рабочая путь, nid*/; char cp[111]/*путь к ребё*/; char rid[22]; int type/*nid узла декл с типом*/; int fpid/*nid очередного фп*/;
 /*printf("\n!type_fpl!DEBUG! in: tid=%i Ilr=%i sigf_t=%i sa=%i n=%i.\n",tid,Ilr,sigf_t,sa,n);*/
 int i; for (i=1;i<n+1;i++){/*обработать i-ых*/
  /*у sig_e: rid='sig_eF' -> 1.2. от sa| rid='sig_eI' -> 1.1. от sa.*/
  /*получаем nid узла типа*/
  /*формируем путь к текущему арг*/ 
  sprintf(cp,"%i.",i);
  /*получаем rid sig_e и формируем путь к узлу type*/
  sget_rid(sigf_t,sa,cp,rid); 
  if(strcmp(rid,"sig_eF")==0) strcpy(cw,"1.2.");
  else if(strcmp(rid,"sig_eI")==0) strcpy(cw,"1.1.");
  else {printf("\n!type_fpl:unexpected rid='%s'!ABORT",rid); exit(EXIT_FAILURE);};
  /*получаем type*/  type=sget_nid(sigf_t,sa,cw);
  /*получаем nid узла фоп*/ fpid=sget_nid(tid,Ilr,cp); 
  /*типизация*/sput_ref(tid,fpid,sigf_t);sput_type(tid,fpid,type);
 };
 return;
}
int type_fps(int tid)/*Лес. типизирует фоп заголовка определения ф-и связывая их с элементами сигнатуры декларации*/{ 
 /*tid - ид дерева определения (доп) new: дерева декларации*/ /*не проверяем что дерево содержит опр-функ!*/
 /*возвращает RC=0 - ОК, или 1 - ошибка или -N, где N - к-во неиспользуемых фоп*/
 char attrv[123]/*рабочая путь, nid*/; char cw[123]/*рабочая nid*/; char Idf[YLsbl]/*Id ф-и*/;  char rid[22]; 
 int flg /*состояние в конце шага цикла: 0 - есть продолжение у обоих...*/; int RC=0;
 int dbg=0; if (dbg!=0) printf("\n!type_fps!DEBUG! in: tid=%i.",tid);
 /*получаем nid-корень доп*/ int rt=sget_strt(tid);
 /*получаем nid-корень списка списков фп - Id_list_bch*/  int Ilbch=sget_nid(tid,rt,"1.5.");
 /*получаем к-во Id_list_b списков*/ int IlbN=sget_chn(tid,Ilbch);
 /*!!!добываем корень сигнатуры ф-и!!!*/ 
 int sigf_t=tid/*tid дерева декларации (дед) new:теперь это одно и тоже дерево.*/;
 /*получаем корень сигнатуры ф-и - sig_f*/ int sigf=sget_nid(sigf_t,rt,"1.3."); 
 /*предусловие: tid - ид дерева определения, sigf_t - ид дерева декларации;
 				Ilbch - узел Id_list_bch в доп, sigf - узел текущего (в первый раз - корневого) sig_f в дед;*/
 int Ilbi=1/*номер обрабатываемого Id_list_b из подвешенных к Id_list_bch*/;
 loop:
 /*printf("\n!type_fps!DEBUG! loop-in (IlbN=%i): Ilbi=%i (tid=%i Ilbch=%i) (sigf_t=%i sigf=%i)",IlbN,Ilbi,tid,Ilbch,sigf_t,sigf);*/
 /*ОПРЕДЕЛЕНИЕ*/
 /*формируем путь к текущему Id_list*/ sprintf(attrv,"%i.2.",Ilbi);
 /*получаем ид Id_list*/ int Ilr=sget_nid(tid,Ilbch,attrv); 
 /*получаем к-во фоп членов*/int Iln=sget_chn(tid,Ilr);
 /*ДЕКЛАРАЦИЯ*/
 /*получаем ид sig_arg*/ int sa=sget_nid(sigf_t,sigf,"1."); 
 /*получаем к-во арг членов*/ int san=sget_chn(sigf_t,sa);
 if(Iln!=san) {printf("\n!type_fps: ERROR! Number %i of args in decl <> number %i of fp in def !WFC(deff-5)",san,Iln);
  printf("\n!type_fps: decl\\sig_arg=");sprt_subtreeL(sigf_t,sa); 
  printf("\n!type_fps: def\\Id_list=");sprt_subtreeL(tid,Ilr); 
 RC=1; goto end;};
 /*типизировать Id_list*/ if(Iln!=0) type_fpl(tid,Ilr,sigf_t,sa,Iln);
 /*синхронный шаг с проверками*/
 /*фоп (Id_list) ещё есть?*/
 if(Ilbi==IlbN) flg=1/*НЕТ*/;else/*ДА*/ flg=0;
 /*арги есть?*//*получаем rid у "3." от sigf. если sig_eF - есть.*/
 sget_rid(sigf_t,sigf,"3.",rid);if(strcmp(rid,"sig_eF")!=0)/*НЕТ*/flg=flg+10;
 /*Имеем flg=1: фоп нет, а арги есть; ЛИБО =0: фоп есть и арги есть; 
   ЛИБО  flg=11: фоп нет и арги нет; ЛИБО =10: фоп есть, а арги нет;*/
 if(flg==11) /*оба состава кончились*/{RC=0; goto end;};
 if(flg==1) {printf("\n!type_fps:!WARNING! Number of arg-sets in decl (tid=%i, nid=%i) > number of fp-sets (IlbN=%i) in def (tid=%i, nid=%i). flg=%i!WFW(deff-5)",sigf_t,sa,IlbN,tid,Ilr,flg);
  RC=0; goto end;};
 if(flg==10) {printf("\n!type_fps:!ERROR! Number of arg-sets in decl (tid=%i, nid=%i) < number of fp-sets (IlbN=%i) in def (tid=%i, nid=%i). flg=%i!WFC(deff-5)",sigf_t,sa,IlbN,tid,Ilr,flg);
  printf("\n!type_fps: Bad news!"); RC=1; goto end;};
 /*получаем очередной sig_f*/
 sigf=sget_nid(sigf_t,sigf,"3.2."); 
 Ilbi=Ilbi+1;
 goto loop;
 end: if (dbg!=0)  printf("\n!type_fps!DEBUG! out, RC=%i.",RC);return RC;
}
/*ОБРАБОТЧИКИ ПРЕДЛОЖЕНИЙ*/
void Dcl_prm(char *st_id) /*st_id - ид узла предложения в ДРВ*/{
 char Id_v[YLsbl]/*значение нт Id*/;
 get_attr(2,st_id,"2.",Id_v); char t[22]/*t - вид сущего если Id уже им занят*/;int en/*номер сущего*/;
 
 if (e_exists_q(Id_v,t)!=1) {printf("\n!sort_add:!ERROR! Id '%s' is already used as '%s'!(WFC_POLY)",Id_v,t);return;};
 /*в лес*/
 int tr_id=st_store(st_id); 
 /*в сем-таб*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select fen from system where id = 'YL'", ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 1531 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sort_add-1");
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update system set fen = fen + 1", ECPGt_EOIT, ECPGt_EORT);}
#line 1532 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sort_add-2");
 en=wi;
 strcpy(wc1,Id_v); wi=en; wi2=tr_id;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "insert into entities ( id , type , ein , tid ) values ( $1  , 'sort' , $2  , $3  )", 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1535 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("sort_add-3");
 commit(); return; /*ОК*/
}
void f_add(char* st_id, char* rid)/*декларация ф-и. 3 предложения и в rid их rid*/{
 /*st_id - ид дрв обрабатываемого предложения.*/
 char id[YLsbl]/*значение нт Id-1*/;
 char t[22]; /*тип проверяемого сущего*/
 char sig_f[123] /*ид- узла sig_f*/;
 int dbg=0; 
 get_attr(2,st_id,"2.",id);
 if(e_exists_q(id,t)!=1) printf("\n!f_add!WARNING!polomorpha is not ready yet but '%s' is already used with type '%s'!(WFC_POLY)",id,t);
 /*begin доп ПРОВЕРКИ РАЗНОГО РОДА*/
 /*WFC(sig_eI-1): все ид в дереве вывода любого type - сорта.*/
 /*+У:это п.п уйдёт либо оно в требованиях к type!?!*/
 get_attr(3,st_id,"3.",sig_f);
 if (check_sig_eI(sig_f)!=0) {printf("\n!f_add:!ERROR! Not all Id are sorts! WFC(sig_eI-1)");return;};
 if (strcmp(rid,"Dcl-5")==0) {char lid[123]/*ид узла списка форм- парам-*/;
 get_attr(3,st_id,"5.",lid); int RC=def_chk_fp(lid);if (RC!=0) {printf("\n!f_add>def_chk_fp.RC=%i.",RC);return;};};
 /*end доп ПРОВЕРКИ РАЗНОГО РОДА*/
 /*в лес и продолжение проверок*/
 int tr_id=st_store(st_id)/*это исходник предложения*/;/*DEBUG sprt_treeLD(tr_id);*/
 int ctid=st_trans_fix(tr_id)/*получаем клон и транслируем +У:ну клон ладно а транс его - только для опр!*/;int cnid=sget_strt(ctid);
 if (strcmp(rid,"Dcl-5")==0){/*обработка определения в лесу*/
  /*типизация фп и проверка*/
  int termi=sget_nid(ctid,cnid,"1.7.")/*ид узла терма определения. = 7-ой ребё*/;
  int RC=type_fps(ctid); if (RC!=0) {st_del(tr_id);st_del(ctid);printf("\n!f_add>type_fps.RC=%i.",RC);return;};
  /*обработка терма. идентиф и привязка*/
  char* msgw=term_proc(ctid,termi,2); if (*msgw!=0) {st_del(tr_id);st_del(ctid); printf("\n!f_add>term_proc.msg(%s).",msgw); return;};
  /*трансляция*/if (dbg!=0) printf("\n!f_add(DEBUG)deff_subst.in");
  while(deff_subst(ctid)!=0);
 };
 /*в сем-таб*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select fen from system where id = 'YL'", ECPGt_EOIT, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 1567 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("f_add-1");
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update system set fen = fen + 1", ECPGt_EOIT, ECPGt_EORT);}
#line 1568 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("f_add-2");
 /*в wi порядковый номер создаваемого сущего*/
 int ein=wi;
 strcpy(wc2,id); wi2=tr_id; wi=ein;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "insert into entities ( id , type , ein , tid ) values ( $1  , 'func' , $2  , $3  )", 
	ECPGt_char,(wc2),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1572 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("f_add-3");
 commit(); 
 return; /*ОК*/
}
void prt_store(int mod){/*mod=1 выдаёт всё содержимое леса в Y!L виде и с tid. mod=0 выдаёт !0! и "исходники" содержимого леса в Y!L виде, т.е. трансляции не выдаются*/
 int dbg=0;
 if (dbg==1) printf("\n prt_store(%i).",mod);
 /* declare prtsc cursor for select tid , nid , coalesce ( ref , 0 ) from dts where up is null order by tid */
#line 1579 "YL_db.pgc"

 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "declare prtsc cursor for select tid , nid , coalesce ( ref , 0 ) from dts where up is null order by tid", ECPGt_EOIT, ECPGt_EORT);}
#line 1580 "YL_db.pgc"
if (sqlca.sqlcode!=0) YL_abort("prt_store-OPEN");
 /* exec sql whenever not found  goto  cend ; */
#line 1581 "YL_db.pgc"

 if(mod==0) printf("\n!0!");
 loop: 
  { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "fetch prtsc", ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi2),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi3),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 1584 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 1584 "YL_db.pgc"

  int ctid=wi1; int cnid=wi2; int ref=wi3; 
  if (dbg==1) printf("\n prt_store.SQL FETCH ctid=%i cnid=%i ref=%i.",ctid,cnid,ref);
  /*выдаём очередное дерево*/ 
  if(mod==1) {printf("\n%04i ",ctid); sprt_subtreeL(ctid,cnid);}; 
  if(mod==0 && (ref==0 || ref>ctid)) {printf("\n"); sprt_subtreeL(ctid,cnid)/*признак исходника - ref есть и вперёд на трансляцию*/;};
 goto loop;
 cend:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "close prtsc", ECPGt_EOIT, ECPGt_EORT);}
#line 1592 "YL_db.pgc"

 /* exec sql whenever not found  continue ; */
#line 1593 "YL_db.pgc"

 if (dbg==1) printf("\n prt_store RETURN.");
}
void prt_fmtv(){/*выдаёт fm_tv в виде команд загрузки*/
 printf("\n--fm_tv dump begins-----------------------------------------");
 /* declare prtfmtv cursor for select t , v from fm_tv order by t */
#line 1598 "YL_db.pgc"

 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "declare prtfmtv cursor for select t , v from fm_tv order by t", ECPGt_EOIT, ECPGt_EORT);}
#line 1599 "YL_db.pgc"
if (sqlca.sqlcode!=0) YL_abort("prt_fmtv-OPEN");
 /* exec sql whenever not found  goto  cend ; */
#line 1600 "YL_db.pgc"

 loop: 
  { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "fetch prtfmtv", ECPGt_EOIT, 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);
#line 1602 "YL_db.pgc"

if (sqlca.sqlcode == ECPG_NOT_FOUND) goto cend;}
#line 1602 "YL_db.pgc"

  /*выдаём очередную парочку*/printf("\n!%s:%s!",wc,wc1);
 goto loop;
 cend:
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "close prtfmtv", ECPGt_EOIT, ECPGt_EORT);}
#line 1606 "YL_db.pgc"

 /* exec sql whenever not found  continue ; */
#line 1607 "YL_db.pgc"


}
int doc(char *cc/*номер команды*/)/*обработка команд YL: 0 - инициализация СИСТЕМЫ, 1 - выдача всего леса с номерами деревьев, 2 - выдача !0!, исходников леса и значений термов*/{
 if (*cc=='0') /*очистка БД*/
 {{ ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "delete from entities", ECPGt_EOIT, ECPGt_EORT);}
#line 1612 "YL_db.pgc"
 if (sqlca.sqlcode!=0 && sqlca.sqlcode!=100) YL_abort("doc-del-entities");
  { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "delete from _w", ECPGt_EOIT, ECPGt_EORT);}
#line 1613 "YL_db.pgc"
 if (sqlca.sqlcode!=0 && sqlca.sqlcode!=100) YL_abort("doc-del-_w"); /*было: EXEC SQL delete from infixes; */
  { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "delete from dts", ECPGt_EOIT, ECPGt_EORT);}
#line 1614 "YL_db.pgc"
 if (sqlca.sqlcode!=0 && sqlca.sqlcode!=100) YL_abort("doc-del-dts");
  { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "delete from fm_tv", ECPGt_EOIT, ECPGt_EORT);}
#line 1615 "YL_db.pgc"
 if (sqlca.sqlcode!=0 && sqlca.sqlcode!=100) YL_abort("doc-del-fm_tv");
  /*EXEC SQL vacuum; после него команды не работают:-(*/
  { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update system set fen = 1 , ftrn = 1", ECPGt_EOIT, ECPGt_EORT);}
#line 1617 "YL_db.pgc"

  commit();
  /*printf("\nDEBUG.doc.before return 0\n");*/
  return 0;} 
 else if(*cc=='1') {prt_store(1); return 0;}
 else if(*cc=='2') {prt_store(0); prt_fmtv(); return 0;}
 ;
 return 1;
}
void fmca_proc(char *st_id)/*e_m Ide Id e_m*/{
 /*st_id - ид узла предложения*//*Добавление эл-та Ide в основу Id.*/
 char Id_v[YLsbl]/*значение нт Ide*/; char Id2_v[YLsbl]/*значение нт Id*/; char st[YLsbl]; /*рабочая для типов и значение РВ сорта*/
 get_attr(2,st_id,"2.",Id_v); get_attr(2,st_id,"3.",Id2_v); /*printf("\n!fmca_proc!DEBUG! Id_v=%s, Id2_v=%s, df_nidc=%s\n",Id_v,Id2_v,df_nidc);*/
 /*- WFC(fmca-2): Id должен быть в эт и быть сорт.*/
 if (e_exists_q(Id2_v,st)==1)/*не порядок - сущего для сорта нет!*/ {printf("\n!fmca_proc!ERROR! Sort %s is missing! WFC(fmca-2)",Id2_v); return;};
 if (strcmp(st,"sort")!=0)/*не порядок - сущее для сорта есть, но не сорт!*/ {printf("\n!fmca_proc!ERROR! %s is not a sort! WFC(fmca-2)",Id2_v); return;};
 /*проверить что сорт не РВ:получить из сем-таб tid декларации и проверить что это не Dcl-2*/
 int dtid=Sget_tid(Id2_v); int drt=sget_strt(dtid); sget_rid(dtid,drt,"1.",st);
 if (strcmp(st,"Dcl-1")!=0)/*не порядок - не предметный сорт!*/ {printf("\n!fmca_proc!ERROR! %s is not application sort  - forbidden! WFC(fmca-2)",Id2_v); return;}; 
 /*WFC(fmca-1): Если Ide есть в какой-либо основе (в том числе в Id) - ОШИБКА.*/
 int w=get_pcm(Id_v); if (w!=0) {printf("\n!fmca_proc!ERROR! %s is already used as carrier member! WFC(fmca-1)",Id_v); return;};
 /*в лес*/
 int tr_id=st_store(st_id);
 commit(); return; /*ОК*/
}
void fmcd_proc(char *st_id)/*e_m Ide e_m*/{
 /*st_id - ид узла предложения*//*Удаление эл-та Ide из основы.*/
 char Id_v[YLsbl]/*значение нт Ide*/;
 get_attr(2,st_id,"2.",Id_v);
 /*printf("\n!fmcd_proc!DEBUG! Id_v=%s, Id2_v=%s, df_nidc=%s\n",Id_v,Id2_v,df_nidc);*/
 int w=get_pcm(Id_v);
 if (w==0) {printf("\n!fmcd_proc!ERROR! %s is not used as carrier member! WFC(fmcd-1)",Id_v); return;};
 strcpy(wc,Id_v);
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from fm_tv where position ( $1  in t ) > 0", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 1650 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("fmcd_proc-select-t");
 if (wi1!=0) {printf("\n!fmcd_proc!ERROR! %s is used as an ARGUMENT in %i FM-lines! WFC(fmcd-2)",Id_v,wi1); return;};
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from fm_tv where position ( $1  in t ) = 1 and length ( $2  ) = length ( v )", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 1652 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("fmcd_proc-select-v");
 if (wi1!=0) {printf("\n!fmcd_proc!ERROR! %s is used as term REZULT %i times! WFC(fmcd-2)",Id_v,wi1); return;};
 /*из леса*/
 st_del(w);
 commit(); return; /*ОК*/
}
void Dcl_prmfC(char *st_id)/*DECLARATION Id type Id DOT*/{
 /*st_id - ид узла предложения*//*???*/
 printf("\n!Dcl_prmfC!SORRY! NOT IMPLEMENTED YET!");
 return; 
}
void fmcaq_proc(char *st_id)/*e_m Id Natural term e_m*/{
 /*st_id - ид узла предложения*//*???*/
 printf("\n!fmcaq_proc!SORRY! NOT IMPLEMENTED YET!");
 return; 
}
void fmcdq_proc(char *st_id)/*e_m Id Natural e_m*/{
 /*st_id - ид узла предложения*//*???*/
 printf("\n!fmcdq_proc!SORRY! NOT IMPLEMENTED YET!");
 return; 
}
int fm_tGetv(char* t,char* v){/*ищет в КС значение для сериализации терма t и помещает в v. возвращает RC: 0 - ОК, 1 - нет значения, "значение" - 0-строка.*/
 strcpy(wc,t);
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select v from fm_tv where t = $1 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 1675 "YL_db.pgc"

 if(sqlca.sqlcode==0){strcpy(v,wc1); return 0;};
 if(sqlca.sqlcode==100) {printf("\n!fm_tGetv!WARNING! FM-term '%s' is absent!",t);strcpy(v,""); return 1;};
 YL_abort("fm_tGetv-sel-v"); 
}
void fm_td(){/*КС. удаление значения терма. сериализация в wc!*/
 /*ищем по серализации*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select v from fm_tv where t = $1 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 1682 "YL_db.pgc"

 if(sqlca.sqlcode==0){{ ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "delete from fm_tv where t = $1 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1683 "YL_db.pgc"
  if (sqlca.sqlcode!=0) YL_abort("fm_td-upd");}
 else if(sqlca.sqlcode==100) {printf("\n!fm_td!WARNING! FM-term '%s' is absent!",wc);}
 else YL_abort("fm_td-sel-v"); 
 commit();
 return;
}
void fmtd_proc(char *st_id)/*обработка предложения fmtd: e_m term COLON e_m*/{
 /*st_id - ид узла предложения в ДРВ*/
 /*терм-1 проверяется как модельный (КСт) (mod=4). см. ОЯ.*/
 int RC=0 /*накопитель к-ва ошибок*/;
 /*!!!мы сразу переходим в лес!!!*/
 int tr_id=st_store(st_id); /*транслируем фикс-позиции*/int RC1=infx_subst(tr_id);
 int snid=atoi(st_id)/*nid корня дерева*/;
 int t1_id/*id вершины терма-1*/; /*получаем корень терма-1*/ t1_id=sget_nid(tr_id,snid,"2.");
 /*!обработка модельного терма-1*/  char* msgw=term_proc(tr_id,t1_id,4); if (*msgw!=0) {printf("\n!fmtd_proc:term_proc-1:(%s).",msgw); RC=1;};
 if(RC!=0) {printf("/n!fmtd_proc:bad term-1!"); st_del(tr_id); return;};
 /*сериализуем терм-1*/wc[0]=0; fm_t2s(tr_id,t1_id,wc); 
 if(strlen(wc)>YL_STRING_BUF_LEN-1) {printf("\n!fmtd_proc:serialization length > %i",YL_STRING_BUF_LEN-1); st_del(tr_id); return;};
 printf("\n!fmtd_proc!DEBUG! term-1 serialized: '%s'",wc);
 /*!сериализация КСт находится в wc*/
 /*удаляем из КС*/fm_td();
 /*удаляем дерево из леса*/st_del(tr_id);
 printf("\n!fmtd_proc!DEBUG! end!");
 return;
}
void fm_tvupd(char* val){/*КС. добавление/обновление значения терма. сериализация в wc!*/
 /*ищем по серализации*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select v from fm_tv where t = $1 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 1710 "YL_db.pgc"

 strcpy(wc1,val);
 if(sqlca.sqlcode==0){{ ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update fm_tv set v = $1  where t = $2 ", 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1712 "YL_db.pgc"
  if (sqlca.sqlcode!=0) YL_abort("fm_tvupd-upd");}
 else if(sqlca.sqlcode==100) {/*вставляем*/{ ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "insert into fm_tv ( t , v ) values ( $1  , $2  )", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_char,(wc1),(long)YLsbl,(long)1,(YLsbl)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1713 "YL_db.pgc"
 if (sqlca.sqlcode!=0) YL_abort("fm_tvupd-ins");}
 else YL_abort("fm_tvupd-sel-v"); 
 commit();
 return;
}
void fmta_proc(char *st_id)/*e_m term COLON term e_m*/{
 /*st_id - ид узла предложения в ДРВ*/
 /*терм-1 проверяется как модельный (КСт) (mod=4), терм-2 как КСз. см. ОЯ.*/
 int dbg=0;
 char V[YLsbl]=""/*буфер значений*/; char wv[YLsbl]=""/*значение терма*/; /*static char ws[YL_STRING_BUF_LEN]=""*//*буфер сериализации в БД 1023*/; 
 int RC=0 /*накопитель к-ва ошибок*/;
 if(dbg!=0) printf("\n<fmta_proc msg='!DEBUG!begin!'>");
 /*!!!мы сразу переходим в лес!!!*/
 int tr_id=st_store(st_id); /*транслируем фикс-позиции*/int RC1=infx_subst(tr_id);
 if(dbg!=0) printf("\n!fmta_proc!DEBUG!after infx_subst RC1=%i!",RC1);
 int snid=atoi(st_id)/*nid корня дерева*/;
 int t1_id/*id вершины терма-1*/; /*получаем корень терма-1*/ t1_id=sget_nid(tr_id,snid,"2.");
 /*!обработка терма-1*/  char* msgw=term_proc(tr_id,t1_id,4); if (*msgw!=0) {printf("\n!fmta_proc!ERROR! msg got='%s'!",msgw); RC=1;};
 int t2_id/*id вершины терма-2*/; /*получаем корень терма-2*/ t2_id=sget_nid(tr_id,snid,"4.");
 /*!обработка терма-2*/ msgw=term_proc(tr_id,t2_id,6); if (*msgw!=0) {printf("\n!fmta_proc!ERROR! msg got='%s'!",msgw); RC=RC+1;};
 if(RC!=0) {printf("\n!fmta_proc:number of bad terms is %i!",RC);goto end;};
 /*!проверка совпадения типов рез-та КСт и КСз*/
 int t1_ref=sget_ref(tr_id,t1_id,"0."); int t1_type=sget_type(tr_id,t1_id,"0."); int t2_ref=sget_ref(tr_id,t2_id,"0."); int t2_type=sget_type(tr_id,t2_id,"0.");
 /*сравниваем деревья типов*/RC=scmp_trs(t1_ref,t1_type,t2_ref,t2_type,1);  
 if(RC==0) goto cont;/*полное синтаксическое совпадение*/
 /*проверяем ослабление для Ide: КСт=Ide, КСз=s*/
 if(check_Ide_relax(t2_ref,t2_type,t1_ref,t1_type)!=0)
 {printf("\n!fmta_proc:Types of FMt and FMv do not match!WFC(fmta-1)");
   printf("\n!fmta_proc:FMt type:");sprt_subtreeL(t1_ref,t1_type);
   printf("\n!fmta_proc:FMv type:");sprt_subtreeL(t2_ref,t2_type);
 goto end;};
 cont:/*сериализуем терм-1*/wc[0]=0; fm_t2s(tr_id,t1_id,wc); 
 if(strlen(wc)>YL_STRING_BUF_LEN-1) {printf("\n!fmta_proc:serialization length > %i",YL_STRING_BUF_LEN-1); goto end;};
 if(dbg!=0) printf("\n<fmta_proc msg='!DEBUG! term-1 serialized:%s'/>",wc);
 /*получаем значение КСз*/sget_v(tr_id,t2_id,"1.",wv);
 /*получаем сорт КСз*/sget_v(t2_ref,t2_type,"0.",V); 
 /*если тип значения - String, добавляем кавычки*/if(strcmp(V,"String")==0) {strcpy(V,"\"");strcat(V,wv);strcat(V,"\"");strcpy(wv,V);};
 /*!сериализация: КСт находится в wc, значение КСз - в wv*/
 /*обновляем КС*/fm_tvupd(wv);
 end:/*!!!дерево из леса удаляется всегда!!!*/
 /*удаляем дерево из леса*/if(dbg==0) st_del(tr_id);
 if(dbg!=0) printf("\n</fmta_proc>");
 return;
}
int fm_cgetFirst(char* sort){/*выдаёт tid !!-предложения первого элемента сорта, 0 - пусто*/
 /*для перебора, предложения состава сорта считаем упорядоченными по tid!*/
 strcpy(wc,sort);
 /*п.п. min не найдя будет выдавать какое-то дурацкое число типа суперминимум! = INT_MIN т.к. у нас отключена индикация Null*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select min ( r . tid ) from dts r , dts ch where r . up is null and r . rid = 'fmca' and ch . tid = r . tid and ch . up = r . nid and ch . irn = 3 and ch . v = $1 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 1761 "YL_db.pgc"
 if(sqlca.sqlcode!=0) YL_abort("fm_cgetFirst-sel-min"); 
 if(wi1<0) return 0; return wi1;
}
int fm_cgetNext(char* sort,int cur){/*выдаёт tid следующего элемента сорта, 0 - нет*/
 strcpy(wc,sort); wi=cur;
 /*п.п. min не найдя будет выдавать какое-то дурацкое число типа суперминимум! = INT_MIN т.к. у нас отключена индикация Null*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select min ( r . tid ) from dts r , dts ch where r . up is null and r . rid = 'fmca' and ch . tid = r . tid and ch . up = r . nid and ch . irn = 3 and ch . v = $1  and r . tid > $2 ", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 1767 "YL_db.pgc"
 if(sqlca.sqlcode!=0) YL_abort("fm_cgetNext-sel-min"); 
 if(wi1<0) return 0; return wi1;
}
void fm_cGetv(int tid,char* v){/*выдаёт значение заданного элемента п.п. сорта*/
 sget_v(tid,sget_strt(tid),"2.",v);
}
int infx_subst(int tid)/*трансляция всех FIX-форм в заданном предложении. перебор через flg*/{
 /*возвращает: 0 - подстановки не было, 1 - подстановка была.*/
 /*см. документацию.*/
 int RC=0; int cnid/*текущий инфикс - ид узла*/; int Iirn/*irn текущего FIX: 2 - префикс, 3 - инфикс*/;
 char val[YLsbl]/*рабочая*/; char fId[YLsbl]/*имя ф-и*/; /*printf("\n!infx_subst!DEBUG! begin tid=%i",tid);*/
 /*снимаем flg в предложении и выставляем у Id-FIX, если их нет уходим на end*/
 /*!!!алгоритм ниже обрабатывает узлы под флагом и нам надо отметить лишь Id в фикс-форме: up.rid=trmp OR trmin!!! */
 wi=tid;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set flg = 0 where tid = $1 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1781 "YL_db.pgc"
  if (sqlca.sqlcode!=0) YL_abort("infx_subst-upd-flg-0");
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts c set flg = 1 from dts p where c . tid = $1  and c . sid = 'Id' and p . tid = $2  and p . nid = c . up and ( p . rid = 'trmp' or p . rid = 'trmin' )", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1782 "YL_db.pgc"
 if(sqlca.sqlcode==100) goto end; if(sqlca.sqlcode!=0) YL_abort("infx_subst-upd-flg-1");
 RC=1;
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select count ( * ) from dts where tid = $1  and flg = 1", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 1784 "YL_db.pgc"
 if(sqlca.sqlcode!=0) YL_abort("infx_subst-sel_count");
 int N=wi1;/*к-во FIX*/
 int i; for(i=1;i<N+1;i++){
  wi=tid;
  /*выбираем первый попавшийся Id-FIX*/
  { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "select min ( nid ) from dts where tid = $1  and flg = 1", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EORT);}
#line 1789 "YL_db.pgc"
 if(sqlca.sqlcode!=0) YL_abort("infx_subst-sel-min"); 
  cnid=wi1; Iirn=sget_irn(tid,cnid);  /*printf("\n!infx_subst!DEBUG! loop cnid=%i Iirn=%i.",cnid,Iirn);*/
  /*обрабатываем очередной Id-FIX.*/
  /*получаем nid родителя*/int pid=sget_up(tid,cnid);
  /*заменяем родителю rid. больше ничего у него менять не нужно!*/sput_rid(tid,pid,"trmf");
  /*назначить Id-FIX irn=0 для соблюдения строения дерева и откладывая удаление чтобы не связываться с курсором!*/sput_irn(tid,cnid,0);
  /*ДЕЛАЕМ НОВЫЕ НО up у term-0 и TermList НЕ НАЗНАЧАЕМ. чтобы не мешать перестройке старого дерева*/
  /*term-0(новый): rid=trmi, sid=term, irn=1, v=Null. структурные: tid=#tid, nid=NEW-1, up=#pid.*/
  int t0=scrt_node(tid,"term","trmi",""); sput_irn(tid,t0,1);
  /*Id(FIX)(новый): rid=Null, sid=Id, irn=1, v=Id.v; структурные: tid=#tid, nid=NEW-2, up=NEW-1.*/
  sget_v(tid,cnid,"0.",fId);int Idnid=scrt_node(tid,"Id","",fId); sput_irn(tid,Idnid,1); sput_up(tid,Idnid,t0);
  /*TermList(новый): rid='#trml', sid=TermList, irn=3, v=""; ref=Null, type=Null. структурные: tid=#tid, nid=NEW-3, up=#pid.*/
  int tl=scrt_node(tid,"TermList","#trml",""); sput_irn(tid,tl,3);
  /*перестраиваем остальные*/
  /*term-1: получить ид (пре pid"3."/инф pid"2."). замены up=NEW-3, irn=(пре -1/инф -2).*/ int t1irn;
  /*готовим путь и атрибутику*/if(Iirn==2) {strcpy(val,"3.");t1irn=-1;} else {strcpy(val,"2.");t1irn=-2;};
  int t1=sget_nid(tid,pid,val)/*ид*/; sput_up(tid,t1,tl); sput_irn(tid,t1,t1irn);
  /*term-2: получить ид (pid"4."). замены up=NEW-3, irn= -1.*/
  if(Iirn==3) {int t2=sget_nid(tid,pid,"4.")/*ид*/; sput_up(tid,t2,tl); sput_irn(tid,t2,-1);};
  /*l_p: из первой становиться второй: получить ид (pid"1.") и заменить irn=2.*/int lp=sget_nid(tid,pid,"1.")/*ид*/; sput_irn(tid,lp,2);
  /*r_p:в случае префикса ничего делать не надо. в случае инфикса получить ид и заменить irn=4.*/
  if(Iirn==3) {int rp=sget_nid(tid,pid,"5.")/*ид*/; sput_irn(tid,rp,4);};
  /*назначаем up t0, tl*/sput_up(tid,t0,pid); sput_up(tid,tl,pid);
  /*снимаем флаг*/wi=tid; wi1=cnid;
  { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set flg = 0 where tid = $1  and nid = $2 ", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1813 "YL_db.pgc"
 if(sqlca.sqlcode!=0) YL_abort("infx_subst-upd-flg-0");
 };
 /*кончились. удаляем узлы Id-FIX*/  wi=tid; /*+У:удалятор OLDD не идёт - п.п у узов уже нет таких родителей!!! Вар-1. irn=0 (см. выше)*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "delete from dts where tid = $1  and sid = 'Id' and irn = 0", 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1816 "YL_db.pgc"
 if(sqlca.sqlcode!=0) YL_abort("infx_subst-delete"); 
 /*OLDD:EXEC SQL delete from dts c using dts p where c.tid=:wi and p.tid=:wi and c.sid='Id' and p.nid=c.up and (p.rid='trmp' or p.rid='trmin');*/
 commit(); printf("\n<infx_subst msg='RESULT'>");int srt=sget_strt(tid); sprt_subtreeL(tid,srt);printf("\n</infx_subst>");
 end:
 /*printf("\n!infx_subst!DEBUG! end RC=%i",RC);*/
 return RC;
}
void term_subst_qv(int tid, int nid, char* v){
 /*Для кванторов строения: l_p Q Id COLON Id term r_p. назначает вхождениям Id-1 в term-1 значение v.*/
 /*вход: term0*/
 /*наличие не проверяем(!) это делают WFC-шники*/
 /*type ссылается на узел ква-фразы см. таблицу ТермТиО*/
 strcpy(wc,v); wi=tid; wi1=nid;/*именно ref=0 говорит что сслыка внутренняя! по идее sid лишний*/
 { ECPGdo(__LINE__, 0, 0, NULL, 0, ECPGst_normal, "update dts set v = $1  where tid = $2  and type = $3  and ref = 0 and sid = 'Id'", 
	ECPGt_char,(wc),(long)YL_STRING_BUF_LEN,(long)1,(YL_STRING_BUF_LEN)*sizeof(char), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, 
	ECPGt_int,&(wi1),(long)1,(long)1,sizeof(int), 
	ECPGt_NO_INDICATOR, NULL , 0L, 0L, 0L, ECPGt_EOIT, ECPGt_EORT);}
#line 1829 "YL_db.pgc"
 if(sqlca.sqlcode!=0) YL_abort("term_subst_qv-upd");
}
int ApplyTL(int tid, int nid){/* вычисляет результат применения значения (v) заданного узла (sid=term rid=trmf) к значениям (v) его аргументов. возвращает RC: 0,1.*/
 /*предусловие: у узла trmf и всех его узлах аргументах, значения уже вычислены!!!*/
 /*Логика хчф: применить <term-1>.v к значениям TermList и занести результат в .v*/
 /*Логика внешних чф: применить Сиф назначенный <term-1>.v к значениям TermList и занести результат в .v*/
 /*Алгоритм trmf-узла. 
 (Сиф) критерий проверки-до-полиморфы: если trmf\1 = trmi тогда его v (ид ф-и) проверяется на Сиф (первичность можно не проверять;-).
 (Сиф) критерий проверки-полиморфы: если trmf\1 = trmi тогда его ref - tid декл, и декл проверяется на Сиф (первичность можно не проверять;-).
  если Сиф обнаружен, то в переключателе вызова формируются значения аргументов (сколько надо), проверяются на наличие и вызывается зашитая ф-я!*/
  int dbg=0/*управляет выдачей протокола отладки: 0 - не выдавать*/;
  char buf[YL_STRING_BUF_LEN]=""/*буфер сериализации*/; char arg1[YLsbl]/*арг1 Сиф*/; char arg2[YLsbl]/*арг2 Сиф*/;  char v[YLsbl]=""/*значение терма*/;char rid1[22]/*rid term-1...*/;
  sget_rid(tid,nid,"1.",rid1); if(strcmp(rid1,"trmi")!=0) goto strf;
  int tidd/*tid декл ф-и*/;tidd=sget_ref(tid,nid,"0.");int rnid=sget_strt(tidd);sget_rid(tidd,rnid,"1.",rid1); if(strcmp(rid1,"Dcl_prmfC")!=0) goto strf;
  char cf[22]/*Сиф-ид*/; sget_v(tidd,rnid,"1.5.",cf);
  if(strcmp(cf,"fm_strcmp")==0){/*это тождество*/if(dbg!=0) printf("<ApplyTL msg='!DEBUG!fm_strcmp is called'/>");
   /*собираем значения аргументов через TermList. Считаем что они есть и правильные. Вызываем fm_strcmp*/
   sget_v(tid,nid,"3.-2.",arg1); sget_v(tid,nid,"3.-1.",arg2); fm_strcmp(arg1,arg2,v); if(dbg!=0) printf("<ApplyTL msg='!DEBUG!fm_strcmp done' arg1='%s' arg2='%s' res='%s'/>",arg1,arg2,v);
   goto end;
  };
  if(strcmp(cf,"fm_req")==0){if(dbg!=0) printf("<ApplyTL msg='!DEBUG!fm_req is called'/>");
   /*собираем значения аргументов через TermList. Считаем что они есть и правильные. Вызываем fm_req*/
   sget_v(tid,nid,"3.-2.",arg1); sget_v(tid,nid,"3.-1.",arg2); fm_req(arg1,arg2,v); if(dbg!=0) printf("\n!ApplyTL!DEBUG!fm_req done arg1='%s' arg2='%s' res='%s'.",arg1,arg2,v);
   goto end;
  };
  if(strcmp(cf,"fm_rlt")==0){if(dbg!=0) printf("<ApplyTL msg='!DEBUG!fm_rlt is called'/>");
   /*собираем значения аргументов через TermList. Считаем что они есть и правильные. Вызываем fm_rlt*/
   sget_v(tid,nid,"3.-2.",arg1); sget_v(tid,nid,"3.-1.",arg2); fm_rlt(arg1,arg2,v); if(dbg!=0) printf("\n!ApplyTL!DEBUG!fm_rlt done arg1='%s' arg2='%s' res='%s'.",arg1,arg2,v);
   goto end;
  };
  printf("\n<ApplyTL msg='!!!!!!!!!!!!!!!!!!SERROR!!!!!!!!!!!!!!!!!! Add this C-func %s to Yp!(SERR-1)'/>",cf) ;return 1;
 strf:
 /*Алгоритм trmf-узла. (хранимая ф-я) надо собрать сериализацию детей и искать в КС:
  -если нет и терм имеет простое значение, RC=1 - нет значения, если значение - ф-я: v не назначать и возвращать 0 - сериализатор учтёт!
  -если есть, значение заносится в v и RC=0.*/
 /*собрать сериализацию детей.*/trm_t2s(tid,nid,buf); if(dbg!=0) printf("<ApplyTL msg='!DEBUG!' ser-val='%s' tid='%i' nid='%i' />",buf,tid,nid);
 /*искать в КС*/ int RC=fm_tGetv(buf,v);		if(dbg!=0) printf("<ApplyTL msg='!DEBUG!after fm_tGetv' v='%s' RC='%i' />",v,RC);
 char tp[YLsbl]=""/*сорт для простого значения*/;int RC2=trm_viss(tid,nid,tp);		if(dbg!=0) printf("\n!ApplyTL:FMv type is '%s':-)",tp);
 if(RC!=0)/*у терма нет значения*/{if(RC2==0)/*значение простое*/ return 1; else return 0;};
 /*очищаем значение строки от кавычек сериализации*/
 if(strcmp(tp,"String")==0){/*стрипим обрамляющие кавычки*/int vl=strlen(v);int i;for (i=1;i<vl-1;i++)v[i-1]=v[i]; v[vl-2]=0;if(dbg!=0) printf("\n!ApplyTL:FMv type is String, v is '%s':-)",v);};
 end: sput_v(tid,nid,v); return 0;
}
int trm_Val(int tid, int nid){/* вычисляет значение заданного узлом терма (sid='term'). Если значение есть, заполняет значением атрибут v узла и возвращает 0; иначе 1.*/
 /*алгоритм пишется для случая хчф - хранимых частичных ф-й*//*для rid=trmf вызывает ApplyTL.*/
 int dbg=1;/*управляет выдачей протокола отладки: 0 - не выдавать*/
 char Rv[YLsbl]=""/*рекорд для минимаксов*/; char V[YLsbl]=""/*текущее для минимаксов...*/; int cf=0/*флаг переборов - было значение в 1*/;
 char crid[22]/*rid текущего терм-узла*/; char sort[YLsbl]/*имя сорта в котором перебор*/; char ts[YLsbl]=""/*сорт терма*/; int term1/*ид первого терма справа*/;
 int i;
 /*+$?проверить на всякий случай что мы в sid='term'*/
 sget_rid(tid,nid,"0.",crid)/*получили rid*/; if(dbg!=0) printf("\n!trm_Val!DEBUG! IN rid=%s (tid=%i,nid=%i)",crid,tid,nid);
 /*обработчики*/if(dbg!=0) printf("\n!trm_Val!DEBUG!BEFORE CASE crid='%s'",crid);
 if((strcmp(crid,"trmi")==0)||(strcmp(crid,"_trmRE")==0)) {/*берём значение у правой части*/sget_v(tid,nid,"1.",V); 
  sput_v(tid,nid,V); if(dbg!=0) printf(" !trm_Val!DEBUG!OUT v='%s'",V); return 0;};
 if(strcmp(crid,"trmf")==0){/*мы в trmf-узле: term l_p TermList r_p.*/
  /*получаем nid term-1*/term1=sget_nid(tid,nid,"1.");
  if(trm_Val(tid,term1)==1) return 1; /*+$$$здесь ветвление на внешнюю алгоритмику*//*Логика вычисления хранимых чф: в <term-1>.v какая-то чхф.*/
  /*получаем nid TermList*/int TL=sget_nid(tid,nid,"3."); /*Получить в N кол-во членов TermList*/int N=sget_chn(tid,TL);
  /*обработать членов TermList*/
  if(N!=0) for(i=1;i<N+1;i++){/*получить ид i-ого ребё*/int TLi=sget_chi(tid,TL,i); /*обработать его*/if(trm_Val(tid,TLi)==1) return 1;};
  /*применить <term-1>.v к значениям TermList и занести результат в .v*/if(ApplyTL(tid,nid)==1) return 1; 
  return 0;
 };
 if(strcmp(crid,"trme")==0){/*l_p EXISTS  Id COLON Id term r_p. Формула: MAX[i:|Id-2|]Val(term-1(Id-1/i)) !!!"/" - подстановка;-)*/
  /*Делаем общий случай MAX! */
  /*тупо - через рекорд. все виды значений кроме Number и Year сравниваются как строки!*/
  sget_v(tid,nid,"5.",sort)/*получили Id-2.v - сорт пробега*/;
  /*получить tid первого элемента сорта (носителя) 0 - пусто*/int cce=fm_cgetFirst(sort);if(dbg!=0) printf("\n!trm_Val.trme!DEBUG!first tid(cce)='%i'.",cce);
  /*Если cce=0 то return 1 (NV). Не соответствует кванторам!!!*/if(cce==0) {if(dbg!=0) printf("\n!trm_Val.trme!DEBUG!EMPTY! sort='%s'! </trme>",sort);return 1;};
  /*получаем nid term-1*/term1=sget_nid(tid,nid,"6."); 
  /*получаем сорт рез-та term-0*//*длинная ссылка на сорт в сигнатуре ф-и*/ int ts_ref=sget_ref(tid,nid,"0."); int ts_type=sget_type(tid,nid,"0.");
  /*получаем ид сорта значения*/sget_v(ts_ref,ts_type,"0.",ts);
  while(cce!=0){
   /*получаем значение текущего элемента основы*/fm_cGetv(cce,V);
   /*назначаем вхождениям Id-1 в term-1 значение V*/term_subst_qv(tid,nid,V);/*чистим trmf.v*/trm_cl_trmf_v(tid,nid);
   /*вычисляем значение term-1*/  /*!!!если при переборе очередное применение ф-и не имеет значения то идём дальше*/if(trm_Val(tid,term1)==1) goto nexte;
   /*получаем значение term-1 в V*/sget_v(tid,term1,"0.",V); if(cf==0){strcpy(Rv,V);cf=1;};if(dbg!=0) printf("\n!trm_Val.trme!DEBUG!Record and cur-ce value' Rv='%s' V='%s'.",Rv,V);
   /*обрабатываем рекорд*/ int rc=fm_cmpVal(Rv,V,ts); if (rc>=0) goto nexte; strcpy(Rv,V);
   nexte:/*получаем следующий*/cce=fm_cgetNext(sort,cce);if(dbg!=0) printf("\n!trm_Val.trme!DEBUG!next ce cce=%i.\n</trmec>",cce);
  };
  /*!!!возможен случай когда ни на одном эо значения нет - пустая ф-я! тогда NV*/if(cf==0) return 1;
  /*заносим рекорд*/ sput_v(tid,nid,Rv); if(dbg!=0) printf("\n!trm_Val.trme!DEBUG!final value Rv='%s'.",Rv); return 0;
 };
 if(strcmp(crid,"trma")==0){/*l_p FOR_ANY Id COLON Id term r_p. Формула: MIN[i:1..|Id-2|]Val(term-1(Id-1/Id-2[i])) !!!"/" - подстановка;-)*/
  /*Делаем общий случай MIN! НО TV - особый случай:сорт пуст либо есть NV возвращаем _F (см. документацию)*/
  /*тупо - через рекорд. все виды значений кроме Number и Year сравниваются как строки!*/
  sget_v(tid,nid,"5.",sort)/*получили Id-2.v*/;
  /*получаем сорт рез-та term-0*//*длинная ссылка на сорт в сигнатуре ф-и*/ int ts_ref=sget_ref(tid,nid,"0."); int ts_type=sget_type(tid,nid,"0.");
  /*получаем ид сорта значения term-0. !!!сорт(term-0)=сорт(term-1)!!!*/sget_v(ts_ref,ts_type,"0.",ts);
  /*получить tid первого элемента сорта (носителя) 0 - пусто*/int cce=fm_cgetFirst(sort);if(dbg!=0) printf("\n!trm_Val.trma!DEBUG!first' cce='%i'.",cce);
  /*Если cce=0 то если ts="TV" то returnV(!) _F иначе return 1 (NV). +?соответствует кванторам!?!*/
   if(cce==0) {if(dbg!=0) printf("\n!trm_Val.trma!DEBUG!EMPTY! sort='%s'! </trma>",sort);
    if(strcmp(ts,"TV")==0) {strcpy(Rv,"_False");goto A_putR;}; return 1;};
  /*получаем nid term-1*/term1=sget_nid(tid,nid,"6."); 
  while(cce!=0){
   /*получаем значение текущего элемента основы*/fm_cGetv(cce,V);
   /*назначаем вхождениям Id-1 в term-1 значение V*/term_subst_qv(tid,nid,V);/*чистим trmf.v*/trm_cl_trmf_v(tid,nid);
   /*вычисляем значение term-1*/ 
   /*!!!если при переборе очередное применение ф-и не имеет значения то идём дальше НО для TV - возвратВ _F*/
   if(trm_Val(tid,term1)==1) {if(strcmp(ts,"TV")==0) {strcpy(Rv,"_False"); goto A_putR;}; goto nexta;};
   /*получаем значение term-1 в V*/sget_v(tid,term1,"0.",V); if(cf==0){strcpy(Rv,V);cf=1;};if(dbg!=0) printf("\n!trm_Val.trma!DEBUG!Record and cur-ce value Rv='%s' V='%s'.",Rv,V);
   /*обрабатываем рекорд*/ int rc=fm_cmpVal(Rv,V,ts); if (rc<=0) goto nexta; strcpy(Rv,V);
   nexta:/*получаем следующий*/cce=fm_cgetNext(sort,cce);if(dbg!=0) printf("\n!trm_Val.trma!DEBUG!next ce cce=%i.",cce);
  };
  /*!!!возможен случай когда ни на одном эо значения нет - пустая ф-я!*/if(cf==0) return 1;
  A_putR:/*заносим рекорд*/ sput_v(tid,nid,Rv); if(dbg!=0) printf("\n!trm_Val.trma!DEBUG!final value Rv='%s'.",Rv);
  return 0;
 };
 if(strcmp(crid,"trmc")==0){/*l_p COUNT Id COLON Id term r_p. количество эл-тов сорта на которых term=_T*/
  int Ri=0/*сумматор*/;
  sget_v(tid,nid,"5.",sort)/*получили Id-2.v - сорт по которому бежим*/;
  /*получить tid первого элемента сорта (носителя) 0 - пусто*/int cce=fm_cgetFirst(sort);if(dbg!=0) printf("\n!trm_Val.trma!DEBUG!first' cce='%i'.",cce);
  /*Если cce=0 то рез-т 0*/
   if(cce==0) {if(dbg!=0) printf("\n!trm_Val.trma!DEBUG!EMPTY! sort='%s'! </trma>",sort);
    strcpy(Rv,"0");goto A_putC;};
  /*получаем nid term-1*/term1=sget_nid(tid,nid,"6."); 
  while(cce!=0){
   /*получаем значение текущего элемента основы*/fm_cGetv(cce,V);
   /*назначаем вхождениям Id-1 в term-1 значение V*/term_subst_qv(tid,nid,V);/*чистим trmf.v*/trm_cl_trmf_v(tid,nid);
   /*вычисляем значение term-1*/ 
   /*!!!если при переборе очередное применение ф-и не имеет значения то идём дальше*/
   if(trm_Val(tid,term1)==1) goto nextc;
   /*получаем значение term-1 в V*/sget_v(tid,term1,"0.",V); if(cf==0){strcpy(Rv,V);cf=1;};if(dbg!=0) printf("\n!trm_Val.trma!DEBUG!Record and cur-ce value Rv='%s' V='%s'.",Rv,V);
   /*обрабатываем рекорд*/ if(strcmp(V,"_True")==0) Ri=Ri+1;
   nextc:/*получаем следующий*/cce=fm_cgetNext(sort,cce);if(dbg!=0) printf("\n!trm_Val.trma!DEBUG!next ce cce=%i.",cce);
  };
  /*!!!возможен случай когда ни на одном эо значения нет - пустая ф-я!*/
  if(cf==0) strcpy(Rv,"0");else sprintf(Rv,"%i",Ri);
  A_putC:/*заносим рекорд*/ sput_v(tid,nid,Rv); if(dbg!=0) printf("\n!trm_Val.trma!DEBUG!final value Rv='%s'.",Rv);
  return 0;
 };
 if(strcmp(crid,"trms")==0){/*l_p SUM Id COLON Id term r_p. количество эл-тов сорта на которых term=_T*/
  double Rr=0/*сумматор*/;
  sget_v(tid,nid,"5.",sort)/*получили Id-2.v - сорт по которому бежим*/;
  /*получить tid первого элемента сорта (носителя) 0 - пусто*/int cce=fm_cgetFirst(sort);if(dbg!=0) printf("\n!trm_Val.trma!DEBUG!first' cce='%i'.",cce);
  /*Если cce=0 то NV*/
   if(cce==0) {if(dbg!=0) printf("\n!trm_Val.trma!DEBUG!EMPTY! sort='%s'! </trma>",sort);
    return 1;};
  /*получаем nid term-1*/term1=sget_nid(tid,nid,"6."); 
  while(cce!=0){
   /*получаем значение текущего элемента основы*/fm_cGetv(cce,V);
   /*назначаем вхождениям Id-1 в term-1 значение V*/term_subst_qv(tid,nid,V);/*чистим trmf.v*/trm_cl_trmf_v(tid,nid);
   /*вычисляем значение term-1*/ 
   /*!!!если при переборе очередное применение ф-и не имеет значения то идём дальше*/
   if(trm_Val(tid,term1)==1) goto nexts;
   /*получаем значение term-1 в V*/sget_v(tid,term1,"0.",V); if(cf==0){strcpy(Rv,V);cf=1;};if(dbg!=0) printf("\n!trm_Val.trma!DEBUG!Record and cur-ce value Rv='%s' V='%s'.",Rv,V);
   /*обрабатываем рекорд*/double Vf=atof(V); Rr=Rr+Vf;
   nexts:/*получаем следующий*/cce=fm_cgetNext(sort,cce);if(dbg!=0) printf("\n!trm_Val.trma!DEBUG!next ce cce=%i.",cce);
  };
  /*!!!возможен случай когда ни на одном эо значения нет - пустая ф-я! == NV*/
  if(cf==0) return 1;else sprintf(Rv,"%f",Rr);
  /*заносим рекорд*/ sput_v(tid,nid,Rv); if(dbg!=0) printf("\n!trm_Val.trma!DEBUG!final value Rv='%s'.",Rv);
  return 0;
 };
 /*неправильный rid!!!*/printf("\n!trm_Val: Unknown rid=%s. Abort!",crid);exit(EXIT_FAILURE);
}
char* q_term(char *st_id)/*q_m term q_m*/{/*st_id - ид узла предложения в ДРВ*/
/*возвращает сообщение: 
-если значение есть: The value is…
-если значения нет: There is no…
-в случае ошибки внизу: <пустую строку>
*/
 static char msg[256] /*буфер сообщения*/;char V[YLsbl]=""/*буфер значения*/;
 msg[0]=0; /*обнуляем static!*/
 int dbg=1/*флаг отладочной выдачи: 0 - выключена*/;
 printf("\n<q_term msg='begin'>");
 /*узел вершины дерева предложения*/ int snid=atoi(st_id);
 /*!!!мы сразу переходим в лес!!!*/
 int tr_id=st_store(st_id);
 int ctid=st_trans_fix(tr_id)/*транслируем и получаем клон*/;
 int t_id/*id вершины терма*/=sget_nid(ctid,snid,"2.");
 /*обработка запросного терма!*/
 char* msgw=term_proc(ctid,t_id,5); if (*msgw!=0) {printf("\n!q_term.term_proc-1:(%s)!",msgw); st_del(tr_id);st_del(ctid); goto end;};
 /*трансляция*/
 int rc;
 while(deff_subst(ctid)!=0);/*DEBUG printf("\n!q_term(DEBUG)deff_subst.rc=%i.",rc);*/
 /*К ЗНАЧЕНИЮ*/
 /*получаем указатель на приведённый терм и вперёд!*/
 t_id=sget_nid(ctid,snid,"2.");/*предполагается что t_id мог смениться!*/
 /*ВТОРИЧНАЯ ПОЛНАЯ(+!!!ЭТО ГРУБО!!!) обработка запросного терма!*/
 if(dbg!=0) printf("\n!q_term!DEBUG! POINT1<term_proc.");
 msgw=term_proc(ctid,t_id,5); if (*msgw!=0) {printf("\n!q_term.term_proc-2:(%s)!",msgw); st_del(tr_id);st_del(ctid); goto end;};
 if(dbg!=0) printf("\n!q_term!DEBUG! POINT2>term_proc.");
 rc=trm_Val(ctid,t_id); if(dbg!=0){/*выдаём терм посмотреть*/ printf("\n!q_term!DEBUG! after trm_Val point! rc=%i.",rc);sprt_subtreeLD(ctid,t_id);};
 if(rc!=0) sprintf(msg,"There is no value."); else {sget_v(ctid,snid,"2.",V); sprintf(msg,"The value is %s.",V);};
 if(dbg!=0) printf("\n!q_term!DEBUG! st_dels off! tr_id=%i ctid=%i.",tr_id,ctid);
 else{st_del(tr_id);st_del(ctid);};
 end:printf("</q_term>");
 return &msg[0];
}
/*мониторы и простые команды*/
void exN_proc(char *st_id){/*WFC: номер команды из списка.*/
 char Num_v[22];/*номер команды*/
 /*БЛОКИРУЕМ*/
 get_attr(2,st_id,"2.",Num_v);
 if (doc(Num_v)!=0) printf("\n<exN_proc msg='Not a valid command - %s!'/>",Num_v);
 return;
}
void str_com_proc(char *st_id){
 /*в лес*/
 int tr_id=st_store(st_id);
 /*printf("\n<str_com_proc! st_id=%s'/>",st_id);*/
}
void Ypm()/*монитор процессора Yp*/{
 int rc; char st_rid[22];  char st_id[22];/*id текущего предложения в ДРВ*/
 /*запрещаем буферизацию протокола*/
 setbuf(stdout, NULL);
 printf("\n<?xml version='1.0' encoding='UTF-8' ?>"); /* encoding="UTF-8"*/
 printf("\n<DT>");
 /*ГЛУБОКАЯ ОТЛАДКА: exit(101);*/
 if (connect()!=0) YL_abort("Yp_1. connection failed."); /*printf ("Connected.\n");*/
 /*код обработчика*/
 /*мы идём по предложениям постепенно увеличивая номер. мы обрабатываем <EBNF>Statements:Statement+. см. КСГ*/
 char pid[123]/*id узла Statements*/; get_min_id(/*sid*/"Statements",pid); /*получаем номер родителя предложений или abort*/
 /*if (pid[0] == 0) { printf("\n<:-(Yp_1. There is no Statements nodes in dt! Abort!'/>"); goto badr; };*/
 int chn = 1; /*номер текущего ребёнка в цепи (в данном случае первый это 1)*/
mc: get_chld_id(/*номер*/chn,/*родитель*/pid,st_id);
 if (st_id[0] == 0) {printf("\n<End msg='of Statement nodes in dt. Stop.' />"); printf("\n</DT>"); goto goodr;}
 /*обработать очередное Statement в зависимости от его rid.*/
 get_attr(1,st_id,"0.",st_rid); printf("\n<Yp1s st_id='%s' st_rid='%s'>",st_id,st_rid);
 /*порядок рид в case совпадает с ОЯ:-)*/
  if (strcmp(st_rid,"st-3")==0) str_com_proc(st_id); else
 if (strcmp(st_rid,"Dcl_prm")==0) /*любая первичка БЫЛО:первичная функция*/Dcl_prm(st_id); else 
 if (strcmp(st_rid,"Dcl_prmfC")==0) /*первичная функция с Сиф было f_add*/Dcl_prmfC(st_id); else 
  if (strcmp(st_rid,"fmca")==0) fmca_proc(st_id); else
  if (strcmp(st_rid,"fmcd")==0) fmcd_proc(st_id); else
  if (strcmp(st_rid,"fmcaq")==0) fmcaq_proc(st_id); else
  if (strcmp(st_rid,"fmcdq")==0) fmcdq_proc(st_id); else
  if (strcmp(st_rid,"fmtd")==0) fmtd_proc(st_id); else
  if (strcmp(st_rid,"fmta")==0) fmta_proc(st_id); else
 if (strcmp(st_rid,"Dcl-5")==0) /*функция с опред*/f_add(st_id,"Dcl-5"); else 
  if (strcmp(st_rid,"st-11")==0) {char* msg=q_term(st_id);   printf("\n<return msg='%s' />",msg); } else
  if (strcmp(st_rid,"st-6")==0) exN_proc(st_id); else
 {/*bad st_rid!!!*/printf("\n<Bad str_rid=%s for_st_id=%s msg='Skip!' />",st_rid,st_id);};
 printf("\n</Yp1s>");
 chn = chn + 1;
 goto mc;
goodr: rc = EXIT_SUCCESS;
ret: disconnect(); exit(rc);
badr: rc = EXIT_FAILURE; goto ret;/*+У:эта метка закомментарена - убрать?*/
}
/**/








