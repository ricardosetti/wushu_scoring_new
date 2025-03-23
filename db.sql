--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

-- Started on 2025-03-21 14:34:15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 4958 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 16389)
-- Name: deductions; Type: TABLE; Schema: public; Owner: wushu
--

CREATE TABLE public.deductions (
    deduction_id integer NOT NULL,
    deduction_category text NOT NULL,
    deduction_criteria text NOT NULL,
    deduction_description text NOT NULL,
    deduction_value numeric(3,1) NOT NULL,
    deduction_code integer,
    CONSTRAINT deduction_code_range CHECK (((deduction_code >= 1) AND (deduction_code <= 1000))),
    CONSTRAINT deductions_deduction_value_check CHECK (((deduction_value >= 0.0) AND (deduction_value <= 5.0)))
);


ALTER TABLE public.deductions OWNER TO wushu;

--
-- TOC entry 218 (class 1259 OID 16397)
-- Name: deductions_deduction_id_seq; Type: SEQUENCE; Schema: public; Owner: wushu
--

CREATE SEQUENCE public.deductions_deduction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.deductions_deduction_id_seq OWNER TO wushu;

--
-- TOC entry 4959 (class 0 OID 0)
-- Dependencies: 218
-- Name: deductions_deduction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.deductions_deduction_id_seq OWNED BY public.deductions.deduction_id;


--
-- TOC entry 231 (class 1259 OID 16500)
-- Name: divisions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.divisions (
    id integer NOT NULL,
    division_name character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    active boolean DEFAULT false NOT NULL
);


ALTER TABLE public.divisions OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16499)
-- Name: divisions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.divisions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.divisions_id_seq OWNER TO postgres;

--
-- TOC entry 4960 (class 0 OID 0)
-- Dependencies: 230
-- Name: divisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.divisions_id_seq OWNED BY public.divisions.id;


--
-- TOC entry 219 (class 1259 OID 16398)
-- Name: participant_deductions; Type: TABLE; Schema: public; Owner: wushu
--

CREATE TABLE public.participant_deductions (
    id integer NOT NULL,
    participant_id integer,
    deduction_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    judge character varying(2),
    division_id integer,
    CONSTRAINT participant_deductions_judge_check CHECK (((judge)::text = ANY (ARRAY[('A1'::character varying)::text, ('A2'::character varying)::text])))
);


ALTER TABLE public.participant_deductions OWNER TO wushu;

--
-- TOC entry 220 (class 1259 OID 16403)
-- Name: participant_deductions_id_seq; Type: SEQUENCE; Schema: public; Owner: wushu
--

CREATE SEQUENCE public.participant_deductions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.participant_deductions_id_seq OWNER TO wushu;

--
-- TOC entry 4961 (class 0 OID 0)
-- Dependencies: 220
-- Name: participant_deductions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.participant_deductions_id_seq OWNED BY public.participant_deductions.id;


--
-- TOC entry 221 (class 1259 OID 16404)
-- Name: participants; Type: TABLE; Schema: public; Owner: wushu
--

CREATE TABLE public.participants (
    id integer NOT NULL,
    school_id integer,
    first_name character varying(100),
    middle_name character varying(100),
    last_name character varying(100),
    birthdate date,
    height_feet integer,
    height_inches integer,
    weight numeric(5,2),
    gender character(1),
    phone character varying(20),
    emergency_contact_name character varying(100),
    emergency_contact_phone character varying(20),
    street character varying(255),
    city character varying(100),
    state character varying(100),
    country character varying(100),
    zip_code character varying(20),
    updated_at timestamp without time zone,
    participant_rank character varying(30),
    CONSTRAINT participants_gender_check CHECK ((gender = ANY (ARRAY['M'::bpchar, 'F'::bpchar, 'O'::bpchar])))
);


ALTER TABLE public.participants OWNER TO wushu;

--
-- TOC entry 222 (class 1259 OID 16409)
-- Name: participants_id_seq; Type: SEQUENCE; Schema: public; Owner: wushu
--

CREATE SEQUENCE public.participants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.participants_id_seq OWNER TO wushu;

--
-- TOC entry 4963 (class 0 OID 0)
-- Dependencies: 222
-- Name: participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.participants_id_seq OWNED BY public.participants.id;


--
-- TOC entry 223 (class 1259 OID 16410)
-- Name: published_scores; Type: TABLE; Schema: public; Owner: wushu
--

