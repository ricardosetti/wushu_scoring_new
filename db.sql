--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

-- Started on 2025-03-15 20:05:34

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
-- TOC entry 4957 (class 1262 OID 16388)
-- Name: wushu; Type: DATABASE; Schema: -; Owner: wushu
--

CREATE DATABASE wushu WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en-US';


ALTER DATABASE wushu OWNER TO wushu;

\connect wushu

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
-- TOC entry 4936 (class 0 OID 16389)
-- Dependencies: 217
-- Data for Name: deductions; Type: TABLE DATA; Schema: public; Owner: wushu
--

INSERT INTO public.deductions VALUES (1, 'Hand Forms/Shape', 'Fist', '* Face of fist uneven\n* Thumb not pressing on second segment of middle finger', 0.1, 5);
INSERT INTO public.deductions VALUES (2, 'Hand Forms/Shape', 'Sword Finger', '* Supporting leg bent\n* Raised leg bent', 0.3, 6);
INSERT INTO public.deductions VALUES (3, 'Hand Forms/Shape', 'Palm', '* Four fingers not straight and together\n* Thumb is not bent in tightly', 0.1, 7);
INSERT INTO public.deductions VALUES (4, 'Hand Forms/Shape', 'Hook', '* Five fingers not pinched together\n* Wrist not hooked completely', 0.1, 8);


--
-- TOC entry 4950 (class 0 OID 16500)
-- Dependencies: 231
-- Data for Name: divisions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.divisions VALUES (1, 'Southern Traditional Weapons', '2025-03-13 11:02:45.532262', '2025-03-13 11:02:45.532262', false);
INSERT INTO public.divisions VALUES (2, 'Northern Traditional Weapons', '2025-03-13 11:02:45.532262', '2025-03-13 11:02:45.532262', false);
INSERT INTO public.divisions VALUES (3, 'Northern Bare Hands', '2025-03-13 11:02:45.532262', '2025-03-13 11:02:45.532262', true);


--
-- TOC entry 4938 (class 0 OID 16398)
-- Dependencies: 219
-- Data for Name: participant_deductions; Type: TABLE DATA; Schema: public; Owner: wushu
--

