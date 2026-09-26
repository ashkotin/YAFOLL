









int get_qua(int tid, int snid)/*Лес. возвращает nid терма квантора либо 0 - не нашёл*/{
 /*tid - ид дерева предложения, snid - стартовый узел Id/trmi*/ 
 char Id_1[YLsbl]/*значение Id-1 при очередном кванторе*/; char crid[22]/*значение текущего rid*/;char iv[YLsbl]/*значение Id.v нашего Id/trmi*/;
 char csid[YLsbl]/*значение sid текущего узла.*/;
 int cnid=snid/*текущий узел на пути вверх. начинаем с Id/trmi*/; 
 /*получаем Id.v (его мы ищем)*/sget_v(tid,snid,"0.",iv); /*printf("\n!get_qua: DEBUG! start tid=%i, snid=%i, iv='%s'.",tid,snid,iv);*/
 /*Шаг вверх к trmi-узлу.*/  /*printf("\n!get_qua: DEBUG! before step up tid=%i, cnid=%i.",tid,cnid);*/ cnid=sget_up(tid,cnid);
 /*пока текущий узел - term обрабатываем его и шагаем вверх.*/
 do 
  /*получаем rid*/ sget_rid(tid,cnid,"0.",crid);
  /*если узел ква*/
  if (strcmp(crid,"trma")==0 || strcmp(crid,"trme")==0) {/*l_p _Q_ Id COLON Id term r_p*/
   /*!узел - ква!*/
   /*получаем Id-1.v*/ sget_v(tid,cnid,"3.",Id_1);   /*printf("\n!get_qua: DEBUG! sget_v gives Id_1='%s'.",Id_1);*/
   /*если совпадают вернуть cnid.*/ if(strcmp(iv,Id_1)==0) return cnid;
  };
  /*!ква но не тот либо не квантор!*/
  /*Шаг вверх.*/  /*printf("\n!get_qua: DEBUG! step up tid=%i, cnid=%i.",tid,cnid);*/ cnid=sget_up(tid,cnid);
  /*получаем sid*/ sget_sid(tid,cnid,"0.",csid);
 while (strcmp(csid,"term")==0);
 /*обработали все term и не нашли*/ return 0;
}