CREATE TABLE public.published_scores (
    id integer NOT NULL,
    participant_id integer NOT NULL,
    judge character varying(10) NOT NULL,
    score numeric(3,1) NOT NULL,
    published_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    division_id integer,
    CONSTRAINT published_scores_judge_check CHECK (((judge)::text = ANY (ARRAY[('A1'::character varying)::text, ('A2'::character varying)::text, ('B1'::character varying)::text, ('B2'::character varying)::text, ('FinalA'::character varying)::text, ('FinalB'::character varying)::text, ('Final'::character varying)::text]))),
    CONSTRAINT published_scores_score_check CHECK (((score >= (0)::numeric) AND (score <= (10)::numeric)))
);


ALTER TABLE public.published_scores OWNER TO wushu;

--
-- TOC entry 224 (class 1259 OID 16416)
-- Name: published_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: wushu
--

CREATE SEQUENCE public.published_scores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.published_scores_id_seq OWNER TO wushu;

--
-- TOC entry 4964 (class 0 OID 0)
-- Dependencies: 224
-- Name: published_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.published_scores_id_seq OWNED BY public.published_scores.id;


--
-- TOC entry 229 (class 1259 OID 16435)
-- Name: schools; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schools (
    id integer NOT NULL,
    school_name character varying(255) NOT NULL,
    school_address text,
    school_contact character varying(255),
    school_phone character varying(20),
    school_logo bytea,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.schools OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16434)
-- Name: schools_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.schools_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.schools_id_seq OWNER TO postgres;

--
-- TOC entry 4965 (class 0 OID 0)
-- Dependencies: 228
-- Name: schools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.schools_id_seq OWNED BY public.schools.id;


--
-- TOC entry 225 (class 1259 OID 16417)
-- Name: scores; Type: TABLE; Schema: public; Owner: wushu
--

CREATE TABLE public.scores (
    id integer NOT NULL,
    participant_id integer,
    judge character varying(10) NOT NULL,
    score numeric(3,1) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    division_id integer,
    CONSTRAINT scores_judge_check CHECK (((judge)::text = ANY (ARRAY[('A1'::character varying)::text, ('A2'::character varying)::text, ('B1'::character varying)::text, ('B2'::character varying)::text, ('FinalA'::character varying)::text, ('FinalB'::character varying)::text, ('Final'::character varying)::text]))),
    CONSTRAINT scores_score_check CHECK (((score >= (0)::numeric) AND (score <= (10)::numeric)))
);


ALTER TABLE public.scores OWNER TO wushu;

--
-- TOC entry 226 (class 1259 OID 16423)
-- Name: scores_id_seq; Type: SEQUENCE; Schema: public; Owner: wushu
--

CREATE SEQUENCE public.scores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.scores_id_seq OWNER TO wushu;

--
-- TOC entry 4966 (class 0 OID 0)
-- Dependencies: 226
-- Name: scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.scores_id_seq OWNED BY public.scores.id;


--
-- TOC entry 227 (class 1259 OID 16424)
-- Name: tournament_details; Type: TABLE; Schema: public; Owner: wushu
--

CREATE TABLE public.tournament_details (
    argument character varying(50) NOT NULL,
    value integer NOT NULL
);


ALTER TABLE public.tournament_details OWNER TO wushu;

