/* Processed by ecpg (11.1) */
/* These include files are added by the preprocessor */
#include <ecpglib.h>
#include <ecpgerrno.h>
#include <sqlca.h>
/* End of automatic include section */

#line 1 "YL_db__SA_call.pgc"
/*это пакет ф-й вызываемых из СА для построения ДРВ*/
void dt_reset(int mod){/*зачищает ДРВ-часть БД. mod = 1 - чистить, иначе - нет.*//*ВЫЗЫВАЕТСЯ в СА!!!*/
 return;
}
void up_node(char* from, char* to, int irn)/*ДРВ. назначает узлу ид=from родителя ид=to, и номер "в родителе" - irn.*/{
 /*from - id ребё, to - id родителя, irn - номер в правиле/цепи.*/
 return;
}
char* crt_prnt(char* sid, char* rid, char* v)/*ДРВ.создаётся узел ("для родителя") и его ид закатывается в кучу и именно на это значение возвращается указатель!*/{
 return &wc1[0]; /*это довольно прилично*/
}
void crt_up_node(char* sid, char* rid, char* v, char* to, int irn)/*ДРВ. создаёт и сразу подключает ребё.*/{
 return;
}
int get_chn(char* id)/*ДРВ. возвращает К1 - количество “детей” данного узла (id).*/{
 return 1;
}
