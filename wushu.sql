--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

-- Started on 2025-03-02 22:48:38

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 223 (class 1259 OID 16421)
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
-- TOC entry 222 (class 1259 OID 16420)
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
-- TOC entry 4913 (class 0 OID 0)
-- Dependencies: 222
-- Name: deductions_deduction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.deductions_deduction_id_seq OWNED BY public.deductions.deduction_id;


--
-- TOC entry 225 (class 1259 OID 16431)
-- Name: participant_deductions; Type: TABLE; Schema: public; Owner: wushu
--

CREATE TABLE public.participant_deductions (
    id integer NOT NULL,
    participant_id integer,
    deduction_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    judge character varying(2),
    CONSTRAINT participant_deductions_judge_check CHECK (((judge)::text = ANY ((ARRAY['A1'::character varying, 'A2'::character varying])::text[])))
);


ALTER TABLE public.participant_deductions OWNER TO wushu;

--
-- TOC entry 224 (class 1259 OID 16430)
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
-- TOC entry 4914 (class 0 OID 0)
-- Dependencies: 224
-- Name: participant_deductions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.participant_deductions_id_seq OWNED BY public.participant_deductions.id;


--
-- TOC entry 218 (class 1259 OID 16392)
-- Name: participants; Type: TABLE; Schema: public; Owner: wushu
--

CREATE TABLE public.participants (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    school character varying(255) NOT NULL,
    division character varying(100) NOT NULL
);


ALTER TABLE public.participants OWNER TO wushu;

--
-- TOC entry 217 (class 1259 OID 16391)
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
-- TOC entry 4915 (class 0 OID 0)
-- Dependencies: 217
-- Name: participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.participants_id_seq OWNED BY public.participants.id;


--
-- TOC entry 227 (class 1259 OID 16460)
-- Name: published_scores; Type: TABLE; Schema: public; Owner: wushu
--

CREATE TABLE public.published_scores (
    id integer NOT NULL,
    participant_id integer NOT NULL,
    judge character varying(10) NOT NULL,
    score numeric(3,1) NOT NULL,
    published_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT published_scores_judge_check CHECK (((judge)::text = ANY ((ARRAY['A1'::character varying, 'A2'::character varying, 'B1'::character varying, 'B2'::character varying, 'FinalA'::character varying, 'FinalB'::character varying, 'Final'::character varying])::text[]))),
    CONSTRAINT published_scores_score_check CHECK (((score >= (0)::numeric) AND (score <= (10)::numeric)))
);


ALTER TABLE public.published_scores OWNER TO wushu;

--
-- TOC entry 226 (class 1259 OID 16459)
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
-- TOC entry 4916 (class 0 OID 0)
-- Dependencies: 226
-- Name: published_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.published_scores_id_seq OWNED BY public.published_scores.id;


--
-- TOC entry 220 (class 1259 OID 16401)
-- Name: scores; Type: TABLE; Schema: public; Owner: wushu
--

CREATE TABLE public.scores (
    id integer NOT NULL,
    participant_id integer,
    judge character varying(10) NOT NULL,
    score numeric(3,1) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT scores_judge_check CHECK (((judge)::text = ANY ((ARRAY['A1'::character varying, 'A2'::character varying, 'B1'::character varying, 'B2'::character varying, 'FinalA'::character varying, 'FinalB'::character varying, 'Final'::character varying])::text[]))),
    CONSTRAINT scores_score_check CHECK (((score >= (0)::numeric) AND (score <= (10)::numeric)))
);


ALTER TABLE public.scores OWNER TO wushu;

--
-- TOC entry 219 (class 1259 OID 16400)
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
-- TOC entry 4917 (class 0 OID 0)
-- Dependencies: 219
-- Name: scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.scores_id_seq OWNED BY public.scores.id;


--
-- TOC entry 221 (class 1259 OID 16415)
-- Name: tournament_details; Type: TABLE; Schema: public; Owner: wushu
--

CREATE TABLE public.tournament_details (
    argument character varying(50) NOT NULL,
    value integer NOT NULL
);


ALTER TABLE public.tournament_details OWNER TO wushu;

--
-- TOC entry 4722 (class 2604 OID 16424)
-- Name: deductions deduction_id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.deductions ALTER COLUMN deduction_id SET DEFAULT nextval('public.deductions_deduction_id_seq'::regclass);


--
-- TOC entry 4723 (class 2604 OID 16434)
-- Name: participant_deductions id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions ALTER COLUMN id SET DEFAULT nextval('public.participant_deductions_id_seq'::regclass);