--
-- TOC entry 232 (class 1259 OID 16510)
-- Name: tournament_participants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_participants (
    participant_id integer NOT NULL,
    division_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tournament_participants OWNER TO postgres;

--
-- TOC entry 4733 (class 2604 OID 16427)
-- Name: deductions deduction_id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.deductions ALTER COLUMN deduction_id SET DEFAULT nextval('public.deductions_deduction_id_seq'::regclass);


--
-- TOC entry 4744 (class 2604 OID 16503)
-- Name: divisions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.divisions ALTER COLUMN id SET DEFAULT nextval('public.divisions_id_seq'::regclass);


--
-- TOC entry 4734 (class 2604 OID 16428)
-- Name: participant_deductions id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions ALTER COLUMN id SET DEFAULT nextval('public.participant_deductions_id_seq'::regclass);


--
-- TOC entry 4736 (class 2604 OID 16429)
-- Name: participants id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants ALTER COLUMN id SET DEFAULT nextval('public.participants_id_seq'::regclass);


--
-- TOC entry 4737 (class 2604 OID 16430)
-- Name: published_scores id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores ALTER COLUMN id SET DEFAULT nextval('public.published_scores_id_seq'::regclass);


--
-- TOC entry 4741 (class 2604 OID 16438)
-- Name: schools id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schools ALTER COLUMN id SET DEFAULT nextval('public.schools_id_seq'::regclass);


--
-- TOC entry 4739 (class 2604 OID 16431)
-- Name: scores id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores ALTER COLUMN id SET DEFAULT nextval('public.scores_id_seq'::regclass);


--
-- TOC entry 4937 (class 0 OID 16389)
-- Dependencies: 217
-- Data for Name: deductions; Type: TABLE DATA; Schema: public; Owner: wushu
--

COPY public.deductions (deduction_id, deduction_category, deduction_criteria, deduction_description, deduction_value, deduction_code) FROM stdin;
1	Hand Forms/Shape	Fist	* Face of fist uneven\\n* Thumb not pressing on second segment of middle finger	0.1	5
2	Hand Forms/Shape	Sword Finger	* Supporting leg bent\\n* Raised leg bent	0.3	6
3	Hand Forms/Shape	Palm	* Four fingers not straight and together\\n* Thumb is not bent in tightly	0.1	7
4	Hand Forms/Shape	Hook	* Five fingers not pinched together\\n* Wrist not hooked completely	0.1	8
\.


--
-- TOC entry 4951 (class 0 OID 16500)
-- Dependencies: 231
-- Data for Name: divisions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.divisions (id, division_name, created_at, updated_at, active) FROM stdin;
2	Northern Traditional Weapons	2025-03-13 11:02:45.532262	2025-03-13 11:02:45.532262	f
4	Southern Bare Hands	2025-03-19 20:50:03.059138	2025-03-19 20:50:03.059138	f
3	Northern Bare Hands	2025-03-13 11:02:45.532262	2025-03-13 11:02:45.532262	f
1	Southern Traditional Weapons	2025-03-13 11:02:45.532262	2025-03-13 11:02:45.532262	t
\.


--
-- TOC entry 4939 (class 0 OID 16398)
-- Dependencies: 219
-- Data for Name: participant_deductions; Type: TABLE DATA; Schema: public; Owner: wushu
--

COPY public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) FROM stdin;
14	5	1	2025-02-20 03:50:25.40272	A1	1
15	5	1	2025-02-20 03:50:27.762947	A1	1
16	5	3	2025-02-20 03:50:32.296349	A1	1
17	5	2	2025-02-20 03:50:34.330336	A1	1
18	5	1	2025-02-20 20:51:32.04023	A1	1
19	5	1	2025-02-20 20:51:32.046907	A1	1
47	1	2	2025-02-22 02:33:25.724669	A2	1
52	1	1	2025-02-24 02:40:06.190977	A2	1
58	1	2	2025-02-24 02:50:09.821501	A2	1
59	1	2	2025-02-24 02:50:09.828919	A2	1
60	1	2	2025-02-24 02:50:09.833099	A2	1
61	1	1	2025-02-24 02:50:09.837374	A2	1
63	1	1	2025-03-03 01:32:53.831003	A1	1
64	1	1	2025-03-03 01:33:21.721934	A1	1
65	1	1	2025-03-03 01:33:21.726877	A1	1
66	1	1	2025-03-03 01:33:29.629221	A1	1
67	1	1	2025-03-03 01:33:29.634767	A1	1
68	1	1	2025-03-03 01:34:03.850965	A1	1
69	1	1	2025-03-03 01:34:03.85919	A1	1
70	3	2	2025-03-03 01:35:10.579346	A1	1
71	3	3	2025-03-03 01:35:28.668441	A2	1
72	2	1	2025-03-10 19:39:35.846454	A2	1
73	2	3	2025-03-10 19:39:36.015219	A2	1
74	2	1	2025-03-12 21:48:02.679764	A1	1
75	2	3	2025-03-12 21:48:02.688533	A1	1
76	8	3	2025-03-14 00:07:30.744422	A1	1
77	8	2	2025-03-14 00:07:30.807297	A1	1
78	10	3	2025-03-14 23:52:40.727588	A1	1
79	10	4	2025-03-19 17:58:43.857064	A1	1
80	10	4	2025-03-19 20:52:28.407391	A1	1
81	10	4	2025-03-19 20:52:28.427632	A1	1
82	10	4	2025-03-19 20:52:28.44596	A1	1
\.


--
-- TOC entry 4941 (class 0 OID 16404)
-- Dependencies: 221
-- Data for Name: participants; Type: TABLE DATA; Schema: public; Owner: wushu
--

