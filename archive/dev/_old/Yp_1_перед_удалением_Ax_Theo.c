/*Процессор Yp. Корень*/
/*первый шаг обработки ДРВ*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/*динамический (кучный;-) буфер значения атрибута-строки*/
#define YYSTYPE char* /*тип атрибута дерева - указатель на строку букв (НЕ ПРОХОДИТ: char [255])*/
YYSTYPE to_buff(char* in) { char* str_buff = malloc(256); strcpy(str_buff, in); return (str_buff); }
#include "YL_db.c"

int main (void) 
{int rc; char st_rid[22];  char st_id[22];/*id текущего предложения*/
 if (connect()!=0) YL_abort("Yp_1. connection failed."); /*printf ("Connected.\n");*/
 /*запрещаем буферизацию протокола*/
 setbuf(stdout, NULL);
 /*код обработчика*/
 /*мы идём по предложениям постепенно увеличивая номер.*/
 char pid[22]; get_min_id(/*sid*/"Statements",pid); /*получаем номер родителя предложений или abort*/
 /*if (pid[0] == 0) { printf("\n<:-(Yp_1. There is no Statements nodes in dt! Abort!'/>"); goto badr; };*/
 printf("<?xml version='1.0' encoding='UTF-8' ?>"); /* encoding="UTF-8"*/
 printf("\n<DT>");
 int chn = 1; /*номер текущего ребёнка в цепи (в данном случае первый это 1)*/
mc: get_chld_id(/*номер*/chn,/*родитель*/pid,st_id);
 if (st_id[0] == 0) {printf("\n<End msg='of Statement nodes in dt. Stop.' />"); printf("\n</DT>"); goto goodr;}
 /*обработать очередное предложение.*/
 get_attr(1,st_id,"0.",st_rid); printf("\n<Yp1s st_id='%s' st_rid='%s'>",st_id,st_rid);
 if (strcmp(st_rid,"st-1")==0) dcl_proc(st_id); else
 if (strcmp(st_rid,"st-2")==0) def_proc(st_id); else
 if (strcmp(st_rid,"st-3")==0) str_com_proc(st_id); else
 if (strcmp(st_rid,"st-4")==0) a_i2f(st_id); else
 if (strcmp(st_rid,"st-5")==0) axm_add(st_id); else
 if (strcmp(st_rid,"st-6")==0) exN_proc(st_id); else
 if (strcmp(st_rid,"fmca")==0) fmca_proc(st_id); else
 if (strcmp(st_rid,"fmcd")==0) fmcd_proc(st_id); else
 if (strcmp(st_rid,"fmtd")==0) fmtd_proc(st_id); else
 if (strcmp(st_rid,"fmta")==0) fmta_proc(st_id); else
 if (strcmp(st_rid,"st-11")==0) {char* msg=q_term(st_id);   printf("\n<return msg='%s' />",msg); } else
 if (strcmp(st_rid,"st-12")==0) prf_add(st_id); else
 if (strcmp(st_rid,"st-13")==0) theo_add(st_id); else
 {/*bad st_rid!!!*/printf("\n<Bad str_rid=%s for_st_id=%s msg='Skip!' />",st_rid,st_id);};
 printf("\n</Yp1s>");
 chn = chn + 1;
 goto mc;
goodr: rc = EXIT_SUCCESS;
ret: disconnect(); exit(rc);
badr: rc = EXIT_FAILURE; goto ret;
}
