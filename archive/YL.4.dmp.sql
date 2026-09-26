--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: _w; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE _w (
    nid integer NOT NULL,
    flg integer DEFAULT 0
);


ALTER TABLE public._w OWNER TO postgres;

--
-- Name: TABLE _w; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE _w IS 'рабочая таблица для множества узлов';


--
-- Name: COLUMN _w.nid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN _w.nid IS 'ид узла';


--
-- Name: COLUMN _w.flg; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN _w.flg IS 'Флажок. 0 - не обработан, 1 - обработан.';


--
-- Name: dt; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE dt (
    id character varying(21) NOT NULL,
    up character varying(21),
    sid character varying(121),
    rid character varying(21),
    v character varying(121),
    irn integer
);


ALTER TABLE public.dt OWNER TO postgres;

--
-- Name: TABLE dt; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE dt IS 'ДРВ';


--
-- Name: COLUMN dt.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dt.id IS 'УИД';


--
-- Name: COLUMN dt.up; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dt.up IS 'ссылка вверх';


--
-- Name: COLUMN dt.sid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dt.sid IS 'идентификатор нт. для внутреннего узла - синтаксический нт - левая часть некоего правила.
для листа - его лнт.';


--
-- Name: COLUMN dt.rid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dt.rid IS 'УИД правила. для внутреннего узла - правило по которому он был развёрнут.
Для лнт пока "".';


--
-- Name: COLUMN dt.v; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dt.v IS 'Синтаксическое значение нт. Пока только для лнт. Для внутреннего узла - "".';


--
-- Name: COLUMN dt.irn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dt.irn IS '"номер в правиле". для корня - Null,
для ребёнка нт+ - его номер в цепи,
для обычного правила - номер позиции в правиле.';


--
-- Name: dts; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE dts (
    tid integer NOT NULL,
    nid integer NOT NULL,
    up integer,
    sid character varying(121),
    rid character varying(21),
    v character varying(121),
    irn integer,
    ref integer,
    flg integer,
    flg2 integer,
    type integer
);


ALTER TABLE public.dts OWNER TO postgres;

--
-- Name: TABLE dts; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE dts IS 'Хранилище поддеревьев ДРВ';


--
-- Name: COLUMN dts.tid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dts.tid IS 'УИД дерева';


--
-- Name: COLUMN dts.nid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dts.nid IS 'УИД узла';


--
-- Name: COLUMN dts.up; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dts.up IS 'ссылка вверх';


--
-- Name: COLUMN dts.sid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dts.sid IS 'идентификатор нт. для внутреннего узла - синтаксический нт - левая часть некоего правила.
для листа - его лнт.';


--
-- Name: COLUMN dts.rid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dts.rid IS 'УИД правила. для внутреннего узла - правило по которому он был развёрнут.
Для лнт пока "".';


--
-- Name: COLUMN dts.v; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dts.v IS 'Синтаксическое значение нт. Пока только для лнт. Для внутреннего узла - "".';


--
-- Name: COLUMN dts.irn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dts.irn IS '"номер в правиле". для корня - Null,
для ребёнка нт+ - его номер в цепи,
для обычного правила - номер позиции в правиле.';


--
-- Name: COLUMN dts.ref; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dts.ref IS 'для значаших узлов терма - ссылка на узел декларации. см. код
назначается после идентификации.
используется при типизации.';


--
-- Name: COLUMN dts.flg; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dts.flg IS 'Флаг обработки для всяческих алгоритмов на дереве';


--
-- Name: COLUMN dts.flg2; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dts.flg2 IS 'Флаг обработки для всяческих алгоритмов на дереве. Если flg занят.';


--
-- Name: COLUMN dts.type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN dts.type IS 'nid узла типа (см. док)';


--
-- Name: entities; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE entities (
    id character varying(21) NOT NULL,
    ref_r character varying(21),
    def_id character varying(21),
    expr character varying(1021),
    type character varying(20) NOT NULL,
    ref_arg character varying(21),
    fp_id character varying(21),
    prime integer,
    ein integer,
    sers character varying(121),
    tid integer,
    cf character varying(21)
);


ALTER TABLE public.entities OWNER TO postgres;

--
-- Name: COLUMN entities.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN entities.id IS 'См. YAFOLL. БД. Правила заполнения полей';


--
-- Name: COLUMN entities.ref_r; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN entities.ref_r IS 'Функция: ссылка на сорт или сигнатуру результата. Константа - ссылка на сорт.';


--
-- Name: COLUMN entities.def_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN entities.def_id IS 'идентификатор определения функции';


--
-- Name: COLUMN entities.expr; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN entities.expr IS 'заполняется для
- сорт:  РВ
- определения, аксиома, теорема : терм
- доказательство:  выражение вывода';


--
-- Name: COLUMN entities.type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN entities.type IS 'тип записи см. YAFOLL. БД. Правила заполнения полей.';


--
-- Name: COLUMN entities.ref_arg; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN entities.ref_arg IS 'ссылка на сорт или сигнатуру функции или сигнатуру цепи аргументов';


--
-- Name: COLUMN entities.fp_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN entities.fp_id IS 'идентификатор формального параметра ф-и. Если он один и сиг его - сорт.';


--
-- Name: COLUMN entities.prime; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN entities.prime IS '0 - нет, 1 - да.';


--
-- Name: COLUMN entities.ein; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN entities.ein IS 'Номер сущего в порядке ввода. Свободный номер лежит в записи system.';


--
-- Name: COLUMN entities.sers; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN entities.sers IS 'Сериализация сигнатуры. См. док.';


--
-- Name: COLUMN entities.tid; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN entities.tid IS 'Ссылка в лес деревьев';


--
-- Name: COLUMN entities.cf; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN entities.cf IS 'Идентификатор Сиф если есть приписанная.';


--
-- Name: fm_tv; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE fm_tv (
    t character varying(1023) NOT NULL,
    v character varying(121) NOT NULL
);


ALTER TABLE public.fm_tv OWNER TO postgres;

--
-- Name: TABLE fm_tv; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE fm_tv IS 'отображение терма в значение';


--
-- Name: COLUMN fm_tv.t; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fm_tv.t IS 'сериализация терма';


--
-- Name: COLUMN fm_tv.v; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN fm_tv.v IS 'значение в строковой форме без обрамления';


--
-- Name: infixes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE infixes (
    v character varying(21) NOT NULL,
    ref_f character varying(21) NOT NULL
);


ALTER TABLE public.infixes OWNER TO postgres;

--
-- Name: COLUMN infixes.v; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN infixes.v IS 'значение инфикса';


--
-- Name: COLUMN infixes.ref_f; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN infixes.ref_f IS 'Ссылка на ф-ю для которой инфикс.';


--
-- Name: sinfixes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sinfixes (
    v character varying(22) NOT NULL
);


ALTER TABLE public.sinfixes OWNER TO postgres;

--
-- Name: TABLE sinfixes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE sinfixes IS 'Здесь хранятся многозначные инфиксы.';


--
-- Name: COLUMN sinfixes.v; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN sinfixes.v IS 'Значение инфикса';