COPY public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank) FROM stdin;
10	8	Rehana	\N	Carre	\N	\N	\N	\N	F	\N	\N	\N	\N	\N	\N	\N	\N	2025-03-13 09:54:46.878039	\N
8	8	Leona	\N	Castillo	\N	\N	\N	\N	F	\N	\N	\N	\N	\N	\N	\N	\N	2025-03-13 09:55:04.691326	\N
1	9	Ralph	\N	Cespedes	\N	\N	\N	\N	M	\N	\N	\N	\N	\N	\N	\N	\N	2025-03-13 09:55:10.520292	\N
7	8	Audrey	\N	Chiang	\N	\N	\N	\N	F	\N	\N	\N	\N	\N	\N	\N	\N	2025-03-13 09:55:25.44711	\N
3	8	Gina	\N	Ku	\N	\N	\N	\N	F	\N	\N	\N	\N	\N	\N	\N	\N	2025-03-13 09:55:37.360592	\N
9	8	Victoria	\N	McKay	\N	\N	\N	\N	F	\N	\N	\N	\N	\N	\N	\N	\N	2025-03-13 09:55:44.382807	\N
6	8	Soveida	\N	Monteiro	\N	\N	\N	\N	F	\N	\N	\N	\N	\N	\N	\N	\N	2025-03-13 09:55:52.304767	\N
2	9	Jarely	\N	Osorio	\N	\N	\N	\N	M	\N	\N	\N	\N	\N	\N	\N	\N	2025-03-13 09:56:01.626954	\N
11	9	Sam	\N	Rodriguez	\N	\N	\N	\N	M	\N	\N	\N	\N	\N	\N	\N	\N	2025-03-13 09:56:10.634019	\N
4	9	Fiorella	\N	Vargas	\N	\N	\N	\N	F	\N	\N	\N	\N	\N	\N	\N	\N	2025-03-13 09:56:18.014433	\N
5	9	Maria	\N	Vargas	\N	\N	\N	\N	F	\N	\N	\N	\N	\N	\N	\N	\N	2025-03-14 23:32:43.266092	\N
\.


--
-- TOC entry 4943 (class 0 OID 16410)
-- Dependencies: 223
-- Data for Name: published_scores; Type: TABLE DATA; Schema: public; Owner: wushu
--

COPY public.published_scores (id, participant_id, judge, score, published_at, division_id) FROM stdin;
43	3	A1	5.0	2025-03-10 19:38:43.321811	\N
44	3	A2	4.7	2025-03-10 19:38:43.322746	\N
45	3	B1	3.3	2025-03-10 19:38:43.323469	\N
46	3	B2	4.4	2025-03-10 19:38:43.324184	\N
47	3	FinalA	4.9	2025-03-10 19:38:43.324863	\N
48	3	FinalB	3.9	2025-03-10 19:38:43.325404	\N
49	3	Final	8.7	2025-03-10 19:38:43.325961	\N
57	2	A1	4.9	2025-03-12 21:49:00.028879	\N
58	2	A2	4.8	2025-03-12 21:49:00.030795	\N
59	2	B1	2.7	2025-03-12 21:49:00.031456	\N
60	2	B2	1.6	2025-03-12 21:49:00.031949	\N
61	2	FinalA	4.9	2025-03-12 21:49:00.032348	\N
62	2	FinalB	2.2	2025-03-12 21:49:00.032697	\N
63	2	Final	7.0	2025-03-12 21:49:00.033041	\N
64	1	A1	4.5	2025-03-13 23:21:34.739058	\N
65	1	A2	5.0	2025-03-13 23:21:34.740714	\N
66	1	B1	4.8	2025-03-13 23:21:34.741473	\N
67	1	B2	4.2	2025-03-13 23:21:34.742174	\N
68	1	FinalA	4.8	2025-03-13 23:21:34.742977	\N
69	1	FinalB	4.5	2025-03-13 23:21:34.743729	\N
70	1	Final	9.3	2025-03-13 23:21:34.744413	\N
71	8	A1	4.6	2025-03-14 00:08:25.612293	\N
72	8	A2	5.0	2025-03-14 00:08:25.625311	\N
73	8	B1	3.5	2025-03-14 00:08:25.626233	\N
74	8	B2	3.5	2025-03-14 00:08:25.6269	\N
75	8	FinalA	4.8	2025-03-14 00:08:25.627551	\N
76	8	FinalB	3.5	2025-03-14 00:08:25.628175	\N
77	8	Final	8.3	2025-03-14 00:08:25.62883	\N
85	10	A1	4.9	2025-03-19 20:53:28.861551	3
86	10	A2	5.0	2025-03-19 20:53:28.86715	3
87	10	B1	3.4	2025-03-19 20:53:28.868685	3
88	10	B2	3.6	2025-03-19 20:53:28.870132	3
89	10	FinalA	5.0	2025-03-19 20:53:28.8716	3
90	10	FinalB	3.5	2025-03-19 20:53:28.872722	3
91	10	Final	8.5	2025-03-19 20:53:28.874037	3
92	8	A1	5.0	2025-03-19 21:05:47.118456	3
93	8	A2	5.0	2025-03-19 21:05:47.170867	3
94	8	B1	1.9	2025-03-19 21:05:47.171714	3
95	8	B2	4.5	2025-03-19 21:05:47.172589	3
96	8	FinalA	5.0	2025-03-19 21:05:47.174016	3
97	8	FinalB	3.2	2025-03-19 21:05:47.175428	3
98	8	Final	8.2	2025-03-19 21:05:47.176814	3
\.


