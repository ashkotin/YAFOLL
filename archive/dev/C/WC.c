int trm_Val(int tid, int nid){/* вычисляет значение заданного узла. Если значение есть, заполняет значением атрибут v узла и возвращает RC=0; иначе RC=1.*/
/*мы в trmf-узле: term l_p TermList r_p.*/
int RC=trm_Val(<term-1>); if(RC==1) return 1; Var Ф1=get_v(<term-1>); /*это какая-то ф-я.*/
int N; /*Получить в N кол-во членов TermList*/ int i;for(i=1;i<N+1;i++){RC=trm_Val(<TermList[i]>); if(RC==1) return 1;};
Var П1; RC=ApplyT(Ф1,TermList,П1); if(RC==1) return 1;
put_v(tid,nid,П1);
return 0;
}