INSERT INTO public.participant_deductions VALUES (14, 5, 1, '2025-02-20 03:50:25.40272', 'A1');
INSERT INTO public.participant_deductions VALUES (15, 5, 1, '2025-02-20 03:50:27.762947', 'A1');
INSERT INTO public.participant_deductions VALUES (16, 5, 3, '2025-02-20 03:50:32.296349', 'A1');
INSERT INTO public.participant_deductions VALUES (17, 5, 2, '2025-02-20 03:50:34.330336', 'A1');
INSERT INTO public.participant_deductions VALUES (18, 5, 1, '2025-02-20 20:51:32.04023', 'A1');
INSERT INTO public.participant_deductions VALUES (19, 5, 1, '2025-02-20 20:51:32.046907', 'A1');
INSERT INTO public.participant_deductions VALUES (47, 1, 2, '2025-02-22 02:33:25.724669', 'A2');
INSERT INTO public.participant_deductions VALUES (52, 1, 1, '2025-02-24 02:40:06.190977', 'A2');
INSERT INTO public.participant_deductions VALUES (58, 1, 2, '2025-02-24 02:50:09.821501', 'A2');
INSERT INTO public.participant_deductions VALUES (59, 1, 2, '2025-02-24 02:50:09.828919', 'A2');
INSERT INTO public.participant_deductions VALUES (60, 1, 2, '2025-02-24 02:50:09.833099', 'A2');
INSERT INTO public.participant_deductions VALUES (61, 1, 1, '2025-02-24 02:50:09.837374', 'A2');
INSERT INTO public.participant_deductions VALUES (63, 1, 1, '2025-03-03 01:32:53.831003', 'A1');
INSERT INTO public.participant_deductions VALUES (64, 1, 1, '2025-03-03 01:33:21.721934', 'A1');
INSERT INTO public.participant_deductions VALUES (65, 1, 1, '2025-03-03 01:33:21.726877', 'A1');
INSERT INTO public.participant_deductions VALUES (66, 1, 1, '2025-03-03 01:33:29.629221', 'A1');
INSERT INTO public.participant_deductions VALUES (67, 1, 1, '2025-03-03 01:33:29.634767', 'A1');
INSERT INTO public.participant_deductions VALUES (68, 1, 1, '2025-03-03 01:34:03.850965', 'A1');
INSERT INTO public.participant_deductions VALUES (69, 1, 1, '2025-03-03 01:34:03.85919', 'A1');
INSERT INTO public.participant_deductions VALUES (70, 3, 2, '2025-03-03 01:35:10.579346', 'A1');
INSERT INTO public.participant_deductions VALUES (71, 3, 3, '2025-03-03 01:35:28.668441', 'A2');
INSERT INTO public.participant_deductions VALUES (72, 2, 1, '2025-03-10 19:39:35.846454', 'A2');
INSERT INTO public.participant_deductions VALUES (73, 2, 3, '2025-03-10 19:39:36.015219', 'A2');
INSERT INTO public.participant_deductions VALUES (74, 2, 1, '2025-03-12 21:48:02.679764', 'A1');
INSERT INTO public.participant_deductions VALUES (75, 2, 3, '2025-03-12 21:48:02.688533', 'A1');
INSERT INTO public.participant_deductions VALUES (76, 8, 3, '2025-03-14 00:07:30.744422', 'A1');
INSERT INTO public.participant_deductions VALUES (77, 8, 2, '2025-03-14 00:07:30.807297', 'A1');
INSERT INTO public.participant_deductions VALUES (78, 10, 3, '2025-03-14 23:52:40.727588', 'A1');


--
-- TOC entry 4940 (class 0 OID 16404)
-- Dependencies: 221
-- Data for Name: participants; Type: TABLE DATA; Schema: public; Owner: wushu
--