--
-- TOC entry 4949 (class 0 OID 16435)
-- Dependencies: 229
-- Data for Name: schools; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schools (id, school_name, school_address, school_contact, school_phone, school_logo, created_at, updated_at) FROM stdin;
8	Wushu Taekwon-Do Academy	456 U.S. 22 West	Chris Leyesa	(732) 789-4744	\N	2025-03-11 22:54:48.869172	2025-03-11 22:54:48.869172
9	Perth Amboy Martial Arts	165 Smith St	Kevin Torres	(732) 877-9229	\N	2025-03-12 21:50:27.287242	2025-03-15 20:08:42.489086
\.


--
-- TOC entry 4945 (class 0 OID 16417)
-- Dependencies: 225
-- Data for Name: scores; Type: TABLE DATA; Schema: public; Owner: wushu
--

COPY public.scores (id, participant_id, judge, score, created_at, division_id) FROM stdin;
1	4	B1	2.5	2025-02-19 03:21:54.62767	\N
113	1	B1	4.8	2025-02-24 02:47:57.911293	\N
114	1	A1	4.5	2025-02-24 02:49:30.155503	\N
16	3	A2	4.7	2025-02-20 03:17:34.721705	\N
17	5	A2	4.7	2025-02-20 03:41:08.844364	\N
18	5	A1	4.4	2025-02-20 03:41:28.251313	\N
19	5	A1	3.8	2025-02-20 03:50:38.78287	\N
20	5	A1	3.6	2025-02-20 20:51:32.028728	\N
21	5	A1	3.6	2025-02-20 21:39:13.434779	\N
22	5	A1	3.5	2025-02-20 21:39:21.901464	\N
23	5	A1	3.5	2025-02-20 21:39:35.307473	\N
24	5	B1	5.0	2025-02-20 21:40:12.201298	\N
25	5	A1	3.5	2025-02-20 21:40:21.336875	\N
26	5	A2	4.7	2025-02-20 21:40:32.355039	\N
27	5	A2	4.6	2025-02-20 21:40:41.977042	\N
28	5	A2	4.6	2025-02-20 21:40:47.843202	\N
29	5	A2	4.6	2025-02-20 21:43:50.953652	\N
30	5	A2	4.6	2025-02-20 22:06:17.449775	\N
31	5	A2	4.6	2025-02-20 22:06:27.223383	\N
32	5	A2	4.2	2025-02-20 22:06:54.365685	\N
33	2	B1	2.7	2025-02-21 01:59:41.266939	\N
34	2	B1	2.7	2025-02-21 02:10:04.042637	\N
35	2	B1	2.7	2025-02-21 02:10:08.49486	\N
36	2	B1	2.7	2025-02-21 02:10:43.269568	\N
37	2	B1	2.7	2025-02-21 02:10:51.850681	\N
38	2	B1	2.7	2025-02-21 02:11:13.602577	\N
39	2	B1	2.7	2025-02-21 02:12:03.555103	\N
40	2	B1	2.7	2025-02-21 02:12:32.328096	\N
41	2	B1	2.7	2025-02-21 02:12:49.99917	\N
42	2	B1	2.7	2025-02-21 02:32:58.548029	\N
43	2	B1	2.7	2025-02-21 02:42:45.337306	\N
44	4	B1	2.5	2025-02-21 02:42:50.94866	\N
45	4	A1	4.6	2025-02-21 02:43:08.267163	\N
46	4	A1	4.6	2025-02-21 02:43:33.394167	\N
47	4	A1	4.3	2025-02-21 02:44:00.823248	\N
48	4	A1	4.0	2025-02-21 02:44:16.385858	\N
49	4	A1	3.7	2025-02-21 02:44:30.943892	\N
50	4	A1	3.7	2025-02-21 02:44:47.154845	\N
51	4	A1	3.7	2025-02-21 02:45:08.259965	\N
52	4	B1	2.5	2025-02-21 02:55:40.715161	\N
53	4	B2	5.0	2025-02-21 02:55:53.203552	\N
54	4	B2	1.1	2025-02-21 02:55:57.83578	\N
55	2	A1	4.9	2025-02-21 02:56:24.495592	\N
56	2	A1	4.9	2025-02-21 02:56:30.517538	\N
57	2	A1	4.9	2025-02-21 03:02:57.159905	\N
58	2	A1	4.6	2025-02-21 03:03:07.87757	\N
59	2	A1	4.5	2025-02-21 03:04:59.379483	\N
132	1	A2	5.0	2025-02-24 03:17:16.449432	\N
133	1	FinalA	4.8	2025-02-24 03:17:21.794577	\N
134	1	FinalB	4.5	2025-02-24 03:17:21.800858	\N
135	1	Final	9.3	2025-02-24 03:17:21.806532	\N
136	1	FinalA	4.8	2025-02-26 02:18:54.690659	\N
137	1	FinalB	4.5	2025-02-26 02:18:54.70433	\N
138	1	Final	9.3	2025-02-26 02:18:54.709079	\N
139	1	A1	4.4	2025-02-26 18:19:01.232335	\N
140	1	FinalA	4.8	2025-02-26 18:19:15.486227	\N
141	1	FinalB	4.5	2025-02-26 18:19:15.494091	\N
142	1	Final	9.3	2025-02-26 18:19:15.49854	\N
143	1	A1	4.4	2025-03-03 01:32:39.274741	\N
144	1	A1	4.3	2025-03-03 01:32:53.824106	\N
145	1	A1	4.2	2025-03-03 01:33:21.711892	\N
146	1	A1	4.2	2025-03-03 01:33:29.620047	\N
147	1	A1	4.2	2025-03-03 01:34:03.83641	\N
148	3	A1	5.0	2025-03-03 01:34:34.925925	\N
149	3	A1	4.7	2025-03-03 01:35:10.56756	\N
150	3	A2	4.6	2025-03-03 01:35:28.659181	\N
151	3	B1	3.3	2025-03-03 01:35:39.991816	\N
152	3	B2	4.4	2025-03-03 01:35:48.813009	\N
153	3	FinalA	4.9	2025-03-03 01:36:15.452257	\N
154	3	FinalB	3.9	2025-03-03 01:36:15.461904	\N
155	3	Final	8.7	2025-03-03 01:36:15.466109	\N
112	1	B2	4.2	2025-02-24 02:47:08.930516	\N
156	3	FinalA	4.9	2025-03-10 19:29:41.276868	\N
157	3	FinalB	3.9	2025-03-10 19:29:41.285205	\N
158	3	Final	8.7	2025-03-10 19:29:41.288305	\N
159	1	B1	2.3	2025-03-10 19:37:59.821142	\N
160	2	A2	4.8	2025-03-10 19:39:35.828373	\N
161	2	B2	1.6	2025-03-10 19:39:49.440975	\N
162	2	FinalA	4.9	2025-03-10 19:39:57.501757	\N
163	2	FinalB	2.2	2025-03-10 19:39:57.517475	\N
164	2	Final	7.0	2025-03-10 19:39:57.521781	\N
165	2	A1	4.3	2025-03-12 21:48:02.655828	\N
166	2	B1	4.2	2025-03-12 21:48:22.925665	\N
167	2	FinalA	4.9	2025-03-12 21:48:43.953993	\N
168	2	FinalB	2.2	2025-03-12 21:48:43.969926	\N
169	2	Final	7.0	2025-03-12 21:48:43.973678	\N
170	2	FinalA	4.9	2025-03-13 14:26:25.461621	\N
171	2	FinalB	2.2	2025-03-13 14:26:25.479522	\N
172	2	Final	7.0	2025-03-13 14:26:25.483493	\N
173	1	FinalA	4.8	2025-03-13 23:21:32.506411	\N
174	1	FinalB	4.5	2025-03-13 23:21:32.525847	\N
175	1	Final	9.3	2025-03-13 23:21:32.529895	\N
176	8	A1	4.6	2025-03-14 00:07:30.724634	\N
177	8	A2	5.0	2025-03-14 00:07:48.792426	\N
178	8	B1	3.5	2025-03-14 00:08:00.856589	\N
179	8	B2	3.5	2025-03-14 00:08:06.640831	\N
180	8	FinalA	4.8	2025-03-14 00:08:21.82302	\N
181	8	FinalB	3.5	2025-03-14 00:08:21.826899	\N
182	8	Final	8.3	2025-03-14 00:08:21.831083	\N
183	10	A1	4.9	2025-03-14 23:52:40.704526	\N
184	10	A1	4.9	2025-03-19 17:58:43.821901	3
185	10	A2	5.0	2025-03-19 17:59:56.969606	3
186	10	B1	3.4	2025-03-19 18:00:01.423884	3
187	10	B2	3.6	2025-03-19 18:00:05.731879	3
188	10	FinalA	5.0	2025-03-19 18:00:10.641921	3
189	10	FinalB	3.5	2025-03-19 18:00:10.648276	3
190	10	Final	8.5	2025-03-19 18:00:10.651747	3
191	10	A1	4.6	2025-03-19 20:52:28.390195	3
192	10	A2	5.0	2025-03-19 20:52:48.88037	3
193	10	B1	3.9	2025-03-19 20:52:56.003567	3
194	10	B2	3.6	2025-03-19 20:52:59.389902	3
195	10	FinalA	5.0	2025-03-19 20:53:15.677168	3
196	10	FinalB	3.5	2025-03-19 20:53:15.736831	3
197	10	Final	8.5	2025-03-19 20:53:15.746471	3
198	10	A1	4.6	2025-03-19 20:54:25.36415	3
199	10	FinalA	5.0	2025-03-19 21:01:13.236387	3
200	10	FinalB	3.5	2025-03-19 21:01:13.244433	3
201	10	Final	8.5	2025-03-19 21:01:13.252013	3
202	8	A1	5.0	2025-03-19 21:02:57.978904	3
203	8	A2	5.0	2025-03-19 21:03:10.497461	3
204	8	B1	1.9	2025-03-19 21:03:18.515664	3
205	8	B2	4.5	2025-03-19 21:03:23.887938	3
206	8	FinalA	5.0	2025-03-19 21:03:45.421069	3
207	8	FinalB	3.2	2025-03-19 21:03:45.477476	3
208	8	Final	8.2	2025-03-19 21:03:45.484761	3
209	8	FinalA	5.0	2025-03-19 21:04:13.515462	3
210	8	FinalB	3.2	2025-03-19 21:04:13.526207	3
211	8	Final	8.2	2025-03-19 21:04:13.534066	3
212	8	B1	3.9	2025-03-19 21:05:25.067833	3
\.