--
-- TOC entry 4719 (class 2604 OID 16395)
-- Name: participants id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants ALTER COLUMN id SET DEFAULT nextval('public.participants_id_seq'::regclass);


--
-- TOC entry 4725 (class 2604 OID 16463)
-- Name: published_scores id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores ALTER COLUMN id SET DEFAULT nextval('public.published_scores_id_seq'::regclass);


--
-- TOC entry 4720 (class 2604 OID 16404)
-- Name: scores id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores ALTER COLUMN id SET DEFAULT nextval('public.scores_id_seq'::regclass);


--
-- TOC entry 4903 (class 0 OID 16421)
-- Dependencies: 223
-- Data for Name: deductions; Type: TABLE DATA; Schema: public; Owner: wushu
--

COPY public.deductions (deduction_id, deduction_category, deduction_criteria, deduction_description, deduction_value, deduction_code) FROM stdin;
1	Hand Forms/Shape	Fist	* Face of fist uneven\n* Thumb not pressing on second segment of middle finger	0.1	5
2	Hand Forms/Shape	Sword Finger	* Supporting leg bent\n* Raised leg bent	0.3	6
3	Hand Forms/Shape	Palm	* Four fingers not straight and together\n* Thumb is not bent in tightly	0.1	7
4	Hand Forms/Shape	Hook	* Five fingers not pinched together\n* Wrist not hooked completely	0.1	8
\.


--
-- TOC entry 4905 (class 0 OID 16431)
-- Dependencies: 225
-- Data for Name: participant_deductions; Type: TABLE DATA; Schema: public; Owner: wushu
--

COPY public.participant_deductions (id, participant_id, deduction_id, created_at, judge) FROM stdin;
14	5	1	2025-02-20 03:50:25.40272	A1
15	5	1	2025-02-20 03:50:27.762947	A1
16	5	3	2025-02-20 03:50:32.296349	A1
17	5	2	2025-02-20 03:50:34.330336	A1
18	5	1	2025-02-20 20:51:32.04023	A1
19	5	1	2025-02-20 20:51:32.046907	A1
47	1	2	2025-02-22 02:33:25.724669	A2
52	1	1	2025-02-24 02:40:06.190977	A2
58	1	2	2025-02-24 02:50:09.821501	A2
59	1	2	2025-02-24 02:50:09.828919	A2
60	1	2	2025-02-24 02:50:09.833099	A2
61	1	1	2025-02-24 02:50:09.837374	A2
63	1	1	2025-03-03 01:32:53.831003	A1
64	1	1	2025-03-03 01:33:21.721934	A1
65	1	1	2025-03-03 01:33:21.726877	A1
66	1	1	2025-03-03 01:33:29.629221	A1
67	1	1	2025-03-03 01:33:29.634767	A1
68	1	1	2025-03-03 01:34:03.850965	A1
69	1	1	2025-03-03 01:34:03.85919	A1
70	3	2	2025-03-03 01:35:10.579346	A1
71	3	3	2025-03-03 01:35:28.668441	A2
\.


--
-- TOC entry 4898 (class 0 OID 16392)
-- Dependencies: 218
-- Data for Name: participants; Type: TABLE DATA; Schema: public; Owner: wushu
--

COPY public.participants (id, name, school, division) FROM stdin;
1	Ricardo Setti	WTA	Southern Traditional Weapon
2	Alice Lobo	WTA	Northern Spear
3	Nolan Leyesa	WTA	Northern Bare Hands
4	Kevin Torres	Perth Amboy Martial Arts	Northern Bare Hands
5	Scott Raff	Perth Amboy Martial Arts	Southern Traditional Weapon
\.


--
-- TOC entry 4907 (class 0 OID 16460)
-- Dependencies: 227
-- Data for Name: published_scores; Type: TABLE DATA; Schema: public; Owner: wushu
--

COPY public.published_scores (id, participant_id, judge, score, published_at) FROM stdin;
8	1	A1	4.5	2025-02-26 18:19:18.240986
9	1	A2	5.0	2025-02-26 18:19:18.24275
10	1	B1	4.8	2025-02-26 18:19:18.244049
11	1	B2	4.2	2025-02-26 18:19:18.24517
12	1	FinalA	4.8	2025-02-26 18:19:18.246448
13	1	FinalB	4.5	2025-02-26 18:19:18.247597
14	1	Final	9.3	2025-02-26 18:19:18.248569
15	3	A1	5.0	2025-03-03 01:36:17.784451
16	3	A2	4.7	2025-03-03 01:36:17.788431
17	3	B1	3.3	2025-03-03 01:36:17.789548
18	3	B2	4.4	2025-03-03 01:36:17.790901
19	3	FinalA	4.9	2025-03-03 01:36:17.79223
20	3	FinalB	3.9	2025-03-03 01:36:17.793416
21	3	Final	8.7	2025-03-03 01:36:17.794417
\.