INSERT INTO public.participants VALUES (10, 8, 'Rehana', NULL, 'Carre', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:54:46.878039', NULL);
INSERT INTO public.participants VALUES (8, 8, 'Leona', NULL, 'Castillo', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:04.691326', NULL);
INSERT INTO public.participants VALUES (1, 9, 'Ralph', NULL, 'Cespedes', NULL, NULL, NULL, NULL, 'M', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:10.520292', NULL);
INSERT INTO public.participants VALUES (7, 8, 'Audrey', NULL, 'Chiang', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:25.44711', NULL);
INSERT INTO public.participants VALUES (3, 8, 'Gina', NULL, 'Ku', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:37.360592', NULL);
INSERT INTO public.participants VALUES (9, 8, 'Victoria', NULL, 'McKay', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:44.382807', NULL);
INSERT INTO public.participants VALUES (6, 8, 'Soveida', NULL, 'Monteiro', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:52.304767', NULL);
INSERT INTO public.participants VALUES (2, 9, 'Jarely', NULL, 'Osorio', NULL, NULL, NULL, NULL, 'M', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:56:01.626954', NULL);
INSERT INTO public.participants VALUES (11, 9, 'Sam', NULL, 'Rodriguez', NULL, NULL, NULL, NULL, 'M', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:56:10.634019', NULL);
INSERT INTO public.participants VALUES (4, 9, 'Fiorella', NULL, 'Vargas', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:56:18.014433', NULL);
INSERT INTO public.participants VALUES (5, 9, 'Maria', NULL, 'Vargas', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-14 23:32:43.266092', NULL);


--
-- TOC entry 4942 (class 0 OID 16410)
-- Dependencies: 223
-- Data for Name: published_scores; Type: TABLE DATA; Schema: public; Owner: wushu
--

INSERT INTO public.published_scores VALUES (43, 3, 'A1', 5.0, '2025-03-10 19:38:43.321811', NULL);
INSERT INTO public.published_scores VALUES (44, 3, 'A2', 4.7, '2025-03-10 19:38:43.322746', NULL);
INSERT INTO public.published_scores VALUES (45, 3, 'B1', 3.3, '2025-03-10 19:38:43.323469', NULL);
INSERT INTO public.published_scores VALUES (46, 3, 'B2', 4.4, '2025-03-10 19:38:43.324184', NULL);
INSERT INTO public.published_scores VALUES (47, 3, 'FinalA', 4.9, '2025-03-10 19:38:43.324863', NULL);
INSERT INTO public.published_scores VALUES (48, 3, 'FinalB', 3.9, '2025-03-10 19:38:43.325404', NULL);
INSERT INTO public.published_scores VALUES (49, 3, 'Final', 8.7, '2025-03-10 19:38:43.325961', NULL);
INSERT INTO public.published_scores VALUES (57, 2, 'A1', 4.9, '2025-03-12 21:49:00.028879', NULL);
INSERT INTO public.published_scores VALUES (58, 2, 'A2', 4.8, '2025-03-12 21:49:00.030795', NULL);
INSERT INTO public.published_scores VALUES (59, 2, 'B1', 2.7, '2025-03-12 21:49:00.031456', NULL);
INSERT INTO public.published_scores VALUES (60, 2, 'B2', 1.6, '2025-03-12 21:49:00.031949', NULL);
INSERT INTO public.published_scores VALUES (61, 2, 'FinalA', 4.9, '2025-03-12 21:49:00.032348', NULL);
INSERT INTO public.published_scores VALUES (62, 2, 'FinalB', 2.2, '2025-03-12 21:49:00.032697', NULL);
INSERT INTO public.published_scores VALUES (63, 2, 'Final', 7.0, '2025-03-12 21:49:00.033041', NULL);
INSERT INTO public.published_scores VALUES (64, 1, 'A1', 4.5, '2025-03-13 23:21:34.739058', NULL);
INSERT INTO public.published_scores VALUES (65, 1, 'A2', 5.0, '2025-03-13 23:21:34.740714', NULL);
INSERT INTO public.published_scores VALUES (66, 1, 'B1', 4.8, '2025-03-13 23:21:34.741473', NULL);
INSERT INTO public.published_scores VALUES (67, 1, 'B2', 4.2, '2025-03-13 23:21:34.742174', NULL);
INSERT INTO public.published_scores VALUES (68, 1, 'FinalA', 4.8, '2025-03-13 23:21:34.742977', NULL);
INSERT INTO public.published_scores VALUES (69, 1, 'FinalB', 4.5, '2025-03-13 23:21:34.743729', NULL);
INSERT INTO public.published_scores VALUES (70, 1, 'Final', 9.3, '2025-03-13 23:21:34.744413', NULL);
INSERT INTO public.published_scores VALUES (71, 8, 'A1', 4.6, '2025-03-14 00:08:25.612293', NULL);
INSERT INTO public.published_scores VALUES (72, 8, 'A2', 5.0, '2025-03-14 00:08:25.625311', NULL);
INSERT INTO public.published_scores VALUES (73, 8, 'B1', 3.5, '2025-03-14 00:08:25.626233', NULL);
INSERT INTO public.published_scores VALUES (74, 8, 'B2', 3.5, '2025-03-14 00:08:25.6269', NULL);
INSERT INTO public.published_scores VALUES (75, 8, 'FinalA', 4.8, '2025-03-14 00:08:25.627551', NULL);
INSERT INTO public.published_scores VALUES (76, 8, 'FinalB', 3.5, '2025-03-14 00:08:25.628175', NULL);
INSERT INTO public.published_scores VALUES (77, 8, 'Final', 8.3, '2025-03-14 00:08:25.62883', NULL);


--
-- TOC entry 4948 (class 0 OID 16435)
-- Dependencies: 229
-- Data for Name: schools; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.schools VALUES (8, 'Wushu Taekwon-Do Academy', '456 U.S. 22 West', 'Chris Leyesa', '(732) 789-4744', '', '2025-03-11 22:54:48.869172', '2025-03-11 22:54:48.869172');
INSERT INTO public.schools VALUES (9, 'Perth Amboy Martial Arts', '165 Smith St', 'Kevin Torres', '(732) 877-9229', '', '2025-03-12 21:50:27.287242', '2025-03-14 00:09:40.124714');


--
-- TOC entry 4944 (class 0 OID 16417)
-- Dependencies: 225
-- Data for Name: scores; Type: TABLE DATA; Schema: public; Owner: wushu
--

INSERT INTO public.scores VALUES (1, 4, 'B1', 2.5, '2025-02-19 03:21:54.62767', NULL);
INSERT INTO public.scores VALUES (113, 1, 'B1', 4.8, '2025-02-24 02:47:57.911293', NULL);
INSERT INTO public.scores VALUES (114, 1, 'A1', 4.5, '2025-02-24 02:49:30.155503', NULL);
INSERT INTO public.scores VALUES (16, 3, 'A2', 4.7, '2025-02-20 03:17:34.721705', NULL);
INSERT INTO public.scores VALUES (17, 5, 'A2', 4.7, '2025-02-20 03:41:08.844364', NULL);
INSERT INTO public.scores VALUES (18, 5, 'A1', 4.4, '2025-02-20 03:41:28.251313', NULL);
INSERT INTO public.scores VALUES (19, 5, 'A1', 3.8, '2025-02-20 03:50:38.78287', NULL);
INSERT INTO public.scores VALUES (20, 5, 'A1', 3.6, '2025-02-20 20:51:32.028728', NULL);
INSERT INTO public.scores VALUES (21, 5, 'A1', 3.6, '2025-02-20 21:39:13.434779', NULL);
INSERT INTO public.scores VALUES (22, 5, 'A1', 3.5, '2025-02-20 21:39:21.901464', NULL);
INSERT INTO public.scores VALUES (23, 5, 'A1', 3.5, '2025-02-20 21:39:35.307473', NULL);
INSERT INTO public.scores VALUES (24, 5, 'B1', 5.0, '2025-02-20 21:40:12.201298', NULL);
INSERT INTO public.scores VALUES (25, 5, 'A1', 3.5, '2025-02-20 21:40:21.336875', NULL);
INSERT INTO public.scores VALUES (26, 5, 'A2', 4.7, '2025-02-20 21:40:32.355039', NULL);
INSERT INTO public.scores VALUES (27, 5, 'A2', 4.6, '2025-02-20 21:40:41.977042', NULL);
INSERT INTO public.scores VALUES (28, 5, 'A2', 4.6, '2025-02-20 21:40:47.843202', NULL);
INSERT INTO public.scores VALUES (29, 5, 'A2', 4.6, '2025-02-20 21:43:50.953652', NULL);
INSERT INTO public.scores VALUES (30, 5, 'A2', 4.6, '2025-02-20 22:06:17.449775', NULL);
INSERT INTO public.scores VALUES (31, 5, 'A2', 4.6, '2025-02-20 22:06:27.223383', NULL);
INSERT INTO public.scores VALUES (32, 5, 'A2', 4.2, '2025-02-20 22:06:54.365685', NULL);
INSERT INTO public.scores VALUES (33, 2, 'B1', 2.7, '2025-02-21 01:59:41.266939', NULL);
INSERT INTO public.scores VALUES (34, 2, 'B1', 2.7, '2025-02-21 02:10:04.042637', NULL);
INSERT INTO public.scores VALUES (35, 2, 'B1', 2.7, '2025-02-21 02:10:08.49486', NULL);
INSERT INTO public.scores VALUES (36, 2, 'B1', 2.7, '2025-02-21 02:10:43.269568', NULL);
INSERT INTO public.scores VALUES (37, 2, 'B1', 2.7, '2025-02-21 02:10:51.850681', NULL);
INSERT INTO public.scores VALUES (38, 2, 'B1', 2.7, '2025-02-21 02:11:13.602577', NULL);
INSERT INTO public.scores VALUES (39, 2, 'B1', 2.7, '2025-02-21 02:12:03.555103', NULL);
INSERT INTO public.scores VALUES (40, 2, 'B1', 2.7, '2025-02-21 02:12:32.328096', NULL);
INSERT INTO public.scores VALUES (41, 2, 'B1', 2.7, '2025-02-21 02:12:49.99917', NULL);
INSERT INTO public.scores VALUES (42, 2, 'B1', 2.7, '2025-02-21 02:32:58.548029', NULL);
INSERT INTO public.scores VALUES (43, 2, 'B1', 2.7, '2025-02-21 02:42:45.337306', NULL);
INSERT INTO public.scores VALUES (44, 4, 'B1', 2.5, '2025-02-21 02:42:50.94866', NULL);
INSERT INTO public.scores VALUES (45, 4, 'A1', 4.6, '2025-02-21 02:43:08.267163', NULL);
INSERT INTO public.scores VALUES (46, 4, 'A1', 4.6, '2025-02-21 02:43:33.394167', NULL);
INSERT INTO public.scores VALUES (47, 4, 'A1', 4.3, '2025-02-21 02:44:00.823248', NULL);
INSERT INTO public.scores VALUES (48, 4, 'A1', 4.0, '2025-02-21 02:44:16.385858', NULL);
INSERT INTO public.scores VALUES (49, 4, 'A1', 3.7, '2025-02-21 02:44:30.943892', NULL);
INSERT INTO public.scores VALUES (50, 4, 'A1', 3.7, '2025-02-21 02:44:47.154845', NULL);
INSERT INTO public.scores VALUES (51, 4, 'A1', 3.7, '2025-02-21 02:45:08.259965', NULL);
INSERT INTO public.scores VALUES (52, 4, 'B1', 2.5, '2025-02-21 02:55:40.715161', NULL);
INSERT INTO public.scores VALUES (53, 4, 'B2', 5.0, '2025-02-21 02:55:53.203552', NULL);
INSERT INTO public.scores VALUES (54, 4, 'B2', 1.1, '2025-02-21 02:55:57.83578', NULL);
INSERT INTO public.scores VALUES (55, 2, 'A1', 4.9, '2025-02-21 02:56:24.495592', NULL);
INSERT INTO public.scores VALUES (56, 2, 'A1', 4.9, '2025-02-21 02:56:30.517538', NULL);
INSERT INTO public.scores VALUES (57, 2, 'A1', 4.9, '2025-02-21 03:02:57.159905', NULL);
INSERT INTO public.scores VALUES (58, 2, 'A1', 4.6, '2025-02-21 03:03:07.87757', NULL);
INSERT INTO public.scores VALUES (59, 2, 'A1', 4.5, '2025-02-21 03:04:59.379483', NULL);
INSERT INTO public.scores VALUES (132, 1, 'A2', 5.0, '2025-02-24 03:17:16.449432', NULL);
INSERT INTO public.scores VALUES (133, 1, 'FinalA', 4.8, '2025-02-24 03:17:21.794577', NULL);
INSERT INTO public.scores VALUES (134, 1, 'FinalB', 4.5, '2025-02-24 03:17:21.800858', NULL);
INSERT INTO public.scores VALUES (135, 1, 'Final', 9.3, '2025-02-24 03:17:21.806532', NULL);
INSERT INTO public.scores VALUES (136, 1, 'FinalA', 4.8, '2025-02-26 02:18:54.690659', NULL);
INSERT INTO public.scores VALUES (137, 1, 'FinalB', 4.5, '2025-02-26 02:18:54.70433', NULL);
INSERT INTO public.scores VALUES (138, 1, 'Final', 9.3, '2025-02-26 02:18:54.709079', NULL);
INSERT INTO public.scores VALUES (139, 1, 'A1', 4.4, '2025-02-26 18:19:01.232335', NULL);
INSERT INTO public.scores VALUES (140, 1, 'FinalA', 4.8, '2025-02-26 18:19:15.486227', NULL);
INSERT INTO public.scores VALUES (141, 1, 'FinalB', 4.5, '2025-02-26 18:19:15.494091', NULL);
INSERT INTO public.scores VALUES (142, 1, 'Final', 9.3, '2025-02-26 18:19:15.49854', NULL);
INSERT INTO public.scores VALUES (143, 1, 'A1', 4.4, '2025-03-03 01:32:39.274741', NULL);
INSERT INTO public.scores VALUES (144, 1, 'A1', 4.3, '2025-03-03 01:32:53.824106', NULL);
INSERT INTO public.scores VALUES (145, 1, 'A1', 4.2, '2025-03-03 01:33:21.711892', NULL);
INSERT INTO public.scores VALUES (146, 1, 'A1', 4.2, '2025-03-03 01:33:29.620047', NULL);
INSERT INTO public.scores VALUES (147, 1, 'A1', 4.2, '2025-03-03 01:34:03.83641', NULL);
INSERT INTO public.scores VALUES (148, 3, 'A1', 5.0, '2025-03-03 01:34:34.925925', NULL);
INSERT INTO public.scores VALUES (149, 3, 'A1', 4.7, '2025-03-03 01:35:10.56756', NULL);
INSERT INTO public.scores VALUES (150, 3, 'A2', 4.6, '2025-03-03 01:35:28.659181', NULL);
INSERT INTO public.scores VALUES (151, 3, 'B1', 3.3, '2025-03-03 01:35:39.991816', NULL);
INSERT INTO public.scores VALUES (152, 3, 'B2', 4.4, '2025-03-03 01:35:48.813009', NULL);
INSERT INTO public.scores VALUES (153, 3, 'FinalA', 4.9, '2025-03-03 01:36:15.452257', NULL);
INSERT INTO public.scores VALUES (154, 3, 'FinalB', 3.9, '2025-03-03 01:36:15.461904', NULL);
INSERT INTO public.scores VALUES (155, 3, 'Final', 8.7, '2025-03-03 01:36:15.466109', NULL);
INSERT INTO public.scores VALUES (112, 1, 'B2', 4.2, '2025-02-24 02:47:08.930516', NULL);
INSERT INTO public.scores VALUES (156, 3, 'FinalA', 4.9, '2025-03-10 19:29:41.276868', NULL);
INSERT INTO public.scores VALUES (157, 3, 'FinalB', 3.9, '2025-03-10 19:29:41.285205', NULL);
INSERT INTO public.scores VALUES (158, 3, 'Final', 8.7, '2025-03-10 19:29:41.288305', NULL);
INSERT INTO public.scores VALUES (159, 1, 'B1', 2.3, '2025-03-10 19:37:59.821142', NULL);
INSERT INTO public.scores VALUES (160, 2, 'A2', 4.8, '2025-03-10 19:39:35.828373', NULL);
INSERT INTO public.scores VALUES (161, 2, 'B2', 1.6, '2025-03-10 19:39:49.440975', NULL);
INSERT INTO public.scores VALUES (162, 2, 'FinalA', 4.9, '2025-03-10 19:39:57.501757', NULL);
INSERT INTO public.scores VALUES (163, 2, 'FinalB', 2.2, '2025-03-10 19:39:57.517475', NULL);
INSERT INTO public.scores VALUES (164, 2, 'Final', 7.0, '2025-03-10 19:39:57.521781', NULL);
INSERT INTO public.scores VALUES (165, 2, 'A1', 4.3, '2025-03-12 21:48:02.655828', NULL);
INSERT INTO public.scores VALUES (166, 2, 'B1', 4.2, '2025-03-12 21:48:22.925665', NULL);
INSERT INTO public.scores VALUES (167, 2, 'FinalA', 4.9, '2025-03-12 21:48:43.953993', NULL);
INSERT INTO public.scores VALUES (168, 2, 'FinalB', 2.2, '2025-03-12 21:48:43.969926', NULL);
INSERT INTO public.scores VALUES (169, 2, 'Final', 7.0, '2025-03-12 21:48:43.973678', NULL);
INSERT INTO public.scores VALUES (170, 2, 'FinalA', 4.9, '2025-03-13 14:26:25.461621', NULL);
INSERT INTO public.scores VALUES (171, 2, 'FinalB', 2.2, '2025-03-13 14:26:25.479522', NULL);
INSERT INTO public.scores VALUES (172, 2, 'Final', 7.0, '2025-03-13 14:26:25.483493', NULL);
INSERT INTO public.scores VALUES (173, 1, 'FinalA', 4.8, '2025-03-13 23:21:32.506411', NULL);
INSERT INTO public.scores VALUES (174, 1, 'FinalB', 4.5, '2025-03-13 23:21:32.525847', NULL);
INSERT INTO public.scores VALUES (175, 1, 'Final', 9.3, '2025-03-13 23:21:32.529895', NULL);
INSERT INTO public.scores VALUES (176, 8, 'A1', 4.6, '2025-03-14 00:07:30.724634', NULL);
INSERT INTO public.scores VALUES (177, 8, 'A2', 5.0, '2025-03-14 00:07:48.792426', NULL);
INSERT INTO public.scores VALUES (178, 8, 'B1', 3.5, '2025-03-14 00:08:00.856589', NULL);
INSERT INTO public.scores VALUES (179, 8, 'B2', 3.5, '2025-03-14 00:08:06.640831', NULL);
INSERT INTO public.scores VALUES (180, 8, 'FinalA', 4.8, '2025-03-14 00:08:21.82302', NULL);
INSERT INTO public.scores VALUES (181, 8, 'FinalB', 3.5, '2025-03-14 00:08:21.826899', NULL);
INSERT INTO public.scores VALUES (182, 8, 'Final', 8.3, '2025-03-14 00:08:21.831083', NULL);
INSERT INTO public.scores VALUES (183, 10, 'A1', 4.9, '2025-03-14 23:52:40.704526', NULL);


--
-- TOC entry 4946 (class 0 OID 16424)
-- Dependencies: 227
-- Data for Name: tournament_details; Type: TABLE DATA; Schema: public; Owner: wushu
--

INSERT INTO public.tournament_details VALUES ('JudgeA2_open', 1);
INSERT INTO public.tournament_details VALUES ('JudgeB2_open', 1);
INSERT INTO public.tournament_details VALUES ('JudgeB1_open', 1);
INSERT INTO public.tournament_details VALUES ('JudgeA1_open', 1);
INSERT INTO public.tournament_details VALUES ('Active_ID', 10);
INSERT INTO public.tournament_details VALUES ('OnDeck_ID', 8);
INSERT INTO public.tournament_details VALUES ('Judge_A1', 0);
INSERT INTO public.tournament_details VALUES ('Judge_A2', 0);
INSERT INTO public.tournament_details VALUES ('Judge_B1', 0);
INSERT INTO public.tournament_details VALUES ('Judge_B2', 0);


--
-- TOC entry 4951 (class 0 OID 16510)
-- Dependencies: 232
-- Data for Name: tournament_participants; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tournament_participants VALUES (10, 3, '2025-03-13 14:32:05.034488', '2025-03-13 14:32:05.034488');
INSERT INTO public.tournament_participants VALUES (10, 1, '2025-03-13 14:32:09.698217', '2025-03-13 14:32:09.698217');
INSERT INTO public.tournament_participants VALUES (8, 3, '2025-03-14 00:06:03.236989', '2025-03-14 00:06:03.236989');
INSERT INTO public.tournament_participants VALUES (1, 3, '2025-03-14 23:30:55.721469', '2025-03-14 23:30:55.721469');
INSERT INTO public.tournament_participants VALUES (1, 1, '2025-03-14 23:30:58.481066', '2025-03-14 23:30:58.481066');
INSERT INTO public.tournament_participants VALUES (7, 1, '2025-03-14 23:31:04.998472', '2025-03-14 23:31:04.998472');
INSERT INTO public.tournament_participants VALUES (3, 3, '2025-03-14 23:31:19.075999', '2025-03-14 23:31:19.075999');
INSERT INTO public.tournament_participants VALUES (3, 2, '2025-03-14 23:31:20.989105', '2025-03-14 23:31:20.989105');
INSERT INTO public.tournament_participants VALUES (3, 1, '2025-03-14 23:31:22.862934', '2025-03-14 23:31:22.862934');
INSERT INTO public.tournament_participants VALUES (9, 2, '2025-03-14 23:31:27.71688', '2025-03-14 23:31:27.71688');
INSERT INTO public.tournament_participants VALUES (6, 2, '2025-03-14 23:31:34.07531', '2025-03-14 23:31:34.07531');
INSERT INTO public.tournament_participants VALUES (6, 3, '2025-03-14 23:31:36.820649', '2025-03-14 23:31:36.820649');
INSERT INTO public.tournament_participants VALUES (2, 3, '2025-03-14 23:31:51.071328', '2025-03-14 23:31:51.071328');
INSERT INTO public.tournament_participants VALUES (2, 1, '2025-03-14 23:31:59.126476', '2025-03-14 23:31:59.126476');
INSERT INTO public.tournament_participants VALUES (11, 3, '2025-03-14 23:32:04.143814', '2025-03-14 23:32:04.143814');
INSERT INTO public.tournament_participants VALUES (11, 1, '2025-03-14 23:32:06.235451', '2025-03-14 23:32:06.235451');
INSERT INTO public.tournament_participants VALUES (4, 2, '2025-03-14 23:32:11.704543', '2025-03-14 23:32:11.704543');
INSERT INTO public.tournament_participants VALUES (5, 1, '2025-03-14 23:32:16.008266', '2025-03-14 23:32:16.008266');


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

SELECT pg_catalog.setval('public.divisions_id_seq', 3, true);


--
-- TOC entry 4969 (class 0 OID 0)
-- Dependencies: 220
-- Name: participant_deductions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.participant_deductions_id_seq', 78, true);


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

SELECT pg_catalog.setval('public.published_scores_id_seq', 77, true);


--
-- TOC entry 4972 (class 0 OID 0)
-- Dependencies: 228
-- Name: schools_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schools_id_seq', 9, true);


--
-- TOC entry 4973 (class 0 OID 0)
-- Dependencies: 226
-- Name: scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.scores_id_seq', 183, true);


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
-- TOC entry 4783 (class 2606 OID 16493)
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
-- TOC entry 4782 (class 2606 OID 16477)
-- Name: participant_deductions participant_deductions_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions
    ADD CONSTRAINT participant_deductions_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 4784 (class 2606 OID 16455)
-- Name: participants participants_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 4785 (class 2606 OID 16534)
-- Name: published_scores published_scores_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores
    ADD CONSTRAINT published_scores_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE SET NULL;


--
-- TOC entry 4786 (class 2606 OID 16482)
-- Name: published_scores published_scores_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores
    ADD CONSTRAINT published_scores_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 4787 (class 2606 OID 16529)
-- Name: scores scores_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE SET NULL;


--
-- TOC entry 4788 (class 2606 OID 16487)
-- Name: scores scores_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 4789 (class 2606 OID 16522)
-- Name: tournament_participants tournament_participants_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE CASCADE;


--
-- TOC entry 4790 (class 2606 OID 16517)
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


-- Completed on 2025-03-15 20:05:34

--
-- PostgreSQL database dump complete
--