--
-- TOC entry 4947 (class 0 OID 16424)
-- Dependencies: 227
-- Data for Name: tournament_details; Type: TABLE DATA; Schema: public; Owner: wushu
--

COPY public.tournament_details (argument, value) FROM stdin;
JudgeA2_open	1
JudgeB2_open	1
JudgeB1_open	1
JudgeA1_open	1
Active_ID	1
OnDeck_ID	8
Judge_A1	0
Judge_A2	0
Judge_B1	0
Judge_B2	0
\.


--
-- TOC entry 4952 (class 0 OID 16510)
-- Dependencies: 232
-- Data for Name: tournament_participants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tournament_participants (participant_id, division_id, created_at, updated_at) FROM stdin;
10	3	2025-03-13 14:32:05.034488	2025-03-13 14:32:05.034488
10	1	2025-03-13 14:32:09.698217	2025-03-13 14:32:09.698217
8	3	2025-03-14 00:06:03.236989	2025-03-14 00:06:03.236989
1	3	2025-03-14 23:30:55.721469	2025-03-14 23:30:55.721469
1	1	2025-03-14 23:30:58.481066	2025-03-14 23:30:58.481066
7	1	2025-03-14 23:31:04.998472	2025-03-14 23:31:04.998472
3	3	2025-03-14 23:31:19.075999	2025-03-14 23:31:19.075999
3	2	2025-03-14 23:31:20.989105	2025-03-14 23:31:20.989105
3	1	2025-03-14 23:31:22.862934	2025-03-14 23:31:22.862934
9	2	2025-03-14 23:31:27.71688	2025-03-14 23:31:27.71688
6	2	2025-03-14 23:31:34.07531	2025-03-14 23:31:34.07531
6	3	2025-03-14 23:31:36.820649	2025-03-14 23:31:36.820649
2	3	2025-03-14 23:31:51.071328	2025-03-14 23:31:51.071328
2	1	2025-03-14 23:31:59.126476	2025-03-14 23:31:59.126476
11	3	2025-03-14 23:32:04.143814	2025-03-14 23:32:04.143814
11	1	2025-03-14 23:32:06.235451	2025-03-14 23:32:06.235451
4	2	2025-03-14 23:32:11.704543	2025-03-14 23:32:11.704543
5	1	2025-03-14 23:32:16.008266	2025-03-14 23:32:16.008266
5	4	2025-03-19 20:50:17.639216	2025-03-19 20:50:17.639216
\.


