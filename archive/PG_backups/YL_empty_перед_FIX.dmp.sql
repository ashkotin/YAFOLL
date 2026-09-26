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

COMMENT ON COLUMN entities.id IS 'См. YAFOLL. БД. entities';


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

COMMENT ON COLUMN entities.type IS 'тип записи см. YAFOLL. БД. entities';


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
0000000002	0000000001	e_m	\N	!	1
0000000003	0000000001	Number	\N	0	2
0000000004	0000000001	e_m	\N	!	3
0000000005	\N	Statements	#st	\N	\N
0000000001	0000000005	Statement	st-6	\N	1
\.


--
-- Data for Name: dts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY dts (tid, nid, up, sid, rid, v, irn, ref, flg, flg2, type) FROM stdin;
\.


--
-- Data for Name: entities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY entities (id, ref_r, def_id, expr, type, ref_arg, fp_id, prime, ein, sers, tid, cf) FROM stdin;
\.


--
-- Data for Name: fm_tv; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY fm_tv (t, v) FROM stdin;
\.


--
-- Data for Name: infixes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY infixes (v, ref_f) FROM stdin;
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
YL	1	1	1	6	1
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