--
-- TOC entry 4900 (class 0 OID 16401)
-- Dependencies: 220
-- Data for Name: scores; Type: TABLE DATA; Schema: public; Owner: wushu
--

COPY public.scores (id, participant_id, judge, score, created_at) FROM stdin;
1	4	B1	2.5	2025-02-19 03:21:54.62767
113	1	B1	4.8	2025-02-24 02:47:57.911293
114	1	A1	4.5	2025-02-24 02:49:30.155503
16	3	A2	4.7	2025-02-20 03:17:34.721705
17	5	A2	4.7	2025-02-20 03:41:08.844364
18	5	A1	4.4	2025-02-20 03:41:28.251313
19	5	A1	3.8	2025-02-20 03:50:38.78287
20	5	A1	3.6	2025-02-20 20:51:32.028728
21	5	A1	3.6	2025-02-20 21:39:13.434779
22	5	A1	3.5	2025-02-20 21:39:21.901464
23	5	A1	3.5	2025-02-20 21:39:35.307473
24	5	B1	5.0	2025-02-20 21:40:12.201298
25	5	A1	3.5	2025-02-20 21:40:21.336875
26	5	A2	4.7	2025-02-20 21:40:32.355039
27	5	A2	4.6	2025-02-20 21:40:41.977042
28	5	A2	4.6	2025-02-20 21:40:47.843202
29	5	A2	4.6	2025-02-20 21:43:50.953652
30	5	A2	4.6	2025-02-20 22:06:17.449775
31	5	A2	4.6	2025-02-20 22:06:27.223383
32	5	A2	4.2	2025-02-20 22:06:54.365685
33	2	B1	2.7	2025-02-21 01:59:41.266939
34	2	B1	2.7	2025-02-21 02:10:04.042637
35	2	B1	2.7	2025-02-21 02:10:08.49486
36	2	B1	2.7	2025-02-21 02:10:43.269568
37	2	B1	2.7	2025-02-21 02:10:51.850681
38	2	B1	2.7	2025-02-21 02:11:13.602577
39	2	B1	2.7	2025-02-21 02:12:03.555103
40	2	B1	2.7	2025-02-21 02:12:32.328096
41	2	B1	2.7	2025-02-21 02:12:49.99917
42	2	B1	2.7	2025-02-21 02:32:58.548029
43	2	B1	2.7	2025-02-21 02:42:45.337306
44	4	B1	2.5	2025-02-21 02:42:50.94866
45	4	A1	4.6	2025-02-21 02:43:08.267163
46	4	A1	4.6	2025-02-21 02:43:33.394167
47	4	A1	4.3	2025-02-21 02:44:00.823248
48	4	A1	4.0	2025-02-21 02:44:16.385858
49	4	A1	3.7	2025-02-21 02:44:30.943892
50	4	A1	3.7	2025-02-21 02:44:47.154845
51	4	A1	3.7	2025-02-21 02:45:08.259965
52	4	B1	2.5	2025-02-21 02:55:40.715161
53	4	B2	5.0	2025-02-21 02:55:53.203552
54	4	B2	1.1	2025-02-21 02:55:57.83578
55	2	A1	4.9	2025-02-21 02:56:24.495592
56	2	A1	4.9	2025-02-21 02:56:30.517538
57	2	A1	4.9	2025-02-21 03:02:57.159905
58	2	A1	4.6	2025-02-21 03:03:07.87757
59	2	A1	4.5	2025-02-21 03:04:59.379483
132	1	A2	5.0	2025-02-24 03:17:16.449432
133	1	FinalA	4.8	2025-02-24 03:17:21.794577
134	1	FinalB	4.5	2025-02-24 03:17:21.800858
135	1	Final	9.3	2025-02-24 03:17:21.806532
136	1	FinalA	4.8	2025-02-26 02:18:54.690659
137	1	FinalB	4.5	2025-02-26 02:18:54.70433
138	1	Final	9.3	2025-02-26 02:18:54.709079
139	1	A1	4.4	2025-02-26 18:19:01.232335
140	1	FinalA	4.8	2025-02-26 18:19:15.486227
141	1	FinalB	4.5	2025-02-26 18:19:15.494091
142	1	Final	9.3	2025-02-26 18:19:15.49854
143	1	A1	4.4	2025-03-03 01:32:39.274741
144	1	A1	4.3	2025-03-03 01:32:53.824106
145	1	A1	4.2	2025-03-03 01:33:21.711892
146	1	A1	4.2	2025-03-03 01:33:29.620047
147	1	A1	4.2	2025-03-03 01:34:03.83641
148	3	A1	5.0	2025-03-03 01:34:34.925925
149	3	A1	4.7	2025-03-03 01:35:10.56756
150	3	A2	4.6	2025-03-03 01:35:28.659181
151	3	B1	3.3	2025-03-03 01:35:39.991816
152	3	B2	4.4	2025-03-03 01:35:48.813009
153	3	FinalA	4.9	2025-03-03 01:36:15.452257
154	3	FinalB	3.9	2025-03-03 01:36:15.461904
155	3	Final	8.7	2025-03-03 01:36:15.466109
112	1	B2	4.2	2025-02-24 02:47:08.930516
\.