--
-- TOC entry 4967 (class 0 OID 0)
-- Dependencies: 218
-- Name: deductions_deduction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.deductions_deduction_id_seq', 4, true);


--
-- TOC entry 4968 (class 0 OID 0)
-- Dependencies: 230
-- Name: divisions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.divisions_id_seq', 4, true);


--
-- TOC entry 4969 (class 0 OID 0)
-- Dependencies: 220
-- Name: participant_deductions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.participant_deductions_id_seq', 82, true);


--
-- TOC entry 4970 (class 0 OID 0)
-- Dependencies: 222
-- Name: participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.participants_id_seq', 11, true);


--
-- TOC entry 4971 (class 0 OID 0)
-- Dependencies: 224
-- Name: published_scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.published_scores_id_seq', 98, true);


--
-- TOC entry 4972 (class 0 OID 0)
-- Dependencies: 228
-- Name: schools_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schools_id_seq', 10, true);


--
-- TOC entry 4973 (class 0 OID 0)
-- Dependencies: 226
-- Name: scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.scores_id_seq', 212, true);


--
-- TOC entry 4759 (class 2606 OID 16463)
-- Name: deductions deductions_deduction_code_key; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.deductions
    ADD CONSTRAINT deductions_deduction_code_key UNIQUE (deduction_code);