--
-- Name: system; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE system (
    id character varying(21) NOT NULL,
    fsn integer NOT NULL,
    fen integer NOT NULL,
    ftn integer NOT NULL,
    fnn integer,
    ftrn integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.system OWNER TO postgres;

--
-- Name: TABLE system; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE system IS 'Хранит значения системных переменных и версию Yp.';


--
-- Name: COLUMN system.fsn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN system.fsn IS 'free sig number';


--
-- Name: COLUMN system.fen; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN system.fen IS 'свободный номер для сущего при вводе. Фактически его номер в полном тексте теории.
Начальное значение - 1.';


--
-- Name: COLUMN system.ftn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN system.ftn IS 'свободный номер для ид терма.';


--
-- Name: COLUMN system.fnn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN system.fnn IS 'свободный номер узла ДРВ';


--
-- Name: COLUMN system.ftrn; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN system.ftrn IS 'свободный номер для дерева в dts';


--
-- Data for Name: _w; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY _w (nid, flg) FROM stdin;
\.


--
-- Data for Name: dt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dt (id, up, sid, rid, v, irn) FROM stdin;
0000000002	0000000001	Id	\N	x	1
0000000004	0000000003	Id	\N	x	1
0000000006	0000000005	l_p	\N	(	1
0000000001	0000000005	term	trmi	\N	2
0000000007	0000000005	INFIX	\N	=	3
0000000003	0000000005	term	trmi	\N	4
0000000008	0000000005	r_p	\N	)	5
0000000010	0000000009	l_p	\N	(	1
0000000011	0000000009	FOR_ANY	\N	∀	2
0000000012	0000000009	Id	\N	x	3
0000000013	0000000009	COLON	\N	:	4
0000000014	0000000009	Id	\N	sample	5
0000000005	0000000009	term	trmin	\N	6
0000000015	0000000009	r_p	\N	)	7
0000000017	0000000016	q_m	\N	?	1
0000000009	0000000016	term	trma	\N	2
0000000018	0000000016	q_m	\N	?	3
0000000019	\N	Statements	#st	\N	\N
0000000016	0000000019	Statement	st-11	\N	1
\.


--
-- Data for Name: dts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dts (tid, nid, up, sid, rid, v, irn, ref, flg, flg2, type) FROM stdin;
6	55	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
1	7	6	String	\N	TV DAD	1	\N	\N	\N	\N
1	6	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
2	8	13	Declaration	Dcl-1	\N	1	\N	\N	\N	\N
2	9	8	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
2	10	8	Id	\N	TV	2	\N	\N	\N	\N
536	1	3	sig_e	sig_eI	\N	1	\N	\N	\N	\N
7	57	56	Add	\N	Add	1	\N	\N	\N	\N
7	58	56	infix	\N	infix	2	\N	\N	\N	\N
7	59	56	String	\N	∧	3	\N	\N	\N	\N
7	60	56	to	\N	to	4	\N	\N	\N	\N
7	61	56	Id	\N	AND	5	\N	\N	\N	\N
7	62	56	Dot	\N	.	6	\N	\N	\N	\N
2	11	8	sort	\N	sort	3	\N	\N	\N	\N
7	56	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
2	12	8	Dot	\N	.	4	\N	\N	\N	\N
2	13	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
8	64	63	Add	\N	Add	1	\N	\N	\N	\N
8	65	63	infix	\N	infix	2	\N	\N	\N	\N
8	66	63	String	\N	and	3	\N	\N	\N	\N
8	67	63	to	\N	to	4	\N	\N	\N	\N
8	68	63	Id	\N	AND	5	\N	\N	\N	\N
3	14	16	sig_e	sig_eI	\N	1	\N	\N	\N	\N
8	69	63	Dot	\N	.	6	\N	\N	\N	\N
3	15	14	Id	\N	TV	1	\N	\N	\N	\N
8	63	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
9	70	72	sig_e	sig_eI	\N	1	\N	\N	\N	\N
9	71	70	Id	\N	TV	1	\N	\N	\N	\N
9	72	77	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
9	73	72	sig_e	sig_eI	\N	2	\N	\N	\N	\N
9	74	73	Id	\N	TV	1	\N	\N	\N	\N
9	75	77	sig_e	sig_eI	\N	3	\N	\N	\N	\N
9	76	75	Id	\N	TV	1	\N	\N	\N	\N
9	77	79	sig_f	sig_f	\N	3	\N	\N	\N	\N
3	16	19	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
9	78	77	COLON	\N	:	2	\N	\N	\N	\N
9	79	84	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
9	80	79	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
9	81	79	Id	\N	OR	2	\N	\N	\N	\N
9	82	79	PRIME	\N	prime	4	\N	\N	\N	\N
3	17	19	sig_e	sig_eI	\N	3	\N	\N	\N	\N
9	83	79	Dot	\N	.	5	\N	\N	\N	\N
9	84	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
10	86	85	Add	\N	Add	1	\N	\N	\N	\N
10	87	85	infix	\N	infix	2	\N	\N	\N	\N
10	88	85	String	\N	∨	3	\N	\N	\N	\N
10	89	85	to	\N	to	4	\N	\N	\N	\N
10	90	85	Id	\N	OR	5	\N	\N	\N	\N
3	18	17	Id	\N	TV	1	\N	\N	\N	\N
3	19	21	sig_f	sig_f	\N	3	\N	\N	\N	\N
10	91	85	Dot	\N	.	6	\N	\N	\N	\N
10	85	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
3	20	19	COLON	\N	:	2	\N	\N	\N	\N
3	21	26	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
3	22	21	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
3	23	21	Id	\N	NOT	2	\N	\N	\N	\N
3	24	21	PRIME	\N	prime	4	\N	\N	\N	\N
3	25	21	Dot	\N	.	5	\N	\N	\N	\N
3	26	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
4	28	27	Add	\N	Add	1	\N	\N	\N	\N
4	29	27	infix	\N	infix	2	\N	\N	\N	\N
4	30	27	String	\N	¬	3	\N	\N	\N	\N
4	31	27	to	\N	to	4	\N	\N	\N	\N
4	32	27	Id	\N	NOT	5	\N	\N	\N	\N
4	33	27	Dot	\N	.	6	\N	\N	\N	\N
4	27	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
5	35	34	Add	\N	Add	1	\N	\N	\N	\N
5	36	34	infix	\N	infix	2	\N	\N	\N	\N
5	37	34	String	\N	not	3	\N	\N	\N	\N
5	38	34	to	\N	to	4	\N	\N	\N	\N
5	39	34	Id	\N	NOT	5	\N	\N	\N	\N
5	40	34	Dot	\N	.	6	\N	\N	\N	\N
5	34	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
11	93	92	Add	\N	Add	1	\N	\N	\N	\N
6	41	43	sig_e	sig_eI	\N	1	\N	\N	\N	\N
6	42	41	Id	\N	TV	1	\N	\N	\N	\N
6	43	48	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
11	94	92	infix	\N	infix	2	\N	\N	\N	\N
6	44	43	sig_e	sig_eI	\N	2	\N	\N	\N	\N
6	45	44	Id	\N	TV	1	\N	\N	\N	\N
6	46	48	sig_e	sig_eI	\N	3	\N	\N	\N	\N
6	47	46	Id	\N	TV	1	\N	\N	\N	\N
6	48	50	sig_f	sig_f	\N	3	\N	\N	\N	\N
6	49	48	COLON	\N	:	2	\N	\N	\N	\N
6	50	55	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
6	51	50	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
11	95	92	String	\N	or	3	\N	\N	\N	\N
6	52	50	Id	\N	AND	2	\N	\N	\N	\N
11	96	92	to	\N	to	4	\N	\N	\N	\N
11	97	92	Id	\N	OR	5	\N	\N	\N	\N
11	98	92	Dot	\N	.	6	\N	\N	\N	\N
11	92	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
12	99	101	sig_e	sig_eI	\N	1	\N	\N	\N	\N
12	100	99	Id	\N	TV	1	\N	\N	\N	\N
12	101	106	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
12	102	101	sig_e	sig_eI	\N	2	\N	\N	\N	\N
6	53	50	PRIME	\N	prime	4	\N	\N	\N	\N
6	54	50	Dot	\N	.	5	\N	\N	\N	\N
12	103	102	Id	\N	TV	1	\N	\N	\N	\N
12	104	106	sig_e	sig_eI	\N	3	\N	\N	\N	\N
12	105	104	Id	\N	TV	1	\N	\N	\N	\N
12	106	108	sig_f	sig_f	\N	3	\N	\N	\N	\N
12	107	106	COLON	\N	:	2	\N	\N	\N	\N
12	108	112	Declaration	Dcl-5	\N	1	\N	\N	\N	\N
12	109	108	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
12	110	108	Id	\N	IMPLIES	2	\N	\N	\N	\N
12	111	108	Dot	\N	.	4	\N	\N	\N	\N
12	112	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
13	114	113	Add	\N	Add	1	\N	\N	\N	\N
13	115	113	infix	\N	infix	2	\N	\N	\N	\N
13	116	113	String	\N	→	3	\N	\N	\N	\N
13	117	113	to	\N	to	4	\N	\N	\N	\N
13	118	113	Id	\N	IMPLIES	5	\N	\N	\N	\N
13	119	113	Dot	\N	.	6	\N	\N	\N	\N
13	113	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
14	121	120	Add	\N	Add	1	\N	\N	\N	\N
14	122	120	infix	\N	infix	2	\N	\N	\N	\N
14	123	120	String	\N	impl	3	\N	\N	\N	\N
14	124	120	to	\N	to	4	\N	\N	\N	\N
14	125	120	Id	\N	IMPLIES	5	\N	\N	\N	\N
14	126	120	Dot	\N	.	6	\N	\N	\N	\N
14	120	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
15	133	146	Id_list_bch	#Id_list_bch	\N	4	\N	0	1	\N
15	130	133	Id_list_b	Id_list_b-1	\N	1	\N	0	1	\N
15	127	130	Id_list	#Id_list	\N	2	\N	0	1	\N
15	152	\N	Statement	st-2	\N	\N	16	0	0	\N
168	2	1	e_m	\N	!	1	\N	\N	\N	\N
168	3	1	Id	\N	PUB5918	2	\N	\N	\N	\N
168	4	1	Id	\N	publication	3	\N	\N	\N	\N
168	5	1	e_m	\N	!	4	\N	\N	\N	\N
168	1	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
536	2	1	Id	\N	sample	1	\N	\N	\N	\N
15	128	127	Id	\N	x	1	12	0	1	100
15	129	127	Id	\N	z	2	12	0	1	100
15	131	130	l_p	\N	(	1	\N	0	1	\N
15	132	130	r_p	\N	)	3	\N	0	1	\N
536	3	6	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
536	4	6	sig_e	sig_eI	\N	3	\N	\N	\N	\N
15	135	134	Id	\N	x	1	128	2	0	0
536	5	4	Id	\N	TV	1	\N	\N	\N	\N
536	6	8	sig_f	sig_f	\N	3	\N	\N	\N	\N
15	141	140	Id	\N	z	1	129	2	0	0
15	134	136	term	trmi	\N	3	12	2	0	100
15	140	142	term	trmi	\N	4	12	2	0	100
536	7	6	COLON	\N	:	2	\N	\N	\N	\N
536	8	13	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
536	9	8	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
536	10	8	Id	\N	basalt_and_olivine	2	\N	\N	\N	\N
536	11	8	PRIME	\N	prime	4	\N	\N	\N	\N
536	12	8	Dot	\N	.	5	\N	\N	\N	\N
536	13	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
537	15	17	sig_e	sig_eI	\N	1	\N	\N	\N	\N
178	124	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
537	16	15	Id	\N	sample	1	\N	\N	\N	\N
537	17	20	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
537	18	20	sig_e	sig_eI	\N	3	\N	\N	\N	\N
537	19	18	Id	\N	TV	1	\N	\N	\N	\N
537	20	22	sig_f	sig_f	\N	3	\N	\N	\N	\N
537	21	20	COLON	\N	:	2	\N	\N	\N	\N
537	22	27	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
15	138	136	INFIX	\N	¬	2	3	2	0	19
537	23	22	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
537	24	22	Id	\N	trachydolerite	2	\N	\N	\N	\N
537	25	22	PRIME	\N	prime	4	\N	\N	\N	\N
537	26	22	Dot	\N	.	5	\N	\N	\N	\N
537	27	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
538	28	30	sig_e	sig_eI	\N	1	\N	\N	\N	\N
16	127	130	Id_list	#Id_list	\N	2	\N	0	0	\N
538	29	28	Id	\N	sample	1	\N	\N	\N	\N
538	30	33	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
16	128	127	Id	\N	x	1	12	0	0	100
16	129	127	Id	\N	z	2	12	0	0	100
16	130	133	Id_list_b	Id_list_b-1	\N	1	\N	0	0	\N
16	131	130	l_p	\N	(	1	\N	0	0	\N
16	132	130	r_p	\N	)	3	\N	0	0	\N
15	137	136	l_p	\N	(	1	\N	1	0	\N
16	133	146	Id_list_bch	#Id_list_bch	\N	4	\N	0	0	\N
15	139	136	r_p	\N	)	4	\N	1	0	\N
538	31	33	sig_e	sig_eI	\N	3	\N	\N	\N	\N
538	32	31	Id	\N	TV	1	\N	\N	\N	\N
538	33	35	sig_f	sig_f	\N	3	\N	\N	\N	\N
15	143	142	l_p	\N	(	1	\N	1	0	\N
538	34	33	COLON	\N	:	2	\N	\N	\N	\N
15	145	142	r_p	\N	)	5	\N	1	0	\N
15	146	152	Definition	Def-2	\N	1	\N	0	0	\N
15	147	146	DEFINITION	\N	Definition	1	\N	0	0	\N
15	148	146	Id	\N	IMPL_d	2	\N	0	0	\N
15	149	146	Id	\N	IMPLIES	3	\N	0	0	\N
15	150	146	COLON	\N	:	5	\N	0	0	\N
15	151	146	Dot	\N	.	7	\N	0	0	\N
538	35	40	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
15	136	142	term	trmp	\N	2	3	2	0	18
538	36	35	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
538	37	35	Id	\N	trachyte	2	\N	\N	\N	\N
15	144	142	INFIX	\N	∨	3	9	2	0	77
538	38	35	PRIME	\N	prime	4	\N	\N	\N	\N
538	39	35	Dot	\N	.	5	\N	\N	\N	\N
15	142	146	term	trmin	\N	6	9	2	0	76
538	40	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
539	41	43	sig_e	sig_eI	\N	1	\N	\N	\N	\N
539	42	41	Id	\N	sample	1	\N	\N	\N	\N
539	43	46	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
539	44	46	sig_e	sig_eI	\N	3	\N	\N	\N	\N
539	45	44	Id	\N	TV	1	\N	\N	\N	\N
16	142	146	term	trmf	\N	6	9	0	1	76
16	143	142	l_p	\N	(	2	\N	0	1	\N
16	136	1984	term	trmf	\N	-2	3	0	1	18
16	137	136	l_p	\N	(	2	\N	0	1	\N
16	139	136	r_p	\N	)	4	\N	0	1	\N
16	140	1984	term	trmi	\N	-1	12	0	1	100
16	141	140	Id	\N	z	1	129	0	1	0
16	134	1981	term	trmi	\N	-1	12	0	1	100
16	135	134	Id	\N	x	1	128	0	1	0
539	46	48	sig_f	sig_f	\N	3	\N	\N	\N	\N
174	78	77	e_m	\N	!	1	\N	\N	\N	\N
174	79	77	Id	\N	SAM30681	2	\N	\N	\N	\N
174	80	77	Id	\N	sample	3	\N	\N	\N	\N
174	81	77	e_m	\N	!	4	\N	\N	\N	\N
174	77	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
178	125	124	e_m	\N	!	1	\N	\N	\N	\N
178	126	124	Id	\N	PLC1555	2	\N	\N	\N	\N
178	127	124	Id	\N	place	3	\N	\N	\N	\N
178	128	124	e_m	\N	!	4	\N	\N	\N	\N
539	47	46	COLON	\N	:	2	\N	\N	\N	\N
539	48	53	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
539	49	48	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
539	50	48	Id	\N	obsidian	2	\N	\N	\N	\N
539	51	48	PRIME	\N	prime	4	\N	\N	\N	\N
539	52	48	Dot	\N	.	5	\N	\N	\N	\N
539	53	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
540	54	56	sig_e	sig_eI	\N	1	\N	\N	\N	\N
540	55	54	Id	\N	sample	1	\N	\N	\N	\N
540	56	59	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
540	57	59	sig_e	sig_eI	\N	3	\N	\N	\N	\N
540	58	57	Id	\N	TV	1	\N	\N	\N	\N
540	59	61	sig_f	sig_f	\N	3	\N	\N	\N	\N
540	60	59	COLON	\N	:	2	\N	\N	\N	\N
540	61	66	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
540	62	61	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
540	63	61	Id	\N	basalt	2	\N	\N	\N	\N
540	64	61	PRIME	\N	prime	4	\N	\N	\N	\N
540	65	61	Dot	\N	.	5	\N	\N	\N	\N
540	66	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
541	68	67	e_m	\N	!	1	\N	\N	\N	\N
541	69	67	Id	\N	Ascension	2	\N	\N	\N	\N
541	70	67	Id	\N	place	3	\N	\N	\N	\N
541	71	67	e_m	\N	!	4	\N	\N	\N	\N
541	67	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
542	72	74	sig_e	sig_eI	\N	1	\N	\N	\N	\N
542	73	72	Id	\N	sample	1	\N	\N	\N	\N
542	74	77	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
542	75	77	sig_e	sig_eI	\N	3	\N	\N	\N	\N
542	76	75	Id	\N	TV	1	\N	\N	\N	\N
542	77	79	sig_f	sig_f	\N	3	\N	\N	\N	\N
542	78	77	COLON	\N	:	2	\N	\N	\N	\N
542	79	84	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
20	193	192	l_p	\N	(	1	\N	1	0	\N
542	80	79	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
542	81	79	Id	\N	TIO2	2	\N	\N	\N	\N
542	82	79	PRIME	\N	prime	4	\N	\N	\N	\N
542	83	79	Dot	\N	.	5	\N	\N	\N	\N
20	195	192	r_p	\N	)	5	\N	1	0	\N
542	84	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
543	85	87	sig_e	sig_eI	\N	1	\N	\N	\N	\N
543	86	85	Id	\N	sample	1	\N	\N	\N	\N
543	87	90	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
16	146	152	Definition	Def-2	\N	1	\N	0	0	\N
543	88	90	sig_e	sig_eI	\N	3	\N	\N	\N	\N
16	147	146	DEFINITION	\N	Definition	1	\N	0	0	\N
16	148	146	Id	\N	IMPL_d	2	\N	0	0	\N
16	149	146	Id	\N	IMPLIES	3	\N	0	0	\N
16	150	146	COLON	\N	:	5	\N	0	0	\N
543	89	88	Id	\N	TV	1	\N	\N	\N	\N
543	90	92	sig_f	sig_f	\N	3	\N	\N	\N	\N
16	151	146	Dot	\N	.	7	\N	0	0	\N
16	152	\N	Statement	st-2	\N	\N	15	0	0	\N
543	91	90	COLON	\N	:	2	\N	\N	\N	\N
543	92	97	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
543	93	92	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
543	94	92	Id	\N	FEO	2	\N	\N	\N	\N
543	95	92	PRIME	\N	prime	4	\N	\N	\N	\N
543	96	92	Dot	\N	.	5	\N	\N	\N	\N
17	153	155	sig_e	sig_eI	\N	1	\N	\N	\N	\N
543	97	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
544	98	100	sig_e	sig_eI	\N	1	\N	\N	\N	\N
16	145	142	r_p	\N	)	4	\N	0	1	\N
16	1982	142	term	trmi	\N	1	9	0	1	77
16	1983	1982	Id	\N	OR	1	9	0	1	77
16	1984	142	TermList	#trml	\N	3	\N	0	1	\N
20	201	200	l_p	\N	(	1	\N	1	0	\N
20	187	208	Id_list_bch	#Id_list_bch	\N	4	\N	0	1	\N
20	184	187	Id_list_b	Id_list_b-1	\N	1	\N	0	1	\N
17	154	153	Id	\N	TV	1	\N	\N	\N	\N
17	155	160	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
17	156	155	sig_e	sig_eI	\N	2	\N	\N	\N	\N
17	157	156	Id	\N	TV	1	\N	\N	\N	\N
17	158	160	sig_e	sig_eI	\N	3	\N	\N	\N	\N
17	159	158	Id	\N	TV	1	\N	\N	\N	\N
17	160	162	sig_f	sig_f	\N	3	\N	\N	\N	\N
17	161	160	COLON	\N	:	2	\N	\N	\N	\N
17	162	166	Declaration	Dcl-5	\N	1	\N	\N	\N	\N
17	163	162	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
17	164	162	Id	\N	EQUIV	2	\N	\N	\N	\N
17	165	162	Dot	\N	.	4	\N	\N	\N	\N
17	166	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
18	168	167	Add	\N	Add	1	\N	\N	\N	\N
18	169	167	infix	\N	infix	2	\N	\N	\N	\N
18	170	167	String	\N	≡	3	\N	\N	\N	\N
18	171	167	to	\N	to	4	\N	\N	\N	\N
18	172	167	Id	\N	EQUIV	5	\N	\N	\N	\N
18	173	167	Dot	\N	.	6	\N	\N	\N	\N
18	167	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
19	175	174	Add	\N	Add	1	\N	\N	\N	\N
19	176	174	infix	\N	infix	2	\N	\N	\N	\N
19	177	174	String	\N	eqv	3	\N	\N	\N	\N
19	178	174	to	\N	to	4	\N	\N	\N	\N
19	179	174	Id	\N	EQUIV	5	\N	\N	\N	\N
19	180	174	Dot	\N	.	6	\N	\N	\N	\N
19	174	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
20	181	184	Id_list	#Id_list	\N	2	\N	0	1	\N
20	182	181	Id	\N	x	1	17	0	1	154
20	183	181	Id	\N	y	2	17	0	1	154
20	185	184	l_p	\N	(	1	\N	0	1	\N
20	186	184	r_p	\N	)	3	\N	0	1	\N
16	1979	136	term	trmi	\N	1	3	0	1	19
16	1980	1979	Id	\N	NOT	1	3	0	1	19
20	189	188	Id	\N	x	1	182	2	0	0
16	1981	136	TermList	#trml	\N	3	\N	0	1	\N
20	191	190	Id	\N	y	1	183	2	0	0
20	197	196	Id	\N	y	1	183	2	0	0
20	199	198	Id	\N	x	1	182	2	0	0
20	188	192	term	trmi	\N	2	17	2	0	154
20	190	192	term	trmi	\N	4	17	2	0	154
544	99	98	Id	\N	sample	1	\N	\N	\N	\N
544	100	103	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
544	101	103	sig_e	sig_eI	\N	3	\N	\N	\N	\N
544	102	101	Id	\N	TV	1	\N	\N	\N	\N
544	103	105	sig_f	sig_f	\N	3	\N	\N	\N	\N
544	104	103	COLON	\N	:	2	\N	\N	\N	\N
20	202	200	INFIX	\N	→	3	12	2	0	106
544	105	110	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
544	106	105	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
544	107	105	Id	\N	MNO	2	\N	\N	\N	\N
544	108	105	PRIME	\N	prime	4	\N	\N	\N	\N
544	109	105	Dot	\N	.	5	\N	\N	\N	\N
544	110	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
545	111	113	sig_e	sig_eI	\N	1	\N	\N	\N	\N
545	112	111	Id	\N	sample	1	\N	\N	\N	\N
545	113	116	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
545	114	116	sig_e	sig_eI	\N	3	\N	\N	\N	\N
545	115	114	Id	\N	TV	1	\N	\N	\N	\N
545	116	118	sig_f	sig_f	\N	3	\N	\N	\N	\N
545	117	116	COLON	\N	:	2	\N	\N	\N	\N
545	118	123	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
545	119	118	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
545	120	118	Id	\N	P2O5	2	\N	\N	\N	\N
545	121	118	PRIME	\N	prime	4	\N	\N	\N	\N
545	122	118	Dot	\N	.	5	\N	\N	\N	\N
545	123	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
546	124	126	sig_e	sig_eI	\N	1	\N	\N	\N	\N
546	125	124	Id	\N	sample	1	\N	\N	\N	\N
546	126	129	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
546	127	129	sig_e	sig_eI	\N	3	\N	\N	\N	\N
546	128	127	Id	\N	TV	1	\N	\N	\N	\N
546	129	131	sig_f	sig_f	\N	3	\N	\N	\N	\N
546	130	129	COLON	\N	:	2	\N	\N	\N	\N
546	131	136	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
546	132	131	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
546	133	131	Id	\N	CO2	2	\N	\N	\N	\N
546	134	131	PRIME	\N	prime	4	\N	\N	\N	\N
546	135	131	Dot	\N	.	5	\N	\N	\N	\N
546	136	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
547	137	139	sig_e	sig_eI	\N	1	\N	\N	\N	\N
547	138	137	Id	\N	sample	1	\N	\N	\N	\N
547	139	142	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
547	140	142	sig_e	sig_eI	\N	3	\N	\N	\N	\N
547	141	140	Id	\N	TV	1	\N	\N	\N	\N
547	142	144	sig_f	sig_f	\N	3	\N	\N	\N	\N
547	143	142	COLON	\N	:	2	\N	\N	\N	\N
547	144	149	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
547	145	144	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
547	146	144	Id	\N	H2Om	2	\N	\N	\N	\N
547	147	144	PRIME	\N	prime	4	\N	\N	\N	\N
547	148	144	Dot	\N	.	5	\N	\N	\N	\N
547	149	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
897	1	3	sig_e	sig_eI	\N	1	\N	\N	\N	\N
897	2	1	Id	\N	sample	1	\N	\N	\N	\N
897	3	6	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
897	4	6	sig_e	sig_eI	\N	3	\N	\N	\N	\N
897	5	4	Id	\N	TV	1	\N	\N	\N	\N
897	6	8	sig_f	sig_f	\N	3	\N	\N	\N	\N
897	7	6	COLON	\N	:	2	\N	\N	\N	\N
897	8	13	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
897	9	8	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
897	10	8	Id	\N	trachyandesite	2	\N	\N	\N	\N
897	11	8	PRIME	\N	prime	4	\N	\N	\N	\N
897	12	8	Dot	\N	.	5	\N	\N	\N	\N
897	13	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
185	218	217	e_m	\N	!	1	\N	\N	\N	\N
185	219	217	Id	\N	SAM30683	2	\N	\N	\N	\N
185	220	217	Id	\N	sample	3	\N	\N	\N	\N
185	221	217	e_m	\N	!	4	\N	\N	\N	\N
185	217	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
195	358	357	e_m	\N	!	1	\N	\N	\N	\N
195	359	357	Id	\N	SAM30684	2	\N	\N	\N	\N
195	360	357	Id	\N	sample	3	\N	\N	\N	\N
195	361	357	e_m	\N	!	4	\N	\N	\N	\N
195	357	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
215	637	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
20	214	\N	Statement	st-2	\N	\N	21	0	0	\N
20	203	200	r_p	\N	)	5	\N	1	0	\N
20	205	204	l_p	\N	(	1	\N	1	0	\N
20	207	204	r_p	\N	)	5	\N	1	0	\N
20	208	214	Definition	Def-2	\N	1	\N	0	0	\N
20	209	208	DEFINITION	\N	Definition	1	\N	0	0	\N
20	210	208	Id	\N	EQV_d	2	\N	0	0	\N
20	211	208	Id	\N	EQUIV	3	\N	0	0	\N
20	212	208	COLON	\N	:	5	\N	0	0	\N
20	213	208	Dot	\N	.	7	\N	0	0	\N
20	196	200	term	trmi	\N	2	17	2	0	154
20	198	200	term	trmi	\N	4	17	2	0	154
20	194	192	INFIX	\N	→	3	12	2	0	106
20	192	204	term	trmin	\N	2	12	2	0	105
20	200	204	term	trmin	\N	4	12	2	0	105
20	206	204	INFIX	\N	∧	3	6	2	0	48
20	204	208	term	trmin	\N	6	6	2	0	47
205	498	497	e_m	\N	!	1	\N	\N	\N	\N
205	499	497	Id	\N	SAM30685	2	\N	\N	\N	\N
205	500	497	Id	\N	sample	3	\N	\N	\N	\N
205	501	497	e_m	\N	!	4	\N	\N	\N	\N
205	497	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
215	638	637	e_m	\N	!	1	\N	\N	\N	\N
215	639	637	Id	\N	SAM30686	2	\N	\N	\N	\N
215	640	637	Id	\N	sample	3	\N	\N	\N	\N
215	641	637	e_m	\N	!	4	\N	\N	\N	\N
225	778	777	e_m	\N	!	1	\N	\N	\N	\N
225	779	777	Id	\N	SAM30687	2	\N	\N	\N	\N
225	780	777	Id	\N	sample	3	\N	\N	\N	\N
225	781	777	e_m	\N	!	4	\N	\N	\N	\N
225	777	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
235	918	917	e_m	\N	!	1	\N	\N	\N	\N
235	919	917	Id	\N	SAM30688	2	\N	\N	\N	\N
235	920	917	Id	\N	sample	3	\N	\N	\N	\N
235	921	917	e_m	\N	!	4	\N	\N	\N	\N
235	917	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
245	1058	1057	e_m	\N	!	1	\N	\N	\N	\N
245	1059	1057	Id	\N	SAM30689	2	\N	\N	\N	\N
245	1060	1057	Id	\N	sample	3	\N	\N	\N	\N
245	1061	1057	e_m	\N	!	4	\N	\N	\N	\N
245	1057	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
255	1198	1197	e_m	\N	!	1	\N	\N	\N	\N
255	1199	1197	Id	\N	SAM30690	2	\N	\N	\N	\N
255	1200	1197	Id	\N	sample	3	\N	\N	\N	\N
255	1201	1197	e_m	\N	!	4	\N	\N	\N	\N
255	1197	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
265	1338	1337	e_m	\N	!	1	\N	\N	\N	\N
265	1339	1337	Id	\N	SAM30691	2	\N	\N	\N	\N
265	1340	1337	Id	\N	sample	3	\N	\N	\N	\N
265	1341	1337	e_m	\N	!	4	\N	\N	\N	\N
265	1337	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
275	1478	1477	e_m	\N	!	1	\N	\N	\N	\N
275	1479	1477	Id	\N	SAM30692	2	\N	\N	\N	\N
275	1480	1477	Id	\N	sample	3	\N	\N	\N	\N
275	1481	1477	e_m	\N	!	4	\N	\N	\N	\N
275	1477	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
21	1997	1996	l_p	\N	(	2	\N	2	0	\N
21	1999	1996	r_p	\N	)	4	\N	2	0	\N
21	2002	1993	term	trmf	\N	-2	9	2	0	76
21	2003	2002	l_p	\N	(	2	\N	2	0	\N
21	2005	2002	r_p	\N	)	4	\N	2	0	\N
21	3839	1996	term	trmi	\N	1	3	2	0	19
21	3840	3839	Id	\N	NOT	1	3	2	0	19
21	3841	1996	TermList	#trml	\N	3	\N	2	0	\N
21	3842	2002	term	trmi	\N	1	9	2	0	77
21	3847	3844	term	trmi	\N	-1	17	0	0	154
21	3848	3847	Id	\N	y	1	183	0	0	0
21	181	184	Id_list	#Id_list	\N	2	\N	0	0	\N
21	182	181	Id	\N	x	1	17	0	0	154
21	183	181	Id	\N	y	2	17	0	0	154
21	184	187	Id_list_b	Id_list_b-1	\N	1	\N	0	0	\N
21	186	184	r_p	\N	)	3	\N	0	0	\N
21	187	208	Id_list_bch	#Id_list_bch	\N	4	\N	0	0	\N
22	216	215	e_m	\N	!	1	\N	\N	\N	\N
21	5694	3851	term	trmi	\N	1	3	2	0	19
21	5695	5694	Id	\N	NOT	1	3	2	0	19
21	5696	3851	TermList	#trml	\N	3	\N	2	0	\N
21	5697	3857	term	trmi	\N	1	9	2	0	77
21	5698	5697	Id	\N	OR	1	9	2	0	77
21	5699	3857	TermList	#trml	\N	3	\N	2	0	\N
21	5700	5696	term	trmi	\N	-1	17	0	0	154
21	5701	5700	Id	\N	y	1	183	0	0	0
21	1996	3844	term	trmf	\N	-2	3	2	0	18
21	3851	5699	term	trmf	\N	-2	3	2	0	18
21	3852	3851	l_p	\N	(	2	\N	2	0	\N
21	3854	3851	r_p	\N	)	4	\N	2	0	\N
21	3857	1993	term	trmf	\N	-1	9	2	0	76
21	3858	3857	l_p	\N	(	2	\N	2	0	\N
21	3860	3857	r_p	\N	)	4	\N	2	0	\N
21	185	184	l_p	\N	(	1	\N	0	0	\N
22	217	215	Id	\N	True	2	\N	\N	\N	\N
22	218	215	Id	\N	TV	3	\N	\N	\N	\N
21	3843	3842	Id	\N	OR	1	9	2	0	77
21	3844	2002	TermList	#trml	\N	3	\N	2	0	\N
21	3845	3841	term	trmi	\N	-1	17	0	0	154
21	3846	3845	Id	\N	x	1	182	0	0	0
22	219	215	e_m	\N	!	4	\N	\N	\N	\N
22	215	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
21	1991	204	term	trmi	\N	1	6	0	0	48
21	1993	204	TermList	#trml	\N	3	\N	0	0	\N
23	221	220	e_m	\N	!	1	\N	\N	\N	\N
21	204	208	term	trmf	\N	6	6	0	0	47
21	205	204	l_p	\N	(	2	\N	0	0	\N
21	207	204	r_p	\N	)	4	\N	0	0	\N
21	208	214	Definition	Def-2	\N	1	\N	0	0	\N
21	209	208	DEFINITION	\N	Definition	1	\N	0	0	\N
21	210	208	Id	\N	EQV_d	2	\N	0	0	\N
21	211	208	Id	\N	EQUIV	3	\N	0	0	\N
21	212	208	COLON	\N	:	5	\N	0	0	\N
21	213	208	Dot	\N	.	7	\N	0	0	\N
21	214	\N	Statement	st-2	\N	\N	20	0	0	\N
21	5702	5699	term	trmi	\N	-1	17	0	0	154
21	5703	5702	Id	\N	x	1	182	0	0	0
23	222	220	Id	\N	False	2	\N	\N	\N	\N
23	223	220	Id	\N	TV	3	\N	\N	\N	\N
23	224	220	e_m	\N	!	4	\N	\N	\N	\N
23	220	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
24	226	225	String	\N	String DAD	1	\N	\N	\N	\N
24	225	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
25	228	227	String	\N	sort of strings without double quote (DQ). То что в тексте они в DQ есть соглашение СЕРИАЛИЗАЦИИ;-)	1	\N	\N	\N	\N
25	227	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
21	1992	1991	Id	\N	AND	1	6	0	0	48
26	229	235	Declaration	Dcl-2	\N	1	\N	\N	\N	\N
26	230	229	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
26	231	229	Id	\N	S	2	\N	\N	\N	\N
26	232	229	sort	\N	sort	3	\N	\N	\N	\N
26	233	229	String	\N	[^DQ]*	4	\N	\N	\N	\N
26	234	229	Dot	\N	.	5	\N	\N	\N	\N
26	235	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
27	236	238	sig_e	sig_eI	\N	1	\N	\N	\N	\N
27	237	236	Id	\N	S	1	\N	\N	\N	\N
27	238	243	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
27	239	238	sig_e	sig_eI	\N	2	\N	\N	\N	\N
27	240	239	Id	\N	S	1	\N	\N	\N	\N
27	241	243	sig_e	sig_eI	\N	3	\N	\N	\N	\N
27	242	241	Id	\N	TV	1	\N	\N	\N	\N
27	243	245	sig_f	sig_f	\N	3	\N	\N	\N	\N
27	244	243	COLON	\N	:	2	\N	\N	\N	\N
27	245	251	Declaration	Dcl-6	\N	1	\N	\N	\N	\N
27	246	245	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
27	247	245	Id	\N	S_EQ	2	\N	\N	\N	\N
27	248	245	PRIME	\N	prime	4	\N	\N	\N	\N
27	249	245	Id	\N	fm_strcmp	5	\N	\N	\N	\N
27	250	245	Dot	\N	.	6	\N	\N	\N	\N
27	251	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
28	253	252	Add	\N	Add	1	\N	\N	\N	\N
28	254	252	infix	\N	infix	2	\N	\N	\N	\N
28	255	252	String	\N	=	3	\N	\N	\N	\N
28	256	252	to	\N	to	4	\N	\N	\N	\N
28	257	252	Id	\N	S_EQ	5	\N	\N	\N	\N
28	258	252	Dot	\N	.	6	\N	\N	\N	\N
28	252	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
29	260	259	String	\N	Number DAD	1	\N	\N	\N	\N
29	259	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
30	262	261	String	\N	Числа	1	\N	\N	\N	\N
30	261	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
31	263	269	Declaration	Dcl-2	\N	1	\N	\N	\N	\N
31	264	263	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
31	265	263	Id	\N	R	2	\N	\N	\N	\N
31	266	263	sort	\N	sort	3	\N	\N	\N	\N
31	267	263	String	\N	[-+]?{DIGIT}+({Dot}{DIGIT}+)?	4	\N	\N	\N	\N
31	268	263	Dot	\N	.	5	\N	\N	\N	\N
31	269	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
32	271	270	String	\N	Объявления функций арифметики десятичных рациональных чисел	1	\N	\N	\N	\N
32	270	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
33	273	272	String	\N	--первичные	1	\N	\N	\N	\N
33	272	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
34	274	276	sig_e	sig_eI	\N	1	\N	\N	\N	\N
34	275	274	Id	\N	R	1	\N	\N	\N	\N
34	276	281	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
34	277	276	sig_e	sig_eI	\N	2	\N	\N	\N	\N
34	278	277	Id	\N	R	1	\N	\N	\N	\N
34	279	281	sig_e	sig_eI	\N	3	\N	\N	\N	\N
34	280	279	Id	\N	TV	1	\N	\N	\N	\N
34	281	283	sig_f	sig_f	\N	3	\N	\N	\N	\N
34	282	281	COLON	\N	:	2	\N	\N	\N	\N
34	283	289	Declaration	Dcl-6	\N	1	\N	\N	\N	\N
34	284	283	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
34	285	283	Id	\N	R_EQ	2	\N	\N	\N	\N
34	286	283	PRIME	\N	prime	4	\N	\N	\N	\N
34	287	283	Id	\N	fm_req	5	\N	\N	\N	\N
34	288	283	Dot	\N	.	6	\N	\N	\N	\N
34	289	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
35	291	290	Add	\N	Add	1	\N	\N	\N	\N
35	292	290	infix	\N	infix	2	\N	\N	\N	\N
35	293	290	String	\N	=	3	\N	\N	\N	\N
35	294	290	to	\N	to	4	\N	\N	\N	\N
35	295	290	Id	\N	R_EQ	5	\N	\N	\N	\N
35	296	290	Dot	\N	.	6	\N	\N	\N	\N
35	290	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
36	297	299	sig_e	sig_eI	\N	1	\N	\N	\N	\N
36	298	297	Id	\N	R	1	\N	\N	\N	\N
36	299	304	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
36	300	299	sig_e	sig_eI	\N	2	\N	\N	\N	\N
36	301	300	Id	\N	R	1	\N	\N	\N	\N
36	302	304	sig_e	sig_eI	\N	3	\N	\N	\N	\N
36	303	302	Id	\N	TV	1	\N	\N	\N	\N
36	304	306	sig_f	sig_f	\N	3	\N	\N	\N	\N
36	305	304	COLON	\N	:	2	\N	\N	\N	\N
36	306	312	Declaration	Dcl-6	\N	1	\N	\N	\N	\N
36	307	306	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
36	308	306	Id	\N	R_LT	2	\N	\N	\N	\N
36	309	306	PRIME	\N	prime	4	\N	\N	\N	\N
36	310	306	Id	\N	fm_rlt	5	\N	\N	\N	\N
36	311	306	Dot	\N	.	6	\N	\N	\N	\N
36	312	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
37	314	313	Add	\N	Add	1	\N	\N	\N	\N
37	315	313	infix	\N	infix	2	\N	\N	\N	\N
37	316	313	String	\N	<	3	\N	\N	\N	\N
37	317	313	to	\N	to	4	\N	\N	\N	\N
37	318	313	Id	\N	R_LT	5	\N	\N	\N	\N
37	319	313	Dot	\N	.	6	\N	\N	\N	\N
37	313	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
38	320	322	sig_e	sig_eI	\N	1	\N	\N	\N	\N
38	321	320	Id	\N	R	1	\N	\N	\N	\N
38	322	327	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
38	323	322	sig_e	sig_eI	\N	2	\N	\N	\N	\N
38	324	323	Id	\N	R	1	\N	\N	\N	\N
38	325	327	sig_e	sig_eI	\N	3	\N	\N	\N	\N
38	326	325	Id	\N	R	1	\N	\N	\N	\N
38	327	329	sig_f	sig_f	\N	3	\N	\N	\N	\N
38	328	327	COLON	\N	:	2	\N	\N	\N	\N
38	329	335	Declaration	Dcl-6	\N	1	\N	\N	\N	\N
38	330	329	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
38	331	329	Id	\N	R_PLUS	2	\N	\N	\N	\N
38	332	329	PRIME	\N	prime	4	\N	\N	\N	\N
38	333	329	Id	\N	fm_radd	5	\N	\N	\N	\N
38	334	329	Dot	\N	.	6	\N	\N	\N	\N
38	335	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
39	337	336	Add	\N	Add	1	\N	\N	\N	\N
39	338	336	infix	\N	infix	2	\N	\N	\N	\N
39	339	336	String	\N	+	3	\N	\N	\N	\N
39	340	336	to	\N	to	4	\N	\N	\N	\N
39	341	336	Id	\N	R_PLUS	5	\N	\N	\N	\N
39	342	336	Dot	\N	.	6	\N	\N	\N	\N
39	336	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
40	343	345	sig_e	sig_eI	\N	1	\N	\N	\N	\N
40	344	343	Id	\N	R	1	\N	\N	\N	\N
40	345	350	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
40	346	345	sig_e	sig_eI	\N	2	\N	\N	\N	\N
40	347	346	Id	\N	R	1	\N	\N	\N	\N
40	348	350	sig_e	sig_eI	\N	3	\N	\N	\N	\N
40	349	348	Id	\N	R	1	\N	\N	\N	\N
40	350	352	sig_f	sig_f	\N	3	\N	\N	\N	\N
40	351	350	COLON	\N	:	2	\N	\N	\N	\N
40	352	358	Declaration	Dcl-6	\N	1	\N	\N	\N	\N
40	353	352	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
40	354	352	Id	\N	R_MINUS	2	\N	\N	\N	\N
40	355	352	PRIME	\N	prime	4	\N	\N	\N	\N
40	356	352	Id	\N	fm_rminus	5	\N	\N	\N	\N
40	357	352	Dot	\N	.	6	\N	\N	\N	\N
40	358	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
41	360	359	Add	\N	Add	1	\N	\N	\N	\N
41	361	359	infix	\N	infix	2	\N	\N	\N	\N
41	362	359	String	\N	-	3	\N	\N	\N	\N
41	363	359	to	\N	to	4	\N	\N	\N	\N
41	364	359	Id	\N	R_MINUS	5	\N	\N	\N	\N
41	365	359	Dot	\N	.	6	\N	\N	\N	\N
41	359	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
42	366	368	sig_e	sig_eI	\N	1	\N	\N	\N	\N
42	367	366	Id	\N	R	1	\N	\N	\N	\N
42	368	373	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
42	369	368	sig_e	sig_eI	\N	2	\N	\N	\N	\N
42	370	369	Id	\N	R	1	\N	\N	\N	\N
42	371	373	sig_e	sig_eI	\N	3	\N	\N	\N	\N
42	372	371	Id	\N	R	1	\N	\N	\N	\N
42	373	375	sig_f	sig_f	\N	3	\N	\N	\N	\N
42	374	373	COLON	\N	:	2	\N	\N	\N	\N
42	375	381	Declaration	Dcl-6	\N	1	\N	\N	\N	\N
42	376	375	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
42	377	375	Id	\N	R_MULTIPLY	2	\N	\N	\N	\N
42	378	375	PRIME	\N	prime	4	\N	\N	\N	\N
42	379	375	Id	\N	fm_rmult	5	\N	\N	\N	\N
42	380	375	Dot	\N	.	6	\N	\N	\N	\N
42	381	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
43	383	382	Add	\N	Add	1	\N	\N	\N	\N
43	384	382	infix	\N	infix	2	\N	\N	\N	\N
43	385	382	String	\N	*	3	\N	\N	\N	\N
43	386	382	to	\N	to	4	\N	\N	\N	\N
43	387	382	Id	\N	R_MULTIPLY	5	\N	\N	\N	\N
43	388	382	Dot	\N	.	6	\N	\N	\N	\N
43	382	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
44	389	391	sig_e	sig_eI	\N	1	\N	\N	\N	\N
44	390	389	Id	\N	R	1	\N	\N	\N	\N
44	391	396	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
44	392	391	sig_e	sig_eI	\N	2	\N	\N	\N	\N
44	393	392	Id	\N	R	1	\N	\N	\N	\N
44	394	396	sig_e	sig_eI	\N	3	\N	\N	\N	\N
44	395	394	Id	\N	R	1	\N	\N	\N	\N
44	396	398	sig_f	sig_f	\N	3	\N	\N	\N	\N
44	397	396	COLON	\N	:	2	\N	\N	\N	\N
44	398	404	Declaration	Dcl-6	\N	1	\N	\N	\N	\N
44	399	398	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
44	400	398	Id	\N	R_DEVIDE	2	\N	\N	\N	\N
44	401	398	PRIME	\N	prime	4	\N	\N	\N	\N
44	402	398	Id	\N	fm_rdev	5	\N	\N	\N	\N
44	403	398	Dot	\N	.	6	\N	\N	\N	\N
44	404	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
45	406	405	Add	\N	Add	1	\N	\N	\N	\N
45	407	405	infix	\N	infix	2	\N	\N	\N	\N
45	408	405	String	\N	/	3	\N	\N	\N	\N
45	409	405	to	\N	to	4	\N	\N	\N	\N
45	410	405	Id	\N	R_DEVIDE	5	\N	\N	\N	\N
45	411	405	Dot	\N	.	6	\N	\N	\N	\N
45	405	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
46	413	412	String	\N	--могли бы иметь определения	1	\N	\N	\N	\N
46	412	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
47	414	416	sig_e	sig_eI	\N	1	\N	\N	\N	\N
47	415	414	Id	\N	R	1	\N	\N	\N	\N
47	416	421	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
47	417	416	sig_e	sig_eI	\N	2	\N	\N	\N	\N
47	418	417	Id	\N	R	1	\N	\N	\N	\N
47	419	421	sig_e	sig_eI	\N	3	\N	\N	\N	\N
47	420	419	Id	\N	TV	1	\N	\N	\N	\N
47	421	423	sig_f	sig_f	\N	3	\N	\N	\N	\N
47	422	421	COLON	\N	:	2	\N	\N	\N	\N
47	423	429	Declaration	Dcl-6	\N	1	\N	\N	\N	\N
47	424	423	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
47	425	423	Id	\N	R_GT	2	\N	\N	\N	\N
47	426	423	PRIME	\N	prime	4	\N	\N	\N	\N
47	427	423	Id	\N	fm_rgt	5	\N	\N	\N	\N
47	428	423	Dot	\N	.	6	\N	\N	\N	\N
47	429	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
48	431	430	Add	\N	Add	1	\N	\N	\N	\N
48	432	430	infix	\N	infix	2	\N	\N	\N	\N
48	433	430	String	\N	>	3	\N	\N	\N	\N
48	434	430	to	\N	to	4	\N	\N	\N	\N
48	435	430	Id	\N	R_GT	5	\N	\N	\N	\N
48	436	430	Dot	\N	.	6	\N	\N	\N	\N
48	430	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
49	437	439	sig_e	sig_eI	\N	1	\N	\N	\N	\N
49	438	437	Id	\N	R	1	\N	\N	\N	\N
49	439	444	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
49	440	439	sig_e	sig_eI	\N	2	\N	\N	\N	\N
49	441	440	Id	\N	R	1	\N	\N	\N	\N
49	442	444	sig_e	sig_eI	\N	3	\N	\N	\N	\N
49	443	442	Id	\N	TV	1	\N	\N	\N	\N
49	444	446	sig_f	sig_f	\N	3	\N	\N	\N	\N
49	445	444	COLON	\N	:	2	\N	\N	\N	\N
49	446	452	Declaration	Dcl-6	\N	1	\N	\N	\N	\N
49	447	446	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
49	448	446	Id	\N	R_LE	2	\N	\N	\N	\N
49	449	446	PRIME	\N	prime	4	\N	\N	\N	\N
49	450	446	Id	\N	fm_rle	5	\N	\N	\N	\N
49	451	446	Dot	\N	.	6	\N	\N	\N	\N
49	452	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
50	454	453	Add	\N	Add	1	\N	\N	\N	\N
50	455	453	infix	\N	infix	2	\N	\N	\N	\N
50	456	453	String	\N	≤	3	\N	\N	\N	\N
50	457	453	to	\N	to	4	\N	\N	\N	\N
50	458	453	Id	\N	R_LE	5	\N	\N	\N	\N
50	459	453	Dot	\N	.	6	\N	\N	\N	\N
50	453	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
51	460	462	sig_e	sig_eI	\N	1	\N	\N	\N	\N
51	461	460	Id	\N	R	1	\N	\N	\N	\N
51	462	467	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
51	463	462	sig_e	sig_eI	\N	2	\N	\N	\N	\N
51	464	463	Id	\N	R	1	\N	\N	\N	\N
51	465	467	sig_e	sig_eI	\N	3	\N	\N	\N	\N
51	466	465	Id	\N	TV	1	\N	\N	\N	\N
51	467	469	sig_f	sig_f	\N	3	\N	\N	\N	\N
51	468	467	COLON	\N	:	2	\N	\N	\N	\N
51	469	475	Declaration	Dcl-6	\N	1	\N	\N	\N	\N
51	470	469	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
51	471	469	Id	\N	R_GE	2	\N	\N	\N	\N
51	472	469	PRIME	\N	prime	4	\N	\N	\N	\N
51	473	469	Id	\N	fm_rge	5	\N	\N	\N	\N
51	474	469	Dot	\N	.	6	\N	\N	\N	\N
51	475	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
52	477	476	Add	\N	Add	1	\N	\N	\N	\N
52	478	476	infix	\N	infix	2	\N	\N	\N	\N
52	479	476	String	\N	≥	3	\N	\N	\N	\N
52	480	476	to	\N	to	4	\N	\N	\N	\N
52	481	476	Id	\N	R_GE	5	\N	\N	\N	\N
52	482	476	Dot	\N	.	6	\N	\N	\N	\N
52	476	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
53	484	483	String	\N	БД Проба DAD	1	\N	\N	\N	\N
53	483	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
54	486	485	String	\N	сорта с равенством	1	\N	\N	\N	\N
54	485	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
55	487	492	Declaration	Dcl-1	\N	1	\N	\N	\N	\N
55	488	487	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
55	489	487	Id	\N	publication	2	\N	\N	\N	\N
55	490	487	sort	\N	sort	3	\N	\N	\N	\N
55	491	487	Dot	\N	.	4	\N	\N	\N	\N
55	492	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
56	493	495	sig_e	sig_eI	\N	1	\N	\N	\N	\N
56	494	493	Id	\N	publication	1	\N	\N	\N	\N
56	495	500	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
56	496	495	sig_e	sig_eI	\N	2	\N	\N	\N	\N
56	497	496	Id	\N	publication	1	\N	\N	\N	\N
56	498	500	sig_e	sig_eI	\N	3	\N	\N	\N	\N
56	499	498	Id	\N	TV	1	\N	\N	\N	\N
56	500	502	sig_f	sig_f	\N	3	\N	\N	\N	\N
56	501	500	COLON	\N	:	2	\N	\N	\N	\N
56	502	508	Declaration	Dcl-6	\N	1	\N	\N	\N	\N
56	503	502	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
56	504	502	Id	\N	EQU_publication	2	\N	\N	\N	\N
56	505	502	PRIME	\N	prime	4	\N	\N	\N	\N
56	506	502	Id	\N	fm_strcmp	5	\N	\N	\N	\N
56	507	502	Dot	\N	.	6	\N	\N	\N	\N
56	508	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
57	510	509	Add	\N	Add	1	\N	\N	\N	\N
57	511	509	infix	\N	infix	2	\N	\N	\N	\N
57	512	509	String	\N	=	3	\N	\N	\N	\N
57	513	509	to	\N	to	4	\N	\N	\N	\N
57	514	509	Id	\N	EQU_publication	5	\N	\N	\N	\N
57	515	509	Dot	\N	.	6	\N	\N	\N	\N
57	509	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
58	516	521	Declaration	Dcl-1	\N	1	\N	\N	\N	\N
58	517	516	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
58	518	516	Id	\N	sample	2	\N	\N	\N	\N
58	519	516	sort	\N	sort	3	\N	\N	\N	\N
58	520	516	Dot	\N	.	4	\N	\N	\N	\N
58	521	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
59	522	524	sig_e	sig_eI	\N	1	\N	\N	\N	\N
59	523	522	Id	\N	sample	1	\N	\N	\N	\N
59	524	529	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
59	525	524	sig_e	sig_eI	\N	2	\N	\N	\N	\N
59	526	525	Id	\N	sample	1	\N	\N	\N	\N
59	527	529	sig_e	sig_eI	\N	3	\N	\N	\N	\N
59	528	527	Id	\N	TV	1	\N	\N	\N	\N
59	529	531	sig_f	sig_f	\N	3	\N	\N	\N	\N
59	530	529	COLON	\N	:	2	\N	\N	\N	\N
59	531	537	Declaration	Dcl-6	\N	1	\N	\N	\N	\N
59	532	531	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
59	533	531	Id	\N	EQU_sample	2	\N	\N	\N	\N
59	534	531	PRIME	\N	prime	4	\N	\N	\N	\N
59	535	531	Id	\N	fm_strcmp	5	\N	\N	\N	\N
59	536	531	Dot	\N	.	6	\N	\N	\N	\N
59	537	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
60	539	538	Add	\N	Add	1	\N	\N	\N	\N
60	540	538	infix	\N	infix	2	\N	\N	\N	\N
60	541	538	String	\N	=	3	\N	\N	\N	\N
60	542	538	to	\N	to	4	\N	\N	\N	\N
60	543	538	Id	\N	EQU_sample	5	\N	\N	\N	\N
60	544	538	Dot	\N	.	6	\N	\N	\N	\N
60	538	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
61	545	550	Declaration	Dcl-1	\N	1	\N	\N	\N	\N
61	546	545	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
61	547	545	Id	\N	place	2	\N	\N	\N	\N
61	548	545	sort	\N	sort	3	\N	\N	\N	\N
61	549	545	Dot	\N	.	4	\N	\N	\N	\N
61	550	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
62	551	553	sig_e	sig_eI	\N	1	\N	\N	\N	\N
62	552	551	Id	\N	place	1	\N	\N	\N	\N
62	553	558	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
62	554	553	sig_e	sig_eI	\N	2	\N	\N	\N	\N
62	555	554	Id	\N	place	1	\N	\N	\N	\N
62	556	558	sig_e	sig_eI	\N	3	\N	\N	\N	\N
62	557	556	Id	\N	TV	1	\N	\N	\N	\N
62	558	560	sig_f	sig_f	\N	3	\N	\N	\N	\N
62	559	558	COLON	\N	:	2	\N	\N	\N	\N
62	560	566	Declaration	Dcl-6	\N	1	\N	\N	\N	\N
62	561	560	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
62	562	560	Id	\N	EQU_place	2	\N	\N	\N	\N
62	563	560	PRIME	\N	prime	4	\N	\N	\N	\N
62	564	560	Id	\N	fm_strcmp	5	\N	\N	\N	\N
62	565	560	Dot	\N	.	6	\N	\N	\N	\N
62	566	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
63	568	567	Add	\N	Add	1	\N	\N	\N	\N
63	569	567	infix	\N	infix	2	\N	\N	\N	\N
63	570	567	String	\N	=	3	\N	\N	\N	\N
63	571	567	to	\N	to	4	\N	\N	\N	\N
63	572	567	Id	\N	EQU_place	5	\N	\N	\N	\N
63	573	567	Dot	\N	.	6	\N	\N	\N	\N
63	567	\N	Statement	st-4	\N	\N	\N	\N	\N	\N
64	575	574	String	\N	атрибуты статьи	1	\N	\N	\N	\N
64	574	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
65	576	578	sig_e	sig_eI	\N	1	\N	\N	\N	\N
65	577	576	Id	\N	publication	1	\N	\N	\N	\N
65	578	581	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
65	579	581	sig_e	sig_eI	\N	3	\N	\N	\N	\N
65	580	579	Id	\N	S	1	\N	\N	\N	\N
65	581	583	sig_f	sig_f	\N	3	\N	\N	\N	\N
65	582	581	COLON	\N	:	2	\N	\N	\N	\N
65	583	588	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
65	584	583	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
65	585	583	Id	\N	title	2	\N	\N	\N	\N
65	586	583	PRIME	\N	prime	4	\N	\N	\N	\N
65	587	583	Dot	\N	.	5	\N	\N	\N	\N
65	588	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
66	589	591	sig_e	sig_eI	\N	1	\N	\N	\N	\N
66	590	589	Id	\N	publication	1	\N	\N	\N	\N
66	591	594	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
66	592	594	sig_e	sig_eI	\N	3	\N	\N	\N	\N
66	593	592	Id	\N	S	1	\N	\N	\N	\N
66	594	596	sig_f	sig_f	\N	3	\N	\N	\N	\N
66	595	594	COLON	\N	:	2	\N	\N	\N	\N
66	596	601	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
66	597	596	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
66	598	596	Id	\N	journal_reference	2	\N	\N	\N	\N
66	599	596	PRIME	\N	prime	4	\N	\N	\N	\N
66	600	596	Dot	\N	.	5	\N	\N	\N	\N
66	601	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
67	602	604	sig_e	sig_eI	\N	1	\N	\N	\N	\N
67	603	602	Id	\N	publication	1	\N	\N	\N	\N
67	604	607	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
67	605	607	sig_e	sig_eI	\N	3	\N	\N	\N	\N
67	606	605	Id	\N	R	1	\N	\N	\N	\N
67	607	609	sig_f	sig_f	\N	3	\N	\N	\N	\N
67	608	607	COLON	\N	:	2	\N	\N	\N	\N
67	609	614	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
67	610	609	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
67	611	609	Id	\N	year	2	\N	\N	\N	\N
67	612	609	PRIME	\N	prime	4	\N	\N	\N	\N
67	613	609	Dot	\N	.	5	\N	\N	\N	\N
67	614	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
68	615	617	sig_e	sig_eI	\N	1	\N	\N	\N	\N
68	616	615	Id	\N	publication	1	\N	\N	\N	\N
68	617	620	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
68	618	620	sig_e	sig_eI	\N	3	\N	\N	\N	\N
68	619	618	Id	\N	R	1	\N	\N	\N	\N
68	620	622	sig_f	sig_f	\N	3	\N	\N	\N	\N
68	621	620	COLON	\N	:	2	\N	\N	\N	\N
68	622	627	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
68	623	622	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
68	624	622	Id	\N	first_page	2	\N	\N	\N	\N
68	625	622	PRIME	\N	prime	4	\N	\N	\N	\N
68	626	622	Dot	\N	.	5	\N	\N	\N	\N
68	627	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
69	628	630	sig_e	sig_eI	\N	1	\N	\N	\N	\N
69	629	628	Id	\N	publication	1	\N	\N	\N	\N
69	630	633	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
69	631	633	sig_e	sig_eI	\N	3	\N	\N	\N	\N
69	632	631	Id	\N	R	1	\N	\N	\N	\N
69	633	635	sig_f	sig_f	\N	3	\N	\N	\N	\N
69	634	633	COLON	\N	:	2	\N	\N	\N	\N
69	635	640	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
69	636	635	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
69	637	635	Id	\N	last_page	2	\N	\N	\N	\N
69	638	635	PRIME	\N	prime	4	\N	\N	\N	\N
69	639	635	Dot	\N	.	5	\N	\N	\N	\N
69	640	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
70	642	641	String	\N	атрибуты образца	1	\N	\N	\N	\N
70	641	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
71	643	645	sig_e	sig_eI	\N	1	\N	\N	\N	\N
71	644	643	Id	\N	sample	1	\N	\N	\N	\N
71	645	648	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
71	646	648	sig_e	sig_eI	\N	3	\N	\N	\N	\N
71	647	646	Id	\N	S	1	\N	\N	\N	\N
71	648	650	sig_f	sig_f	\N	3	\N	\N	\N	\N
71	649	648	COLON	\N	:	2	\N	\N	\N	\N
71	650	655	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
71	651	650	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
71	652	650	Id	\N	authorial_number	2	\N	\N	\N	\N
71	653	650	PRIME	\N	prime	4	\N	\N	\N	\N
71	654	650	Dot	\N	.	5	\N	\N	\N	\N
71	655	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
72	656	658	sig_e	sig_eI	\N	1	\N	\N	\N	\N
72	657	656	Id	\N	sample	1	\N	\N	\N	\N
72	658	661	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
72	659	661	sig_e	sig_eI	\N	3	\N	\N	\N	\N
72	660	659	Id	\N	S	1	\N	\N	\N	\N
72	661	663	sig_f	sig_f	\N	3	\N	\N	\N	\N
72	662	661	COLON	\N	:	2	\N	\N	\N	\N
72	663	668	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
72	664	663	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
72	665	663	Id	\N	reference	2	\N	\N	\N	\N
72	666	663	PRIME	\N	prime	4	\N	\N	\N	\N
72	667	663	Dot	\N	.	5	\N	\N	\N	\N
72	668	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
73	670	669	String	\N	связи образца	1	\N	\N	\N	\N
73	669	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
74	671	673	sig_e	sig_eI	\N	1	\N	\N	\N	\N
74	672	671	Id	\N	sample	1	\N	\N	\N	\N
74	673	676	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
74	674	676	sig_e	sig_eI	\N	3	\N	\N	\N	\N
74	675	674	Id	\N	publication	1	\N	\N	\N	\N
74	676	678	sig_f	sig_f	\N	3	\N	\N	\N	\N
74	677	676	COLON	\N	:	2	\N	\N	\N	\N
74	678	683	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
74	679	678	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
74	680	678	Id	\N	described	2	\N	\N	\N	\N
74	681	678	PRIME	\N	prime	4	\N	\N	\N	\N
74	682	678	Dot	\N	.	5	\N	\N	\N	\N
74	683	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
75	684	686	sig_e	sig_eI	\N	1	\N	\N	\N	\N
75	685	684	Id	\N	sample	1	\N	\N	\N	\N
75	686	689	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
75	687	689	sig_e	sig_eI	\N	3	\N	\N	\N	\N
75	688	687	Id	\N	place	1	\N	\N	\N	\N
75	689	691	sig_f	sig_f	\N	3	\N	\N	\N	\N
75	690	689	COLON	\N	:	2	\N	\N	\N	\N
75	691	696	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
75	692	691	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
75	693	691	Id	\N	gathering_place	2	\N	\N	\N	\N
75	694	691	PRIME	\N	prime	4	\N	\N	\N	\N
75	695	691	Dot	\N	.	5	\N	\N	\N	\N
75	696	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
76	698	697	String	\N	атрибуты места	1	\N	\N	\N	\N
76	697	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
77	699	701	sig_e	sig_eI	\N	1	\N	\N	\N	\N
77	700	699	Id	\N	place	1	\N	\N	\N	\N
77	701	704	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
77	702	704	sig_e	sig_eI	\N	3	\N	\N	\N	\N
77	703	702	Id	\N	R	1	\N	\N	\N	\N
77	704	706	sig_f	sig_f	\N	3	\N	\N	\N	\N
77	705	704	COLON	\N	:	2	\N	\N	\N	\N
77	706	711	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
77	707	706	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
77	708	706	Id	\N	latitude	2	\N	\N	\N	\N
77	709	706	PRIME	\N	prime	4	\N	\N	\N	\N
77	710	706	Dot	\N	.	5	\N	\N	\N	\N
77	711	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
78	712	714	sig_e	sig_eI	\N	1	\N	\N	\N	\N
78	713	712	Id	\N	place	1	\N	\N	\N	\N
78	714	717	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
78	715	717	sig_e	sig_eI	\N	3	\N	\N	\N	\N
78	716	715	Id	\N	R	1	\N	\N	\N	\N
78	717	719	sig_f	sig_f	\N	3	\N	\N	\N	\N
78	718	717	COLON	\N	:	2	\N	\N	\N	\N
78	719	724	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
78	720	719	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
78	721	719	Id	\N	longitude	2	\N	\N	\N	\N
78	722	719	PRIME	\N	prime	4	\N	\N	\N	\N
78	723	719	Dot	\N	.	5	\N	\N	\N	\N
78	724	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
79	726	725	String	\N	связи места	1	\N	\N	\N	\N
79	725	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
80	727	729	sig_e	sig_eI	\N	1	\N	\N	\N	\N
80	728	727	Id	\N	place	1	\N	\N	\N	\N
80	729	734	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
80	730	729	sig_e	sig_eI	\N	2	\N	\N	\N	\N
80	731	730	Id	\N	place	1	\N	\N	\N	\N
80	732	734	sig_e	sig_eI	\N	3	\N	\N	\N	\N
80	733	732	Id	\N	TV	1	\N	\N	\N	\N
80	734	736	sig_f	sig_f	\N	3	\N	\N	\N	\N
80	735	734	COLON	\N	:	2	\N	\N	\N	\N
80	736	741	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
80	737	736	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
80	738	736	Id	\N	part_of	2	\N	\N	\N	\N
80	739	736	PRIME	\N	prime	4	\N	\N	\N	\N
80	740	736	Dot	\N	.	5	\N	\N	\N	\N
80	741	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
81	742	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
81	743	742	String	\N	оператор весового процентного содержания вещества	1	\N	\N	\N	\N
82	744	746	sig_e	sig_eI	\N	1	\N	\N	\N	\N
82	745	744	Id	\N	sample	1	\N	\N	\N	\N
82	746	749	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
82	747	749	sig_e	sig_eI	\N	3	\N	\N	\N	\N
82	748	747	Id	\N	TV	1	\N	\N	\N	\N
82	749	751	sig_f	sig_f	\N	2	\N	\N	\N	\N
82	750	749	COLON	\N	:	2	\N	\N	\N	\N
82	751	754	sig_e	sig_eF	\N	1	\N	\N	\N	\N
82	752	751	l_p	\N	(	1	\N	\N	\N	\N
82	753	751	r_p	\N	)	3	\N	\N	\N	\N
82	754	765	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
82	755	757	sig_e	sig_eI	\N	1	\N	\N	\N	\N
82	756	755	Id	\N	sample	1	\N	\N	\N	\N
82	757	760	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
82	758	760	sig_e	sig_eI	\N	3	\N	\N	\N	\N
82	759	758	Id	\N	R	1	\N	\N	\N	\N
82	760	762	sig_f	sig_f	\N	2	\N	\N	\N	\N
82	761	760	COLON	\N	:	2	\N	\N	\N	\N
82	762	765	sig_e	sig_eF	\N	3	\N	\N	\N	\N
82	763	762	l_p	\N	(	1	\N	\N	\N	\N
82	764	762	r_p	\N	)	3	\N	\N	\N	\N
82	765	767	sig_f	sig_f	\N	3	\N	\N	\N	\N
82	766	765	COLON	\N	:	2	\N	\N	\N	\N
82	767	772	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
82	768	767	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
82	769	767	Id	\N	WPC	2	\N	\N	\N	\N
82	770	767	PRIME	\N	prime	4	\N	\N	\N	\N
82	771	767	Dot	\N	.	5	\N	\N	\N	\N
82	772	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
83	774	773	String	\N	аксиомы	1	\N	\N	\N	\N
83	773	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
84	776	775	String	\N	GPfull: Каждый образец имеет место сбора.	1	\N	\N	\N	\N
84	775	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
85	778	777	Id	\N	gathering_place	1	75	2	\N	689
85	780	779	Id	\N	x	1	0	2	\N	798
85	786	785	Id	\N	y	1	0	2	\N	791
85	777	782	term	trmi	\N	1	75	2	\N	689
85	779	781	term	trmi	\N	-1	85	2	\N	803
85	785	787	term	trmi	\N	4	85	2	\N	796
85	782	787	term	trmf	\N	2	75	2	\N	688
285	1618	1617	e_m	\N	!	1	\N	\N	\N	\N
85	787	791	term	trmin	\N	6	62	2	\N	557
285	1619	1617	Id	\N	SAM30693	2	\N	\N	\N	\N
285	1620	1617	Id	\N	sample	3	\N	\N	\N	\N
285	1621	1617	e_m	\N	!	4	\N	\N	\N	\N
85	791	798	term	trme	\N	6	62	2	\N	557
285	1617	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
85	798	805	term	trma	\N	3	62	2	\N	557
85	805	\N	Statement	st-5	\N	\N	86	0	\N	\N
85	806	805	Axiom	\N	Axiom	1	\N	0	\N	\N
85	807	805	Id	\N	GPfull	2	\N	0	\N	\N
85	808	805	Dot	\N	.	4	\N	0	\N	\N
85	781	782	TermList	#trml	\N	3	\N	1	\N	\N
85	783	782	l_p	\N	(	2	\N	1	\N	\N
85	784	782	r_p	\N	)	4	\N	1	\N	\N
85	788	787	l_p	\N	(	1	\N	1	\N	\N
85	790	787	r_p	\N	)	5	\N	1	\N	\N
85	792	791	l_p	\N	(	1	\N	1	\N	\N
85	793	791	EXISTS	\N	∃	2	\N	1	\N	\N
295	1758	1757	e_m	\N	!	1	\N	\N	\N	\N
295	1759	1757	Id	\N	SAM30696	2	\N	\N	\N	\N
295	1760	1757	Id	\N	sample	3	\N	\N	\N	\N
295	1761	1757	e_m	\N	!	4	\N	\N	\N	\N
85	795	791	COLON	\N	:	4	\N	1	\N	\N
295	1757	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
85	797	791	r_p	\N	)	7	\N	1	\N	\N
85	799	798	l_p	\N	(	1	\N	1	\N	\N
85	800	798	FOR_ANY	\N	∀	2	\N	1	\N	\N
85	802	798	COLON	\N	:	4	\N	1	\N	\N
85	804	798	r_p	\N	)	7	\N	1	\N	\N
85	796	791	Id	\N	place	5	0	2	\N	\N
85	803	798	Id	\N	sample	5	0	2	\N	\N
85	794	791	Id	\N	y	3	0	2	\N	\N
85	801	798	Id	\N	x	3	0	2	\N	\N
86	777	782	term	trmi	\N	1	75	0	\N	689
85	789	787	INFIX	\N	=	3	62	2	\N	558
87	810	809	String	\N	Dfull: Каждый образец описан.	1	\N	\N	\N	\N
87	809	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
86	779	781	term	trmi	\N	-1	85	0	\N	803
86	781	782	TermList	#trml	\N	3	\N	0	\N	\N
86	782	1996	term	trmf	\N	-2	75	0	\N	688
86	783	782	l_p	\N	(	2	\N	0	\N	\N
86	784	782	r_p	\N	)	4	\N	0	\N	\N
86	785	1996	term	trmi	\N	-1	85	0	\N	796
86	787	791	term	trmf	\N	6	62	0	\N	557
86	788	787	l_p	\N	(	2	\N	0	\N	\N
86	791	798	term	trme	\N	6	62	0	\N	557
86	798	805	term	trma	\N	3	62	0	\N	557
86	805	\N	Statement	st-5	\N	\N	85	0	\N	\N
86	806	805	Axiom	\N	Axiom	1	\N	0	\N	\N
86	808	805	Dot	\N	.	4	\N	0	\N	\N
86	790	787	r_p	\N	)	4	\N	0	\N	\N
86	792	791	l_p	\N	(	1	\N	0	\N	\N
86	793	791	EXISTS	\N	∃	2	\N	0	\N	\N
86	795	791	COLON	\N	:	4	\N	0	\N	\N
86	797	791	r_p	\N	)	7	\N	0	\N	\N
86	799	798	l_p	\N	(	1	\N	0	\N	\N
86	800	798	FOR_ANY	\N	∀	2	\N	0	\N	\N
86	802	798	COLON	\N	:	4	\N	0	\N	\N
86	804	798	r_p	\N	)	7	\N	0	\N	\N
86	1994	787	term	trmi	\N	1	62	0	\N	558
86	1996	787	TermList	#trml	\N	3	\N	0	\N	\N
88	832	839	term	trma	\N	3	56	2	\N	499
86	778	777	Id	\N	gathering_place	1	75	0	\N	689
86	780	779	Id	\N	x	1	0	0	\N	798
86	786	785	Id	\N	y	1	0	0	\N	791
86	794	791	Id	\N	y	3	0	0	\N	\N
86	796	791	Id	\N	place	5	0	0	\N	\N
86	801	798	Id	\N	x	3	0	0	\N	\N
86	803	798	Id	\N	sample	5	0	0	\N	\N
86	807	805	Id	\N	GPfull	2	\N	0	\N	\N
86	1995	1994	Id	\N	EQU_place	1	62	0	\N	558
88	840	839	Axiom	\N	Axiom	1	\N	0	\N	\N
305	1898	1897	e_m	\N	!	1	\N	\N	\N	\N
305	1899	1897	Id	\N	SAM30697	2	\N	\N	\N	\N
305	1900	1897	Id	\N	sample	3	\N	\N	\N	\N
305	1901	1897	e_m	\N	!	4	\N	\N	\N	\N
305	1897	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
88	841	839	Id	\N	Dfull	2	\N	0	\N	\N
88	842	839	Dot	\N	.	4	\N	0	\N	\N
88	815	816	TermList	#trml	\N	3	\N	1	\N	\N
88	817	816	l_p	\N	(	2	\N	1	\N	\N
88	818	816	r_p	\N	)	4	\N	1	\N	\N
88	822	821	l_p	\N	(	1	\N	1	\N	\N
88	824	821	r_p	\N	)	5	\N	1	\N	\N
88	826	825	l_p	\N	(	1	\N	1	\N	\N
88	827	825	EXISTS	\N	∃	2	\N	1	\N	\N
88	829	825	COLON	\N	:	4	\N	1	\N	\N
88	831	825	r_p	\N	)	7	\N	1	\N	\N
88	833	832	l_p	\N	(	1	\N	1	\N	\N
88	834	832	FOR_ANY	\N	∀	2	\N	1	\N	\N
88	836	832	COLON	\N	:	4	\N	1	\N	\N
89	832	839	term	trma	\N	3	56	0	\N	499
88	838	832	r_p	\N	)	7	\N	1	\N	\N
89	838	832	r_p	\N	)	7	\N	0	\N	\N
89	839	\N	Statement	st-5	\N	\N	88	0	\N	\N
88	812	811	Id	\N	described	1	74	2	\N	676
89	840	839	Axiom	\N	Axiom	1	\N	0	\N	\N
88	814	813	Id	\N	x	1	0	2	\N	832
89	842	839	Dot	\N	.	4	\N	0	\N	\N
89	825	832	term	trme	\N	6	56	0	\N	499
88	820	819	Id	\N	y	1	0	2	\N	825
88	811	816	term	trmi	\N	1	74	2	\N	676
88	813	815	term	trmi	\N	-1	88	2	\N	837
88	819	821	term	trmi	\N	4	88	2	\N	830
88	830	825	Id	\N	publication	5	0	2	\N	\N
88	837	832	Id	\N	sample	5	0	2	\N	\N
88	828	825	Id	\N	y	3	0	2	\N	\N
88	835	832	Id	\N	x	3	0	2	\N	\N
89	821	825	term	trmf	\N	6	56	0	\N	499
89	816	1999	term	trmf	\N	-2	74	0	\N	675
88	816	821	term	trmf	\N	2	74	2	\N	675
89	811	816	term	trmi	\N	1	74	0	\N	676
88	823	821	INFIX	\N	=	3	56	2	\N	500
89	815	816	TermList	#trml	\N	3	\N	0	\N	\N
89	813	815	term	trmi	\N	-1	88	0	\N	837
88	821	825	term	trmin	\N	6	56	2	\N	499
89	817	816	l_p	\N	(	2	\N	0	\N	\N
89	818	816	r_p	\N	)	4	\N	0	\N	\N
88	825	832	term	trme	\N	6	56	2	\N	499
88	839	\N	Statement	st-5	\N	\N	89	0	\N	\N
89	819	1999	term	trmi	\N	-1	88	0	\N	830
89	822	821	l_p	\N	(	2	\N	0	\N	\N
89	824	821	r_p	\N	)	4	\N	0	\N	\N
89	812	811	Id	\N	described	1	74	0	\N	676
89	814	813	Id	\N	x	1	0	0	\N	832
89	820	819	Id	\N	y	1	0	0	\N	825
89	837	832	Id	\N	sample	5	0	0	\N	\N
89	841	839	Id	\N	Dfull	2	\N	0	\N	\N
95	898	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
96	899	901	sig_e	sig_eI	\N	1	\N	\N	\N	\N
96	900	899	Id	\N	sample	1	\N	\N	\N	\N
96	901	904	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
96	902	904	sig_e	sig_eI	\N	3	\N	\N	\N	\N
96	903	902	Id	\N	TV	1	\N	\N	\N	\N
96	904	906	sig_f	sig_f	\N	3	\N	\N	\N	\N
96	905	904	COLON	\N	:	2	\N	\N	\N	\N
89	826	825	l_p	\N	(	1	\N	0	\N	\N
89	827	825	EXISTS	\N	∃	2	\N	0	\N	\N
96	906	911	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
89	829	825	COLON	\N	:	4	\N	0	\N	\N
96	907	906	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
89	831	825	r_p	\N	)	7	\N	0	\N	\N
89	833	832	l_p	\N	(	1	\N	0	\N	\N
89	834	832	FOR_ANY	\N	∀	2	\N	0	\N	\N
96	908	906	Id	\N	MGO	2	\N	\N	\N	\N
89	836	832	COLON	\N	:	4	\N	0	\N	\N
96	909	906	PRIME	\N	prime	4	\N	\N	\N	\N
89	1997	821	term	trmi	\N	1	56	0	\N	500
89	1999	821	TermList	#trml	\N	3	\N	0	\N	\N
96	910	906	Dot	\N	.	5	\N	\N	\N	\N
96	911	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
97	912	914	sig_e	sig_eI	\N	1	\N	\N	\N	\N
89	828	825	Id	\N	y	3	0	0	\N	\N
89	830	825	Id	\N	publication	5	0	0	\N	\N
89	835	832	Id	\N	x	3	0	0	\N	\N
89	1998	1997	Id	\N	EQU_publication	1	56	0	\N	500
90	844	843	String	\N	горные породы	1	\N	\N	\N	\N
90	843	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
91	845	847	sig_e	sig_eI	\N	1	\N	\N	\N	\N
91	846	845	Id	\N	sample	1	\N	\N	\N	\N
91	847	850	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
91	848	850	sig_e	sig_eI	\N	3	\N	\N	\N	\N
91	849	848	Id	\N	TV	1	\N	\N	\N	\N
91	850	852	sig_f	sig_f	\N	3	\N	\N	\N	\N
91	851	850	COLON	\N	:	2	\N	\N	\N	\N
91	852	857	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
91	853	852	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
91	854	852	Id	\N	rhyolite	2	\N	\N	\N	\N
91	855	852	PRIME	\N	prime	4	\N	\N	\N	\N
91	856	852	Dot	\N	.	5	\N	\N	\N	\N
91	857	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
92	859	858	String	\N	химические вещества, элементы, изотопы...	1	\N	\N	\N	\N
92	858	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
93	860	862	sig_e	sig_eI	\N	1	\N	\N	\N	\N
93	861	860	Id	\N	sample	1	\N	\N	\N	\N
93	862	865	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
93	863	865	sig_e	sig_eI	\N	3	\N	\N	\N	\N
93	864	863	Id	\N	TV	1	\N	\N	\N	\N
93	865	867	sig_f	sig_f	\N	3	\N	\N	\N	\N
93	866	865	COLON	\N	:	2	\N	\N	\N	\N
93	867	872	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
93	868	867	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
93	869	867	Id	\N	SIO2	2	\N	\N	\N	\N
93	870	867	PRIME	\N	prime	4	\N	\N	\N	\N
93	871	867	Dot	\N	.	5	\N	\N	\N	\N
93	872	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
94	873	875	sig_e	sig_eI	\N	1	\N	\N	\N	\N
94	874	873	Id	\N	sample	1	\N	\N	\N	\N
94	875	878	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
94	876	878	sig_e	sig_eI	\N	3	\N	\N	\N	\N
94	877	876	Id	\N	TV	1	\N	\N	\N	\N
94	878	880	sig_f	sig_f	\N	3	\N	\N	\N	\N
94	879	878	COLON	\N	:	2	\N	\N	\N	\N
94	880	885	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
94	881	880	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
94	882	880	Id	\N	AL2O3	2	\N	\N	\N	\N
94	883	880	PRIME	\N	prime	4	\N	\N	\N	\N
94	884	880	Dot	\N	.	5	\N	\N	\N	\N
94	885	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
95	886	888	sig_e	sig_eI	\N	1	\N	\N	\N	\N
95	887	886	Id	\N	sample	1	\N	\N	\N	\N
95	888	891	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
95	889	891	sig_e	sig_eI	\N	3	\N	\N	\N	\N
95	890	889	Id	\N	TV	1	\N	\N	\N	\N
95	891	893	sig_f	sig_f	\N	3	\N	\N	\N	\N
95	892	891	COLON	\N	:	2	\N	\N	\N	\N
95	893	898	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
95	894	893	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
95	895	893	Id	\N	FE2O3	2	\N	\N	\N	\N
95	896	893	PRIME	\N	prime	4	\N	\N	\N	\N
95	897	893	Dot	\N	.	5	\N	\N	\N	\N
97	913	912	Id	\N	sample	1	\N	\N	\N	\N
97	914	917	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
97	915	917	sig_e	sig_eI	\N	3	\N	\N	\N	\N
97	916	915	Id	\N	TV	1	\N	\N	\N	\N
97	917	919	sig_f	sig_f	\N	3	\N	\N	\N	\N
97	918	917	COLON	\N	:	2	\N	\N	\N	\N
97	919	924	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
97	920	919	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
97	921	919	Id	\N	CAO	2	\N	\N	\N	\N
97	922	919	PRIME	\N	prime	4	\N	\N	\N	\N
97	923	919	Dot	\N	.	5	\N	\N	\N	\N
97	924	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
98	925	927	sig_e	sig_eI	\N	1	\N	\N	\N	\N
98	926	925	Id	\N	sample	1	\N	\N	\N	\N
98	927	930	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
98	928	930	sig_e	sig_eI	\N	3	\N	\N	\N	\N
98	929	928	Id	\N	TV	1	\N	\N	\N	\N
98	930	932	sig_f	sig_f	\N	3	\N	\N	\N	\N
98	931	930	COLON	\N	:	2	\N	\N	\N	\N
98	932	937	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
98	933	932	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
98	934	932	Id	\N	NA2O	2	\N	\N	\N	\N
98	935	932	PRIME	\N	prime	4	\N	\N	\N	\N
98	936	932	Dot	\N	.	5	\N	\N	\N	\N
98	937	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
99	938	940	sig_e	sig_eI	\N	1	\N	\N	\N	\N
99	939	938	Id	\N	sample	1	\N	\N	\N	\N
99	940	943	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
315	2038	2037	e_m	\N	!	1	\N	\N	\N	\N
315	2039	2037	Id	\N	SAM30682	2	\N	\N	\N	\N
315	2040	2037	Id	\N	sample	3	\N	\N	\N	\N
315	2041	2037	e_m	\N	!	4	\N	\N	\N	\N
315	2037	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
325	2178	2177	e_m	\N	!	1	\N	\N	\N	\N
325	2179	2177	Id	\N	SAM30695	2	\N	\N	\N	\N
325	2180	2177	Id	\N	sample	3	\N	\N	\N	\N
325	2181	2177	e_m	\N	!	4	\N	\N	\N	\N
325	2177	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
335	2318	2317	e_m	\N	!	1	\N	\N	\N	\N
335	2319	2317	Id	\N	SAM30694	2	\N	\N	\N	\N
335	2320	2317	Id	\N	sample	3	\N	\N	\N	\N
335	2321	2317	e_m	\N	!	4	\N	\N	\N	\N
335	2317	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
99	941	943	sig_e	sig_eI	\N	3	\N	\N	\N	\N
99	942	941	Id	\N	TV	1	\N	\N	\N	\N
99	943	945	sig_f	sig_f	\N	3	\N	\N	\N	\N
99	944	943	COLON	\N	:	2	\N	\N	\N	\N
99	945	950	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
99	946	945	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
99	947	945	Id	\N	K2O	2	\N	\N	\N	\N
99	948	945	PRIME	\N	prime	4	\N	\N	\N	\N
99	949	945	Dot	\N	.	5	\N	\N	\N	\N
99	950	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
100	951	953	sig_e	sig_eI	\N	1	\N	\N	\N	\N
100	952	951	Id	\N	sample	1	\N	\N	\N	\N
100	953	956	sig_arg	#sig_arg	\N	1	\N	\N	\N	\N
100	954	956	sig_e	sig_eI	\N	3	\N	\N	\N	\N
100	955	954	Id	\N	TV	1	\N	\N	\N	\N
100	956	958	sig_f	sig_f	\N	3	\N	\N	\N	\N
100	957	956	COLON	\N	:	2	\N	\N	\N	\N
100	958	963	Declaration	Dcl-4	\N	1	\N	\N	\N	\N
100	959	958	DECLARATION	\N	Declaration	1	\N	\N	\N	\N
100	960	958	Id	\N	H2Op	2	\N	\N	\N	\N
100	961	958	PRIME	\N	prime	4	\N	\N	\N	\N
100	962	958	Dot	\N	.	5	\N	\N	\N	\N
100	963	\N	Statement	st-1	\N	\N	\N	\N	\N	\N
101	965	964	String	\N	географические названия	1	\N	\N	\N	\N
101	964	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
102	967	966	e_m	\N	!	1	\N	\N	\N	\N
102	968	966	Id	\N	Iceland	2	\N	\N	\N	\N
102	969	966	Id	\N	place	3	\N	\N	\N	\N
102	970	966	e_m	\N	!	4	\N	\N	\N	\N
102	966	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
103	972	971	e_m	\N	!	1	\N	\N	\N	\N
103	973	971	Id	\N	Atlantic_Ocean	2	\N	\N	\N	\N
103	974	971	Id	\N	place	3	\N	\N	\N	\N
103	975	971	e_m	\N	!	4	\N	\N	\N	\N
103	971	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
104	977	976	String	\N	постатейная часть	1	\N	\N	\N	\N
104	976	\N	Statement	st-3	\N	\N	\N	\N	\N	\N
105	979	978	e_m	\N	!	1	\N	\N	\N	\N
105	980	978	Id	\N	PUB5633	2	\N	\N	\N	\N
105	981	978	Id	\N	publication	3	\N	\N	\N	\N
105	982	978	e_m	\N	!	4	\N	\N	\N	\N
105	978	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
106	984	983	e_m	\N	!	1	\N	\N	\N	\N
106	985	983	Id	\N	PLC1809	2	\N	\N	\N	\N
106	986	983	Id	\N	place	3	\N	\N	\N	\N
106	987	983	e_m	\N	!	4	\N	\N	\N	\N
106	983	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
107	989	988	e_m	\N	!	1	\N	\N	\N	\N
107	990	988	Id	\N	SAM32994	2	\N	\N	\N	\N
107	991	988	Id	\N	sample	3	\N	\N	\N	\N
107	992	988	e_m	\N	!	4	\N	\N	\N	\N
107	988	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
108	994	993	e_m	\N	!	1	\N	\N	\N	\N
108	995	993	Id	\N	SAM32995	2	\N	\N	\N	\N
108	996	993	Id	\N	sample	3	\N	\N	\N	\N
108	997	993	e_m	\N	!	4	\N	\N	\N	\N
108	993	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
109	999	998	e_m	\N	!	1	\N	\N	\N	\N
109	1000	998	Id	\N	SAM32996	2	\N	\N	\N	\N
109	1001	998	Id	\N	sample	3	\N	\N	\N	\N
109	1002	998	e_m	\N	!	4	\N	\N	\N	\N
109	998	\N	Statement	fmca	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: entities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY entities (id, ref_r, def_id, expr, type, ref_arg, fp_id, prime, ein, sers, tid, cf) FROM stdin;
basalt_and_olivine	0000000004	\N	\N	func	0000000003	\N	1	51	\N	536	\N
trachydolerite	0000000018	\N	\N	func	0000000017	\N	1	52	\N	537	\N
trachyte	0000000031	\N	\N	func	0000000030	\N	1	53	\N	538	\N
obsidian	0000000044	\N	\N	func	0000000043	\N	1	54	\N	539	\N
basalt	0000000057	\N	\N	func	0000000056	\N	1	55	\N	540	\N
authorial_number	0000000646	\N	\N	func	0000000645	\N	1	32	\N	71	\N
TIO2	0000000075	\N	\N	func	0000000074	\N	1	56	\N	542	\N
FEO	0000000088	\N	\N	func	0000000087	\N	1	57	\N	543	\N
MNO	0000000101	\N	\N	func	0000000100	\N	1	58	\N	544	\N
reference	0000000659	\N	\N	func	0000000658	\N	1	33	\N	72	\N
P2O5	0000000114	\N	\N	func	0000000113	\N	1	59	\N	545	\N
CO2	0000000127	\N	\N	func	0000000126	\N	1	60	\N	546	\N
H2Om	0000000140	\N	\N	func	0000000139	\N	1	61	\N	547	\N
trachyandesite	0000000004	\N	\N	func	0000000003	\N	1	62	\N	897	\N
TV	\N	\N	\N	sort	\N	\N	\N	1	\N	2	\N
NOT	0000000017	\N	\N	func	0000000016	\N	1	2	\N	3	\N
AND	0000000046	\N	\N	func	0000000043	\N	1	3	\N	6	\N
OR	0000000075	\N	\N	func	0000000072	\N	1	4	\N	9	\N
IMPLIES	0000000104	IMPL_d	\N	func	0000000101	\N	0	5	\N	12	\N
IMPL_d	\N	\N	0000000142	def	\N	0000000133	\N	6	\N	15	\N
EQUIV	0000000158	EQV_d	\N	func	0000000155	\N	0	7	\N	17	\N
EQV_d	\N	\N	0000000204	def	\N	0000000187	\N	8	\N	20	\N
S	\N	\N	[^DQ]*	sort	\N	\N	\N	9	\N	26	\N
S_EQ	0000000241	\N	\N	func	0000000238	\N	1	10	\N	27	fm_strcmp
R	\N	\N	[-+]?{DIGIT}+({Dot}{DIGIT}+)?	sort	\N	\N	\N	11	\N	31	\N
R_EQ	0000000279	\N	\N	func	0000000276	\N	1	12	\N	34	fm_req
R_LT	0000000302	\N	\N	func	0000000299	\N	1	13	\N	36	fm_rlt
R_PLUS	0000000325	\N	\N	func	0000000322	\N	1	14	\N	38	fm_radd
R_MINUS	0000000348	\N	\N	func	0000000345	\N	1	15	\N	40	fm_rminus
R_MULTIPLY	0000000371	\N	\N	func	0000000368	\N	1	16	\N	42	fm_rmult
R_DEVIDE	0000000394	\N	\N	func	0000000391	\N	1	17	\N	44	fm_rdev
R_GT	0000000419	\N	\N	func	0000000416	\N	1	18	\N	47	fm_rgt
R_LE	0000000442	\N	\N	func	0000000439	\N	1	19	\N	49	fm_rle
R_GE	0000000465	\N	\N	func	0000000462	\N	1	20	\N	51	fm_rge
publication	\N	\N	\N	sort	\N	\N	\N	21	\N	55	\N
EQU_publication	0000000498	\N	\N	func	0000000495	\N	1	22	\N	56	fm_strcmp
sample	\N	\N	\N	sort	\N	\N	\N	23	\N	58	\N
EQU_sample	0000000527	\N	\N	func	0000000524	\N	1	24	\N	59	fm_strcmp
place	\N	\N	\N	sort	\N	\N	\N	25	\N	61	\N
EQU_place	0000000556	\N	\N	func	0000000553	\N	1	26	\N	62	fm_strcmp
title	0000000579	\N	\N	func	0000000578	\N	1	27	\N	65	\N
journal_reference	0000000592	\N	\N	func	0000000591	\N	1	28	\N	66	\N
year	0000000605	\N	\N	func	0000000604	\N	1	29	\N	67	\N
first_page	0000000618	\N	\N	func	0000000617	\N	1	30	\N	68	\N
last_page	0000000631	\N	\N	func	0000000630	\N	1	31	\N	69	\N
described	0000000674	\N	\N	func	0000000673	\N	1	34	\N	74	\N
gathering_place	0000000687	\N	\N	func	0000000686	\N	1	35	\N	75	\N
latitude	0000000702	\N	\N	func	0000000701	\N	1	36	\N	77	\N
longitude	0000000715	\N	\N	func	0000000714	\N	1	37	\N	78	\N
part_of	0000000732	\N	\N	func	0000000729	\N	1	38	\N	80	\N
WPC	0000000762	\N	\N	func	0000000754	\N	1	39	\N	82	\N
GPfull	\N	\N	0000000798	axi	\N	\N	\N	40	\N	85	\N
Dfull	\N	\N	0000000832	axi	\N	\N	\N	41	\N	88	\N
rhyolite	0000000848	\N	\N	func	0000000847	\N	1	42	\N	91	\N
SIO2	0000000863	\N	\N	func	0000000862	\N	1	43	\N	93	\N
AL2O3	0000000876	\N	\N	func	0000000875	\N	1	44	\N	94	\N
FE2O3	0000000889	\N	\N	func	0000000888	\N	1	45	\N	95	\N
MGO	0000000902	\N	\N	func	0000000901	\N	1	46	\N	96	\N
CAO	0000000915	\N	\N	func	0000000914	\N	1	47	\N	97	\N
NA2O	0000000928	\N	\N	func	0000000927	\N	1	48	\N	98	\N
K2O	0000000941	\N	\N	func	0000000940	\N	1	49	\N	99	\N
H2Op	0000000954	\N	\N	func	0000000953	\N	1	50	\N	100	\N
\.


--
-- Data for Name: fm_tv; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY fm_tv (t, v) FROM stdin;
 WPC ( H2Op ) ( SAM32996 )	3.08
 WPC ( K2O ) ( SAM32994 )	2.37
 WPC ( K2O ) ( SAM32995 )	1.68
 WPC ( K2O ) ( SAM32996 )	1.55
 WPC ( MGO ) ( SAM32994 )	0.15
 WPC ( MGO ) ( SAM32995 )	0.25
 WPC ( MGO ) ( SAM32996 )	0.1
 WPC ( NA2O ) ( SAM32994 )	5.3
 WPC ( NA2O ) ( SAM32995 )	4.33
 WPC ( NA2O ) ( SAM32996 )	4.22
 WPC ( SIO2 ) ( SAM32994 )	73.95
 WPC ( SIO2 ) ( SAM32995 )	72.25
 WPC ( SIO2 ) ( SAM32996 )	71.32
 year ( PUB5633 )	1946
 reference ( SAM30681 )	""
 title ( PUB5918 )	"THE GEOLOGY OF ASCENSION ISLAND. "
 gathering_place ( SAM30681 )	PLC1555
 journal_reference ( PUB5918 )	"PROC. AM. ACAD. ARTS SCI. 60"
 year ( PUB5918 )	1925
 first_page ( PUB5918 )	3
 last_page ( PUB5918 )	80
 authorial_number ( SAM30681 )	""
 described ( SAM30681 )	PUB5918
 reference ( SAM30683 )	""
 gathering_place ( SAM30683 )	PLC1555
 authorial_number ( SAM30683 )	""
 described ( SAM30683 )	PUB5918
 reference ( SAM30684 )	""
 gathering_place ( SAM30684 )	PLC1555
 authorial_number ( SAM30684 )	""
 described ( SAM30684 )	PUB5918
 reference ( SAM30685 )	""
 gathering_place ( SAM30685 )	PLC1555
 authorial_number ( SAM30685 )	""
 described ( SAM30685 )	PUB5918
 reference ( SAM30686 )	""
 gathering_place ( SAM30686 )	PLC1555
 authorial_number ( SAM30686 )	""
 described ( SAM30686 )	PUB5918
 reference ( SAM30687 )	""
 gathering_place ( SAM30687 )	PLC1555
 authorial_number ( SAM30687 )	""
 described ( SAM30687 )	PUB5918
 reference ( SAM30688 )	""
 gathering_place ( SAM30688 )	PLC1555
 authorial_number ( SAM30688 )	""
 described ( SAM30688 )	PUB5918
 reference ( SAM30689 )	""
 gathering_place ( SAM30689 )	PLC1555
 authorial_number ( SAM30689 )	""
 AND ( False False )	False
 AND ( False True )	False
 AND ( True False )	False
 AND ( True True )	True
 authorial_number ( SAM32994 )	"A"
 authorial_number ( SAM32995 )	"B"
 authorial_number ( SAM32996 )	"C"
 described ( SAM32994 )	PUB5633
 described ( SAM32995 )	PUB5633
 described ( SAM32996 )	PUB5633
 first_page ( PUB5633 )	1
 gathering_place ( SAM32994 )	PLC1809
 gathering_place ( SAM32995 )	PLC1809
 gathering_place ( SAM32996 )	PLC1809
 journal_reference ( PUB5633 )	"ACTA NAT. ISLAND. 1 (2)"
 last_page ( PUB5633 )	15
 latitude ( PLC1809 )	64.7
 longitude ( PLC1809 )	-19.2
 NOT ( False )	True
 NOT ( True )	False
 OR ( False False )	False
 OR ( False True )	True
 OR ( True False )	True
 OR ( True True )	True
 part_of ( PLC1809 Atlantic_Ocean )	True
 part_of ( PLC1809 Iceland )	True
 reference ( SAM32994 )	"KERLINGARFJELL"
 reference ( SAM32995 )	"KERLINGARFJELL"
 reference ( SAM32996 )	"KERLINGARFJELL"
 rhyolite ( SAM32994 )	True
 rhyolite ( SAM32995 )	True
 rhyolite ( SAM32996 )	True
 title ( PUB5633 )	"A CONTRIBUTION TO THE GEOLOGY OF THE KERLINGARFJELL"
 WPC ( AL2O3 ) ( SAM32994 )	15
 WPC ( AL2O3 ) ( SAM32995 )	12.8
 WPC ( AL2O3 ) ( SAM32996 )	14.35
 WPC ( CAO ) ( SAM32994 )	0.72
 WPC ( CAO ) ( SAM32995 )	2.55
 WPC ( CAO ) ( SAM32996 )	1.22
 WPC ( FE2O3 ) ( SAM32994 )	1.05
 WPC ( FE2O3 ) ( SAM32995 )	5.1
 WPC ( FE2O3 ) ( SAM32996 )	3.3
 WPC ( H2Op ) ( SAM32994 )	0.51
 WPC ( H2Op ) ( SAM32995 )	1.27
 described ( SAM30689 )	PUB5918
 reference ( SAM30690 )	""
 gathering_place ( SAM30690 )	PLC1555
 authorial_number ( SAM30690 )	""
 described ( SAM30690 )	PUB5918
 reference ( SAM30691 )	""
 gathering_place ( SAM30691 )	PLC1555
 authorial_number ( SAM30691 )	""
 described ( SAM30691 )	PUB5918
 reference ( SAM30692 )	""
 gathering_place ( SAM30692 )	PLC1555
 authorial_number ( SAM30692 )	""
 described ( SAM30692 )	PUB5918
 reference ( SAM30693 )	""
 gathering_place ( SAM30693 )	PLC1555
 authorial_number ( SAM30693 )	""
 described ( SAM30693 )	PUB5918
 reference ( SAM30696 )	""
 gathering_place ( SAM30696 )	PLC1555
 authorial_number ( SAM30696 )	""
 described ( SAM30696 )	PUB5918
 reference ( SAM30697 )	""
 authorial_number ( SAM30697 )	""
 rhyolite ( SAM30697 )	True
 described ( SAM30697 )	PUB5918
 gathering_place ( SAM30697 )	PLC1555
 authorial_number ( SAM30682 )	""
 longitude ( PLC1555 )	-14.37
 described ( SAM30682 )	PUB5918
 reference ( SAM30682 )	""
 authorial_number ( SAM30695 )	""
 described ( SAM30695 )	PUB5918
 reference ( SAM30695 )	""
 gathering_place ( SAM30695 )	PLC1555
 authorial_number ( SAM30694 )	""
 described ( SAM30694 )	PUB5918
 reference ( SAM30694 )	""
 gathering_place ( SAM30694 )	PLC1555
 WPC ( SIO2 ) ( SAM30681 )	47.69
 WPC ( AL2O3 ) ( SAM30681 )	16.23
 WPC ( FE2O3 ) ( SAM30681 )	2.2
 WPC ( MGO ) ( SAM30681 )	7.15
 WPC ( CAO ) ( SAM30681 )	10.02
 WPC ( NA2O ) ( SAM30681 )	2.87
 WPC ( K2O ) ( SAM30681 )	0.64
 WPC ( H2Op ) ( SAM30681 )	0.19
 WPC ( AL2O3 ) ( SAM30682 )	15.54
 WPC ( FE2O3 ) ( SAM30682 )	5.31
 WPC ( MGO ) ( SAM30682 )	4.96
 WPC ( CAO ) ( SAM30682 )	9.03
 WPC ( NA2O ) ( SAM30682 )	3.6
 WPC ( K2O ) ( SAM30682 )	1.24
 WPC ( H2Op ) ( SAM30682 )	0.18
 WPC ( SIO2 ) ( SAM30683 )	52.87
 WPC ( AL2O3 ) ( SAM30683 )	16.68
 WPC ( FE2O3 ) ( SAM30683 )	4.54
 WPC ( MGO ) ( SAM30683 )	3.92
 WPC ( CAO ) ( SAM30683 )	7.32
 WPC ( NA2O ) ( SAM30683 )	4.63
 WPC ( K2O ) ( SAM30683 )	2.06
 WPC ( H2Op ) ( SAM30683 )	0.3
 WPC ( SIO2 ) ( SAM30684 )	51.18
 WPC ( FE2O3 ) ( SAM30684 )	4.63
 WPC ( MGO ) ( SAM30684 )	1.75
 WPC ( CAO ) ( SAM30684 )	6.56
 WPC ( NA2O ) ( SAM30684 )	4.72
 WPC ( K2O ) ( SAM30684 )	3.53
 WPC ( SIO2 ) ( SAM30685 )	54.04
 WPC ( AL2O3 ) ( SAM30685 )	19.58
 WPC ( FE2O3 ) ( SAM30685 )	5.09
 WPC ( MGO ) ( SAM30685 )	1.99
 WPC ( CAO ) ( SAM30685 )	5.54
 WPC ( NA2O ) ( SAM30685 )	4.7
 WPC ( K2O ) ( SAM30685 )	3.78
 WPC ( SIO2 ) ( SAM30686 )	58
 WPC ( AL2O3 ) ( SAM30686 )	14.92
 WPC ( FE2O3 ) ( SAM30686 )	1.73
 WPC ( MGO ) ( SAM30686 )	2.23
 WPC ( CAO ) ( SAM30686 )	4.5
 WPC ( NA2O ) ( SAM30686 )	5.88
 WPC ( H2Op ) ( SAM30686 )	0.31
 WPC ( SIO2 ) ( SAM30687 )	65.18
 WPC ( AL2O3 ) ( SAM30687 )	15.91
 WPC ( FE2O3 ) ( SAM30687 )	4.41
 WPC ( MGO ) ( SAM30687 )	0.1
 WPC ( CAO ) ( SAM30687 )	0.81
 WPC ( NA2O ) ( SAM30687 )	6.24
 WPC ( K2O ) ( SAM30687 )	4.6
 WPC ( H2Op ) ( SAM30687 )	0.53
 WPC ( SIO2 ) ( SAM30688 )	66.98
 WPC ( AL2O3 ) ( SAM30688 )	14.3
 WPC ( FE2O3 ) ( SAM30688 )	3.85
 WPC ( MGO ) ( SAM30688 )	0.3
 WPC ( CAO ) ( SAM30688 )	0.83
 WPC ( K2O ) ( SAM30688 )	4.34
 WPC ( H2Op ) ( SAM30688 )	0.44
 WPC ( SIO2 ) ( SAM30689 )	66.12
 WPC ( AL2O3 ) ( SAM30689 )	15.51
 WPC ( FE2O3 ) ( SAM30689 )	3.27
 WPC ( MGO ) ( SAM30689 )	0.17
 WPC ( CAO ) ( SAM30689 )	1.05
 WPC ( NA2O ) ( SAM30689 )	6.31
 WPC ( K2O ) ( SAM30689 )	5.4
 WPC ( H2Op ) ( SAM30689 )	1.98
 WPC ( SIO2 ) ( SAM30690 )	63.98
 WPC ( AL2O3 ) ( SAM30690 )	16
 WPC ( MGO ) ( SAM30690 )	0.64
 WPC ( CAO ) ( SAM30690 )	1.58
 WPC ( NA2O ) ( SAM30690 )	6.45
 WPC ( K2O ) ( SAM30690 )	5.18
 WPC ( H2Op ) ( SAM30690 )	0.61
 WPC ( SIO2 ) ( SAM30691 )	67.05
 WPC ( AL2O3 ) ( SAM30691 )	15.43
 WPC ( FE2O3 ) ( SAM30691 )	3.25
 WPC ( MGO ) ( SAM30691 )	0.16
 WPC ( CAO ) ( SAM30691 )	1.06
 WPC ( NA2O ) ( SAM30691 )	6.12
 WPC ( K2O ) ( SAM30691 )	5.32
 WPC ( H2Op ) ( SAM30691 )	0.56
 WPC ( SIO2 ) ( SAM30692 )	63.02
 WPC ( AL2O3 ) ( SAM30692 )	15.75
 WPC ( FE2O3 ) ( SAM30692 )	0.52
 WPC ( MGO ) ( SAM30692 )	0.38
 WPC ( CAO ) ( SAM30692 )	1.49
 WPC ( K2O ) ( SAM30692 )	5.21
 WPC ( H2Op ) ( SAM30692 )	4.83
 WPC ( SIO2 ) ( SAM30693 )	55.1
 WPC ( AL2O3 ) ( SAM30693 )	18.56
 WPC ( FE2O3 ) ( SAM30693 )	6.8
 WPC ( MGO ) ( SAM30693 )	0.62
 WPC ( CAO ) ( SAM30693 )	0.7
 WPC ( NA2O ) ( SAM30693 )	3.17
 WPC ( K2O ) ( SAM30693 )	4
 WPC ( H2Op ) ( SAM30693 )	8.3
 WPC ( SIO2 ) ( SAM30694 )	71.88
 WPC ( AL2O3 ) ( SAM30694 )	12.85
 WPC ( FE2O3 ) ( SAM30694 )	3.6
 WPC ( MGO ) ( SAM30694 )	0.18
 WPC ( NA2O ) ( SAM30694 )	5.32
 WPC ( K2O ) ( SAM30694 )	4.78
 WPC ( H2Op ) ( SAM30694 )	0.17
 WPC ( SIO2 ) ( SAM30695 )	70.99
 WPC ( AL2O3 ) ( SAM30695 )	14.84
 WPC ( FE2O3 ) ( SAM30695 )	3.76
 WPC ( MGO ) ( SAM30695 )	0.14
 WPC ( CAO ) ( SAM30695 )	0.6
 WPC ( NA2O ) ( SAM30695 )	5.94
 WPC ( K2O ) ( SAM30695 )	2.4
 WPC ( H2Op ) ( SAM30695 )	0.4
 basalt_and_olivine ( SAM30681 )	True
 trachydolerite ( SAM30683 )	True
 WPC ( FE2O3 ) ( SAM30690 )	2.57
 WPC ( FEO ) ( SAM30690 )	2.12
 trachydolerite ( SAM30684 )	True
 WPC ( TIO2 ) ( SAM30691 )	0.1
 WPC ( FEO ) ( SAM30691 )	1.25
 trachydolerite ( SAM30685 )	True
 WPC ( P2O5 ) ( SAM30691 )	0.04
 WPC ( FEO ) ( SAM30692 )	3.15
 WPC ( NA2O ) ( SAM30692 )	6.11
 WPC ( FEO ) ( SAM30693 )	0.03
 trachyte ( SAM30687 )	True
 WPC ( TIO2 ) ( SAM30694 )	0.25
 WPC ( FEO ) ( SAM30694 )	0.05
 trachyte ( SAM30688 )	True
 WPC ( MNO ) ( SAM30694 )	0.29
 WPC ( CAO ) ( SAM30694 )	0.6
 trachyte ( SAM30689 )	True
 WPC ( P2O5 ) ( SAM30694 )	0.05
 WPC ( H2Om ) ( SAM30694 )	0.18
 trachyte ( SAM30690 )	True
 WPC ( FEO ) ( SAM30695 )	0.35
 WPC ( SIO2 ) ( SAM30696 )	72.71
 trachyte ( SAM30691 )	True
 WPC ( AL2O3 ) ( SAM30696 )	12.8
 WPC ( FE2O3 ) ( SAM30696 )	2.64
 trachyte ( SAM30692 )	True
 WPC ( FEO ) ( SAM30696 )	1.48
 WPC ( MGO ) ( SAM30696 )	0.1
 trachyte ( SAM30693 )	True
 WPC ( CAO ) ( SAM30696 )	0.58
 WPC ( NA2O ) ( SAM30696 )	6.5
 obsidian ( SAM30696 )	True
 WPC ( K2O ) ( SAM30696 )	3.87
 WPC ( H2Op ) ( SAM30696 )	0.48
 WPC ( SIO2 ) ( SAM30697 )	71.42
 WPC ( AL2O3 ) ( SAM30697 )	14.09
 WPC ( FE2O3 ) ( SAM30697 )	1.41
 basalt ( SAM30682 )	True
 WPC ( FEO ) ( SAM30697 )	2.32
 WPC ( MGO ) ( SAM30697 )	0.08
 WPC ( CAO ) ( SAM30697 )	0.8
 gathering_place ( SAM30682 )	PLC1555
 trachyte ( SAM30695 )	True
 WPC ( NA2O ) ( SAM30697 )	6.01
 WPC ( K2O ) ( SAM30697 )	3.52
 WPC ( H2Op ) ( SAM30697 )	0.85
 trachyte ( SAM30694 )	True
 latitude ( PLC1555 )	-7.93
 part_of ( PLC1555 Ascension )	True
 part_of ( PLC1555 Atlantic_Ocean )	True
 WPC ( TIO2 ) ( SAM30681 )	2.79
 WPC ( FEO ) ( SAM30681 )	9.93
 WPC ( MNO ) ( SAM30681 )	0.17
 WPC ( P2O5 ) ( SAM30681 )	0.59
 WPC ( CO2 ) ( SAM30681 )	0.04
 WPC ( H2Om ) ( SAM30681 )	0.09
 WPC ( SIO2 ) ( SAM30682 )	48.64
 WPC ( TIO2 ) ( SAM30682 )	3.52
 WPC ( FEO ) ( SAM30682 )	7.73
 WPC ( MNO ) ( SAM30682 )	0.17
 WPC ( P2O5 ) ( SAM30682 )	0.64
 WPC ( CO2 ) ( SAM30682 )	0.03
 WPC ( H2Om ) ( SAM30682 )	0.16
 WPC ( TIO2 ) ( SAM30683 )	2.01
 WPC ( FEO ) ( SAM30683 )	4.79
 WPC ( MNO ) ( SAM30683 )	0.37
 WPC ( P2O5 ) ( SAM30683 )	0.52
 WPC ( H2Om ) ( SAM30683 )	0.4
 WPC ( TIO2 ) ( SAM30684 )	1.34
 WPC ( AL2O3 ) ( SAM30684 )	21.41
 WPC ( FEO ) ( SAM30684 )	3.32
 WPC ( P2O5 ) ( SAM30684 )	0.48
 WPC ( H2Om ) ( SAM30684 )	1.08
 WPC ( TIO2 ) ( SAM30685 )	0.94
 WPC ( FEO ) ( SAM30685 )	3.75
 WPC ( P2O5 ) ( SAM30685 )	0.31
 WPC ( H2Om ) ( SAM30685 )	1.16
 WPC ( TIO2 ) ( SAM30686 )	3.38
 WPC ( FEO ) ( SAM30686 )	5.78
 WPC ( MNO ) ( SAM30686 )	0.11
 WPC ( K2O ) ( SAM30686 )	2.76
 WPC ( P2O5 ) ( SAM30686 )	0.71
 WPC ( H2Om ) ( SAM30686 )	0.09
 WPC ( TIO2 ) ( SAM30687 )	0.44
 WPC ( FEO ) ( SAM30687 )	0.98
 WPC ( MNO ) ( SAM30687 )	0.17
 WPC ( P2O5 ) ( SAM30687 )	0.08
 WPC ( CO2 ) ( SAM30687 )	0.09
 WPC ( H2Om ) ( SAM30687 )	0.45
 WPC ( TIO2 ) ( SAM30688 )	0.89
 WPC ( FEO ) ( SAM30688 )	0.33
 WPC ( MNO ) ( SAM30688 )	0.21
 WPC ( NA2O ) ( SAM30688 )	6.76
 WPC ( P2O5 ) ( SAM30688 )	0.22
 WPC ( H2Om ) ( SAM30688 )	0.08
 WPC ( FEO ) ( SAM30689 )	0.93
 WPC ( TIO2 ) ( SAM30690 )	0.28
 trachyandesite ( SAM30686 )	True
\.


--
-- Data for Name: infixes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY infixes (v, ref_f) FROM stdin;
¬	NOT
not	NOT
∧	AND
and	AND
∨	OR
or	OR
→	IMPLIES
impl	IMPLIES
≡	EQUIV
eqv	EQUIV
=	S_EQ
=	R_EQ
<	R_LT
+	R_PLUS
-	R_MINUS
*	R_MULTIPLY
/	R_DEVIDE
>	R_GT
≤	R_LE
≥	R_GE
=	EQU_publication
=	EQU_sample
=	EQU_place
\.


--
-- Data for Name: sinfixes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY sinfixes (v) FROM stdin;
=
<
≠
≤
>
≥
neq
leq
geq
\.


--
-- Data for Name: system; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY system (id, fsn, fen, ftn, fnn, ftrn) FROM stdin;
YL	1	63	1	23	903
\.


--
-- Name: PK_sinfx; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY sinfixes
    ADD CONSTRAINT "PK_sinfx" PRIMARY KEY (v);


--
-- Name: PK_w; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY _w
    ADD CONSTRAINT "PK_w" PRIMARY KEY (nid);


--
-- Name: dt_PK; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dt
    ADD CONSTRAINT "dt_PK" PRIMARY KEY (id);


--
-- Name: dts_PK; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dts
    ADD CONSTRAINT "dts_PK" PRIMARY KEY (tid, nid);


--
-- Name: e_PK; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT "e_PK" PRIMARY KEY (id);


--
-- Name: fmtv_pk; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY fm_tv
    ADD CONSTRAINT fmtv_pk PRIMARY KEY (t);


--
-- Name: infx_PK; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY infixes
    ADD CONSTRAINT "infx_PK" PRIMARY KEY (v, ref_f);


--
-- Name: s_PK; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY system
    ADD CONSTRAINT "s_PK" PRIMARY KEY (id);


--
-- Name: dt_PKI; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX "dt_PKI" ON dt USING btree (id);


--
-- Name: ein_uniq; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX ein_uniq ON entities USING btree (ein);


--
-- Name: INDEX ein_uniq; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON INDEX ein_uniq IS 'для уникальности ein';


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