--
-- TOC entry 4901 (class 0 OID 16415)
-- Dependencies: 221
-- Data for Name: tournament_details; Type: TABLE DATA; Schema: public; Owner: wushu
--

COPY public.tournament_details (argument, value) FROM stdin;
JudgeA2_open	1
JudgeB2_open	1
JudgeB1_open	1
JudgeA1_open	1
Active_ID	3
OnDeck_ID	5
Judge_A1	0
Judge_A2	0
Judge_B1	0
Judge_B2	0
\.


--
-- TOC entry 4918 (class 0 OID 0)
-- Dependencies: 222
-- Name: deductions_deduction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.deductions_deduction_id_seq', 4, true);


--
-- TOC entry 4919 (class 0 OID 0)
-- Dependencies: 224
-- Name: participant_deductions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.participant_deductions_id_seq', 71, true);


--
-- TOC entry 4920 (class 0 OID 0)
-- Dependencies: 217
-- Name: participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.participants_id_seq', 5, true);


--
-- TOC entry 4921 (class 0 OID 0)
-- Dependencies: 226
-- Name: published_scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.published_scores_id_seq', 21, true);


--
-- TOC entry 4922 (class 0 OID 0)
-- Dependencies: 219
-- Name: scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.scores_id_seq', 155, true);


--
-- TOC entry 4741 (class 2606 OID 16475)
-- Name: deductions deductions_deduction_code_key; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.deductions
    ADD CONSTRAINT deductions_deduction_code_key UNIQUE (deduction_code);


--
-- TOC entry 4743 (class 2606 OID 16429)
-- Name: deductions deductions_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.deductions
    ADD CONSTRAINT deductions_pkey PRIMARY KEY (deduction_id);


--
-- TOC entry 4745 (class 2606 OID 16437)
-- Name: participant_deductions participant_deductions_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions
    ADD CONSTRAINT participant_deductions_pkey PRIMARY KEY (id);


--
-- TOC entry 4735 (class 2606 OID 16399)
-- Name: participants participants_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_pkey PRIMARY KEY (id);


--
-- TOC entry 4747 (class 2606 OID 16468)
-- Name: published_scores published_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores
    ADD CONSTRAINT published_scores_pkey PRIMARY KEY (id);


--
-- TOC entry 4737 (class 2606 OID 16409)
-- Name: scores scores_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_pkey PRIMARY KEY (id);


--
-- TOC entry 4739 (class 2606 OID 16419)
-- Name: tournament_details tournament_details_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.tournament_details
    ADD CONSTRAINT tournament_details_pkey PRIMARY KEY (argument);


--
-- TOC entry 4749 (class 2606 OID 16443)
-- Name: participant_deductions participant_deductions_deduction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions
    ADD CONSTRAINT participant_deductions_deduction_id_fkey FOREIGN KEY (deduction_id) REFERENCES public.deductions(deduction_id) ON DELETE CASCADE;


--
-- TOC entry 4750 (class 2606 OID 16438)
-- Name: participant_deductions participant_deductions_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions
    ADD CONSTRAINT participant_deductions_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 4751 (class 2606 OID 16469)
-- Name: published_scores published_scores_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores
    ADD CONSTRAINT published_scores_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 4748 (class 2606 OID 16410)
-- Name: scores scores_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


-- Completed on 2025-03-02 22:48:38

--
-- PostgreSQL database dump complete
--