--
-- TOC entry 4761 (class 2606 OID 16465)
-- Name: deductions deductions_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.deductions
    ADD CONSTRAINT deductions_pkey PRIMARY KEY (deduction_id);


--
-- TOC entry 4776 (class 2606 OID 16509)
-- Name: divisions divisions_division_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.divisions
    ADD CONSTRAINT divisions_division_name_key UNIQUE (division_name);


--
-- TOC entry 4778 (class 2606 OID 16507)
-- Name: divisions divisions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.divisions
    ADD CONSTRAINT divisions_pkey PRIMARY KEY (id);


--
-- TOC entry 4763 (class 2606 OID 16467)
-- Name: participant_deductions participant_deductions_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions
    ADD CONSTRAINT participant_deductions_pkey PRIMARY KEY (id);


--
-- TOC entry 4765 (class 2606 OID 16461)
-- Name: participants participants_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_pkey PRIMARY KEY (id);


--
-- TOC entry 4767 (class 2606 OID 16469)
-- Name: published_scores published_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores
    ADD CONSTRAINT published_scores_pkey PRIMARY KEY (id);


--
-- TOC entry 4774 (class 2606 OID 16444)
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- TOC entry 4769 (class 2606 OID 16471)
-- Name: scores scores_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_pkey PRIMARY KEY (id);


--
-- TOC entry 4771 (class 2606 OID 16433)
-- Name: tournament_details tournament_details_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.tournament_details
    ADD CONSTRAINT tournament_details_pkey PRIMARY KEY (argument);


--
-- TOC entry 4780 (class 2606 OID 16516)
-- Name: tournament_participants tournament_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_pkey PRIMARY KEY (participant_id, division_id);


--
-- TOC entry 4772 (class 1259 OID 16445)
-- Name: idx_schools_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_schools_name ON public.schools USING btree (school_name);


--
-- TOC entry 4784 (class 2606 OID 16493)
-- Name: participants fk_school; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT fk_school FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 4781 (class 2606 OID 16472)
-- Name: participant_deductions participant_deductions_deduction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions
    ADD CONSTRAINT participant_deductions_deduction_id_fkey FOREIGN KEY (deduction_id) REFERENCES public.deductions(deduction_id) ON DELETE CASCADE;


--
-- TOC entry 4782 (class 2606 OID 16540)
-- Name: participant_deductions participant_deductions_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions
    ADD CONSTRAINT participant_deductions_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE SET NULL;


--
-- TOC entry 4783 (class 2606 OID 16477)
-- Name: participant_deductions participant_deductions_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions
    ADD CONSTRAINT participant_deductions_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 4785 (class 2606 OID 16455)
-- Name: participants participants_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 4786 (class 2606 OID 16534)
-- Name: published_scores published_scores_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores
    ADD CONSTRAINT published_scores_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE SET NULL;


--
-- TOC entry 4787 (class 2606 OID 16482)
-- Name: published_scores published_scores_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores
    ADD CONSTRAINT published_scores_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 4788 (class 2606 OID 16529)
-- Name: scores scores_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE SET NULL;


--
-- TOC entry 4789 (class 2606 OID 16487)
-- Name: scores scores_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 4790 (class 2606 OID 16522)
-- Name: tournament_participants tournament_participants_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE CASCADE;


--
-- TOC entry 4791 (class 2606 OID 16517)
-- Name: tournament_participants tournament_participants_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 4962 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE participants; Type: ACL; Schema: public; Owner: wushu
--

GRANT ALL ON TABLE public.participants TO postgres;


-- Completed on 2025-03-21 14:34:15

--
-- PostgreSQL database dump complete
--

