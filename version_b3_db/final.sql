--
-- PostgreSQL database dump
--

\restrict G2Lrl4xiHCdMs8VaatNIR6DeF6ZRXXgIC98jZv2eImlXbWiUl3rkZTPeMRUed5H

-- Dumped from database version 18.1 (Postgres.app)
-- Dumped by pg_dump version 18.0

-- Started on 2025-12-11 21:45:57 EST

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
-- TOC entry 4030 (class 1262 OID 16391)
-- Name: wushu; Type: DATABASE; Schema: -; Owner: wushu
--

CREATE DATABASE wushu WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = icu LOCALE = 'en_US.UTF-8' ICU_LOCALE = 'en-US';


ALTER DATABASE wushu OWNER TO wushu;

\unrestrict G2Lrl4xiHCdMs8VaatNIR6DeF6ZRXXgIC98jZv2eImlXbWiUl3rkZTPeMRUed5H
\connect wushu
\restrict G2Lrl4xiHCdMs8VaatNIR6DeF6ZRXXgIC98jZv2eImlXbWiUl3rkZTPeMRUed5H

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
-- TOC entry 4031 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 219 (class 1259 OID 16392)
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
-- TOC entry 220 (class 1259 OID 16404)
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
-- TOC entry 4032 (class 0 OID 0)
-- Dependencies: 220
-- Name: deductions_deduction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.deductions_deduction_id_seq OWNED BY public.deductions.deduction_id;


--
-- TOC entry 221 (class 1259 OID 16405)
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
-- TOC entry 222 (class 1259 OID 16414)
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
-- TOC entry 4033 (class 0 OID 0)
-- Dependencies: 222
-- Name: divisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.divisions_id_seq OWNED BY public.divisions.id;


--
-- TOC entry 223 (class 1259 OID 16415)
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
-- TOC entry 224 (class 1259 OID 16421)
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
-- TOC entry 4034 (class 0 OID 0)
-- Dependencies: 224
-- Name: participant_deductions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.participant_deductions_id_seq OWNED BY public.participant_deductions.id;


--
-- TOC entry 225 (class 1259 OID 16422)
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
    tournament_id integer DEFAULT 1,
    CONSTRAINT participants_gender_check CHECK ((gender = ANY (ARRAY['M'::bpchar, 'F'::bpchar, 'O'::bpchar])))
);


ALTER TABLE public.participants OWNER TO wushu;

--
-- TOC entry 226 (class 1259 OID 16430)
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
-- TOC entry 4036 (class 0 OID 0)
-- Dependencies: 226
-- Name: participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.participants_id_seq OWNED BY public.participants.id;


--
-- TOC entry 227 (class 1259 OID 16431)
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
-- TOC entry 228 (class 1259 OID 16441)
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
-- TOC entry 4037 (class 0 OID 0)
-- Dependencies: 228
-- Name: published_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.published_scores_id_seq OWNED BY public.published_scores.id;


--
-- TOC entry 229 (class 1259 OID 16442)
-- Name: registrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.registrations (
    id integer NOT NULL,
    tournament_id integer,
    school_id integer,
    participant_rank character varying(50),
    status integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    user_id integer,
    participant_id integer,
    height_feet integer,
    height_inches integer,
    weight numeric(5,2),
    age_at_event integer
);


ALTER TABLE public.registrations OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16449)
-- Name: registrations_divisions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.registrations_divisions (
    registration_id integer NOT NULL,
    division_id integer NOT NULL
);


ALTER TABLE public.registrations_divisions OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16454)
-- Name: registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.registrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.registrations_id_seq OWNER TO postgres;

--
-- TOC entry 4038 (class 0 OID 0)
-- Dependencies: 231
-- Name: registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.registrations_id_seq OWNED BY public.registrations.id;


--
-- TOC entry 232 (class 1259 OID 16455)
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
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    registration_token uuid,
    registration_link text,
    registration_qr_code bytea,
    expires_at timestamp without time zone
);


ALTER TABLE public.schools OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16464)
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
-- TOC entry 4039 (class 0 OID 0)
-- Dependencies: 233
-- Name: schools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.schools_id_seq OWNED BY public.schools.id;


--
-- TOC entry 234 (class 1259 OID 16465)
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
-- TOC entry 235 (class 1259 OID 16474)
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
-- TOC entry 4040 (class 0 OID 0)
-- Dependencies: 235
-- Name: scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.scores_id_seq OWNED BY public.scores.id;


--
-- TOC entry 236 (class 1259 OID 16475)
-- Name: tournament_details; Type: TABLE; Schema: public; Owner: wushu
--

CREATE TABLE public.tournament_details (
    argument character varying(50) NOT NULL,
    value integer NOT NULL
);


ALTER TABLE public.tournament_details OWNER TO wushu;

--
-- TOC entry 237 (class 1259 OID 16480)
-- Name: tournament_divisions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_divisions (
    tournament_id integer NOT NULL,
    division_id integer NOT NULL
);


ALTER TABLE public.tournament_divisions OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 16485)
-- Name: tournament_participants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_participants (
    participant_id integer NOT NULL,
    division_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    tournament_id integer DEFAULT 1
);


ALTER TABLE public.tournament_participants OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16493)
-- Name: tournament_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_results (
    id integer NOT NULL,
    tournament_id integer,
    participant_id integer,
    division_id integer,
    total_score numeric(4,2) NOT NULL,
    rank integer,
    score_breakdown jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tournament_results OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 16501)
-- Name: tournament_results_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tournament_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tournament_results_id_seq OWNER TO postgres;

--
-- TOC entry 4041 (class 0 OID 0)
-- Dependencies: 240
-- Name: tournament_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tournament_results_id_seq OWNED BY public.tournament_results.id;


--
-- TOC entry 241 (class 1259 OID 16502)
-- Name: tournament_schools; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_schools (
    tournament_id integer NOT NULL,
    school_id integer NOT NULL
);


ALTER TABLE public.tournament_schools OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 16507)
-- Name: tournaments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournaments (
    tournament_id integer NOT NULL,
    tournament_title character varying(255) NOT NULL,
    tournament_start_date date,
    tournament_end_date date,
    tournament_hours character varying(100),
    tournament_contact character varying(255),
    tournament_address text,
    tournament_city character varying(100),
    tournament_state character varying(100),
    tournament_country character varying(100),
    tournament_email character varying(255),
    is_active boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    tournament_logo text,
    color_primary character varying(20) DEFAULT '#1E40AF'::character varying,
    color_background character varying(20) DEFAULT '#F3F4F6'::character varying,
    details_content text,
    judges_config jsonb DEFAULT '{"A1": true, "A2": true, "B1": true, "B2": true}'::jsonb,
    registration_start_date date,
    registration_end_date date
);


ALTER TABLE public.tournaments OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 16519)
-- Name: tournaments_tournament_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tournaments_tournament_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tournaments_tournament_id_seq OWNER TO postgres;

--
-- TOC entry 4042 (class 0 OID 0)
-- Dependencies: 243
-- Name: tournaments_tournament_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tournaments_tournament_id_seq OWNED BY public.tournaments.tournament_id;


--
-- TOC entry 244 (class 1259 OID 16520)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(255) NOT NULL,
    role character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    email character varying(255),
    first_name character varying(100),
    middle_name character varying(100),
    last_name character varying(100),
    birthdate date,
    gender character(1),
    height_feet integer,
    height_inches integer,
    weight numeric(5,2),
    phone character varying(20),
    emergency_contact_name character varying(100),
    emergency_contact_phone character varying(20),
    street character varying(255),
    city character varying(100),
    state character varying(100),
    country character varying(100),
    zip_code character varying(20),
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_verified boolean DEFAULT false,
    verification_token character varying(255),
    reset_password_token character varying(255),
    reset_password_expires timestamp without time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 16531)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 4043 (class 0 OID 0)
-- Dependencies: 245
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 3740 (class 2604 OID 16532)
-- Name: deductions deduction_id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.deductions ALTER COLUMN deduction_id SET DEFAULT nextval('public.deductions_deduction_id_seq'::regclass);


--
-- TOC entry 3741 (class 2604 OID 16533)
-- Name: divisions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.divisions ALTER COLUMN id SET DEFAULT nextval('public.divisions_id_seq'::regclass);


--
-- TOC entry 3745 (class 2604 OID 16534)
-- Name: participant_deductions id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions ALTER COLUMN id SET DEFAULT nextval('public.participant_deductions_id_seq'::regclass);


--
-- TOC entry 3747 (class 2604 OID 16535)
-- Name: participants id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants ALTER COLUMN id SET DEFAULT nextval('public.participants_id_seq'::regclass);


--
-- TOC entry 3749 (class 2604 OID 16536)
-- Name: published_scores id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores ALTER COLUMN id SET DEFAULT nextval('public.published_scores_id_seq'::regclass);


--
-- TOC entry 3751 (class 2604 OID 16537)
-- Name: registrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations ALTER COLUMN id SET DEFAULT nextval('public.registrations_id_seq'::regclass);


--
-- TOC entry 3755 (class 2604 OID 16538)
-- Name: schools id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schools ALTER COLUMN id SET DEFAULT nextval('public.schools_id_seq'::regclass);


--
-- TOC entry 3758 (class 2604 OID 16539)
-- Name: scores id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores ALTER COLUMN id SET DEFAULT nextval('public.scores_id_seq'::regclass);


--
-- TOC entry 3763 (class 2604 OID 16540)
-- Name: tournament_results id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_results ALTER COLUMN id SET DEFAULT nextval('public.tournament_results_id_seq'::regclass);


--
-- TOC entry 3765 (class 2604 OID 16541)
-- Name: tournaments tournament_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournaments ALTER COLUMN tournament_id SET DEFAULT nextval('public.tournaments_tournament_id_seq'::regclass);


--
-- TOC entry 3772 (class 2604 OID 16542)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 3998 (class 0 OID 16392)
-- Dependencies: 219
-- Data for Name: deductions; Type: TABLE DATA; Schema: public; Owner: wushu
--

INSERT INTO public.deductions (deduction_id, deduction_category, deduction_criteria, deduction_description, deduction_value, deduction_code) VALUES (1, 'Hand Forms/Shape', 'Fist', '* Face of fist uneven\n* Thumb not pressing on second segment of middle finger', 0.1, 5);
INSERT INTO public.deductions (deduction_id, deduction_category, deduction_criteria, deduction_description, deduction_value, deduction_code) VALUES (2, 'Hand Forms/Shape', 'Sword Finger', '* Supporting leg bent\n* Raised leg bent', 0.3, 6);
INSERT INTO public.deductions (deduction_id, deduction_category, deduction_criteria, deduction_description, deduction_value, deduction_code) VALUES (3, 'Hand Forms/Shape', 'Palm', '* Four fingers not straight and together\n* Thumb is not bent in tightly', 0.1, 7);
INSERT INTO public.deductions (deduction_id, deduction_category, deduction_criteria, deduction_description, deduction_value, deduction_code) VALUES (4, 'Hand Forms/Shape', 'Hook', '* Five fingers not pinched together\n* Wrist not hooked completely', 0.1, 8);


--
-- TOC entry 4000 (class 0 OID 16405)
-- Dependencies: 221
-- Data for Name: divisions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.divisions (id, division_name, created_at, updated_at, active) VALUES (2, 'Northern Traditional Weapons', '2025-03-13 11:02:45.532262', '2025-03-13 11:02:45.532262', false);
INSERT INTO public.divisions (id, division_name, created_at, updated_at, active) VALUES (4, 'Southern Bare Hands', '2025-03-19 20:50:03.059138', '2025-03-27 23:18:43.431666', false);
INSERT INTO public.divisions (id, division_name, created_at, updated_at, active) VALUES (8, 'Northern Long Weapons', '2025-05-22 15:35:37.86546', '2025-05-22 15:35:37.86546', false);
INSERT INTO public.divisions (id, division_name, created_at, updated_at, active) VALUES (9, 'Test', '2025-11-24 22:25:56.458055', '2025-11-24 22:25:56.458055', false);
INSERT INTO public.divisions (id, division_name, created_at, updated_at, active) VALUES (1, 'Southern Traditional Weapons', '2025-03-13 11:02:45.532262', '2025-03-13 11:02:45.532262', false);
INSERT INTO public.divisions (id, division_name, created_at, updated_at, active) VALUES (3, 'Northern Bare Hands', '2025-03-13 11:02:45.532262', '2025-03-24 13:44:18.089647', true);


--
-- TOC entry 4002 (class 0 OID 16415)
-- Dependencies: 223
-- Data for Name: participant_deductions; Type: TABLE DATA; Schema: public; Owner: wushu
--

INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (14, 5, 1, '2025-02-20 03:50:25.40272', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (15, 5, 1, '2025-02-20 03:50:27.762947', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (16, 5, 3, '2025-02-20 03:50:32.296349', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (17, 5, 2, '2025-02-20 03:50:34.330336', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (18, 5, 1, '2025-02-20 20:51:32.04023', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (19, 5, 1, '2025-02-20 20:51:32.046907', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (70, 3, 2, '2025-03-03 01:35:10.579346', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (71, 3, 3, '2025-03-03 01:35:28.668441', 'A2', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (72, 2, 1, '2025-03-10 19:39:35.846454', 'A2', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (73, 2, 3, '2025-03-10 19:39:36.015219', 'A2', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (74, 2, 1, '2025-03-12 21:48:02.679764', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (75, 2, 3, '2025-03-12 21:48:02.688533', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (76, 8, 3, '2025-03-14 00:07:30.744422', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (77, 8, 2, '2025-03-14 00:07:30.807297', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (78, 10, 3, '2025-03-14 23:52:40.727588', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (83, 1, 2, '2025-03-24 15:58:25.845291', 'A1', NULL);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (84, 1, 3, '2025-03-24 15:58:25.853283', 'A1', NULL);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (85, 1, 4, '2025-05-20 16:56:53.780699', 'A1', NULL);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (86, 3, 4, '2025-05-20 21:07:31.103244', 'A1', NULL);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (87, 3, 3, '2025-05-20 21:07:31.110293', 'A1', NULL);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (88, 2, 3, '2025-05-22 15:38:21.089962', 'A1', NULL);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (89, 2, 3, '2025-05-22 15:38:21.096345', 'A1', NULL);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (90, 2, 2, '2025-05-22 15:38:21.103175', 'A1', NULL);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (91, 2, 2, '2025-05-22 15:38:21.10802', 'A1', NULL);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (92, 2, 2, '2025-05-22 15:38:21.114254', 'A1', NULL);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (93, 2, 4, '2025-05-22 15:38:51.008685', 'A2', NULL);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (94, 2, 2, '2025-05-22 15:38:51.015882', 'A2', NULL);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (97, 2, 3, '2025-05-23 12:43:04.288008', 'A2', 8);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (98, 2, 3, '2025-05-23 12:43:04.293016', 'A2', 8);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (99, 2, 3, '2025-05-23 12:43:04.298913', 'A2', 8);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (103, 2, 2, '2025-05-23 14:28:43.193166', 'A1', 8);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (104, 10, 3, '2025-11-22 23:50:23.55629', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (105, 10, 3, '2025-11-22 23:50:23.562855', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (106, 10, 2, '2025-11-22 23:50:23.568184', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (108, 10, 4, '2025-11-22 23:51:08.92626', 'A2', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (112, 1, 2, '2025-11-22 23:54:14.050248', 'A2', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (113, 1, 2, '2025-11-22 23:54:39.474072', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (114, 7, 2, '2025-11-22 23:56:09.987129', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (115, 7, 2, '2025-11-22 23:56:21.702441', 'A2', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (116, 17, 1, '2025-11-23 00:02:14.86946', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (117, 17, 1, '2025-11-23 00:02:14.874976', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (118, 17, 1, '2025-11-23 00:02:14.880055', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (119, 17, 1, '2025-11-23 00:02:14.885259', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (120, 17, 1, '2025-11-23 00:02:14.890831', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (121, 17, 1, '2025-11-23 00:02:14.896006', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (122, 17, 4, '2025-11-23 00:02:38.043802', 'A2', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (123, 17, 4, '2025-11-23 00:02:38.049566', 'A2', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (124, 17, 4, '2025-11-23 00:02:38.054922', 'A2', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (125, 17, 4, '2025-11-23 00:02:38.058881', 'A2', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (126, 17, 4, '2025-11-23 00:02:38.062905', 'A2', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (127, 18, 3, '2025-11-27 00:19:02.835179', 'A2', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (128, 18, 3, '2025-11-27 22:50:43.97018', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (133, 20, 2, '2025-11-27 23:06:54.630271', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (134, 20, 3, '2025-11-27 23:07:00.150721', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (135, 20, 4, '2025-11-27 23:07:25.156658', 'A2', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (136, 20, 2, '2025-11-27 23:23:58.932811', 'A2', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (137, 20, 2, '2025-11-27 23:24:02.004323', 'A2', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (138, 20, 3, '2025-11-27 23:24:02.859956', 'A2', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (139, 18, 3, '2025-11-27 23:36:08.364487', 'A1', 1);
INSERT INTO public.participant_deductions (id, participant_id, deduction_id, created_at, judge, division_id) VALUES (140, 18, 2, '2025-11-27 23:36:11.099913', 'A1', 1);


--
-- TOC entry 4004 (class 0 OID 16422)
-- Dependencies: 225
-- Data for Name: participants; Type: TABLE DATA; Schema: public; Owner: wushu
--

INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (1, 9, 'Ralph', NULL, 'Cespedes', NULL, NULL, NULL, NULL, 'M', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:10.520292', NULL, 1);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (7, 8, 'Audrey', NULL, 'Chiang', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:25.44711', NULL, 1);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (3, 8, 'Gina', NULL, 'Ku', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:37.360592', NULL, 1);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (6, 8, 'Soveida', NULL, 'Monteiro', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:52.304767', NULL, 1);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (11, 9, 'Sam', NULL, 'Rodriguez', NULL, NULL, NULL, NULL, 'M', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:56:10.634019', NULL, 1);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (4, 9, 'Fiorella', NULL, 'Vargas', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:56:18.014433', NULL, 1);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (5, 9, 'Maria', NULL, 'Vargas', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-14 23:32:43.266092', NULL, 1);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (2, 9, 'Jarely', NULL, 'Osorio', '2025-03-17', NULL, NULL, NULL, 'M', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:56:01.626954', NULL, 1);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (9, 8, 'Victoria', NULL, 'McKay', '2025-03-04', NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:44.382807', NULL, 1);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (8, 8, 'Leona', NULL, 'Castillo', '2025-03-03', NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:04.691326', NULL, 1);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (10, 8, 'Rehana', NULL, 'Carre', '2025-03-03', NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:54:46.878039', NULL, 1);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (16, 11, 'James', 'T', 'Kirk', '1980-01-01', 5, 10, 100.00, 'M', '908 908 8888', 'Janice', '908 888 8888', '1 Chronos Pl', 'Main', 'War', 'Chronos', '12345', NULL, 'Black', 1);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (17, 11, 'Jean-Luc', '', 'Picard', '1980-01-01', 5, 9, 86.00, 'M', '908 908 7777', 'Beverly Crusher', '', '10th Forward', 'Main Deck', 'Captain', 'Enterprise', '11111', NULL, 'Black', 1);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (18, 8, 'Ricardo', '', 'Balbachevsky Setti', '2025-10-31', NULL, NULL, NULL, 'M', '9086937777', '', '', '', '', '', '', '', NULL, '', 3);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (19, 11, 'Ricardo', NULL, 'Balbachevsky Setti', '2025-11-11', NULL, NULL, NULL, 'M', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 3);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (20, 9, 'Ricardo', NULL, 'Balbachevsky Setti', '2025-10-27', NULL, NULL, NULL, 'M', '9086937777', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 3);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (21, 8, 'Ricardo', NULL, 'Balbachevsky Settissss', '2025-11-12', NULL, NULL, NULL, 'M', '9086937777', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 3);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (22, 9, 'sdfsdfsfsdf', '', 'sdsdfsdfsdf', '2025-11-13', NULL, NULL, NULL, 'M', '', '', '', '', '', '', '', '', NULL, '', 1);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (24, 8, 'Alice', NULL, 'Lobo', '1978-02-19', 5, 8, 50.00, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 4);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (25, 9, 'Paulo', NULL, 'Borelli', '1978-01-01', 5, 11, 90.00, 'M', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 4);
INSERT INTO public.participants (id, school_id, first_name, middle_name, last_name, birthdate, height_feet, height_inches, weight, gender, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, participant_rank, tournament_id) VALUES (23, 9, 'Ricardo', NULL, 'Balbachevsky Setti', '2025-11-12', NULL, NULL, NULL, 'M', '9086937777', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-02 23:13:27.445957', NULL, 4);


--
-- TOC entry 4006 (class 0 OID 16431)
-- Dependencies: 227
-- Data for Name: published_scores; Type: TABLE DATA; Schema: public; Owner: wushu
--

INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (43, 3, 'A1', 5.0, '2025-03-10 19:38:43.321811', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (44, 3, 'A2', 4.7, '2025-03-10 19:38:43.322746', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (45, 3, 'B1', 3.3, '2025-03-10 19:38:43.323469', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (46, 3, 'B2', 4.4, '2025-03-10 19:38:43.324184', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (47, 3, 'FinalA', 4.9, '2025-03-10 19:38:43.324863', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (48, 3, 'FinalB', 3.9, '2025-03-10 19:38:43.325404', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (49, 3, 'Final', 8.7, '2025-03-10 19:38:43.325961', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (57, 2, 'A1', 4.9, '2025-03-12 21:49:00.028879', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (58, 2, 'A2', 4.8, '2025-03-12 21:49:00.030795', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (59, 2, 'B1', 2.7, '2025-03-12 21:49:00.031456', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (60, 2, 'B2', 1.6, '2025-03-12 21:49:00.031949', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (61, 2, 'FinalA', 4.9, '2025-03-12 21:49:00.032348', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (62, 2, 'FinalB', 2.2, '2025-03-12 21:49:00.032697', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (63, 2, 'Final', 7.0, '2025-03-12 21:49:00.033041', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (64, 1, 'A1', 4.5, '2025-03-13 23:21:34.739058', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (65, 1, 'A2', 5.0, '2025-03-13 23:21:34.740714', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (66, 1, 'B1', 4.8, '2025-03-13 23:21:34.741473', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (67, 1, 'B2', 4.2, '2025-03-13 23:21:34.742174', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (68, 1, 'FinalA', 4.8, '2025-03-13 23:21:34.742977', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (69, 1, 'FinalB', 4.5, '2025-03-13 23:21:34.743729', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (70, 1, 'Final', 9.3, '2025-03-13 23:21:34.744413', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (71, 8, 'A1', 4.6, '2025-03-14 00:08:25.612293', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (72, 8, 'A2', 5.0, '2025-03-14 00:08:25.625311', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (73, 8, 'B1', 3.5, '2025-03-14 00:08:25.626233', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (74, 8, 'B2', 3.5, '2025-03-14 00:08:25.6269', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (75, 8, 'FinalA', 4.8, '2025-03-14 00:08:25.627551', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (76, 8, 'FinalB', 3.5, '2025-03-14 00:08:25.628175', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (77, 8, 'Final', 8.3, '2025-03-14 00:08:25.62883', NULL);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (85, 10, 'A1', 4.9, '2025-03-19 20:53:28.861551', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (86, 10, 'A2', 5.0, '2025-03-19 20:53:28.86715', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (87, 10, 'B1', 3.4, '2025-03-19 20:53:28.868685', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (88, 10, 'B2', 3.6, '2025-03-19 20:53:28.870132', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (89, 10, 'FinalA', 5.0, '2025-03-19 20:53:28.8716', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (90, 10, 'FinalB', 3.5, '2025-03-19 20:53:28.872722', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (91, 10, 'Final', 8.5, '2025-03-19 20:53:28.874037', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (92, 8, 'A1', 5.0, '2025-03-19 21:05:47.118456', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (93, 8, 'A2', 5.0, '2025-03-19 21:05:47.170867', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (94, 8, 'B1', 1.9, '2025-03-19 21:05:47.171714', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (95, 8, 'B2', 4.5, '2025-03-19 21:05:47.172589', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (96, 8, 'FinalA', 5.0, '2025-03-19 21:05:47.174016', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (97, 8, 'FinalB', 3.2, '2025-03-19 21:05:47.175428', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (98, 8, 'Final', 8.2, '2025-03-19 21:05:47.176814', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (113, 1, 'A1', 4.9, '2025-05-20 16:57:34.421151', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (114, 1, 'A2', 5.0, '2025-05-20 16:57:34.422726', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (115, 1, 'B1', 1.4, '2025-05-20 16:57:34.42316', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (116, 1, 'B2', 2.2, '2025-05-20 16:57:34.423567', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (117, 1, 'FinalA', 5.0, '2025-05-20 16:57:34.424004', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (118, 1, 'FinalB', 1.8, '2025-05-20 16:57:34.424539', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (119, 1, 'Final', 6.8, '2025-05-20 16:57:34.425082', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (127, 3, 'A1', 4.8, '2025-05-20 21:08:48.277156', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (128, 3, 'A2', 5.0, '2025-05-20 21:08:48.277156', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (129, 3, 'B1', 3.1, '2025-05-20 21:08:48.277156', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (130, 3, 'B2', 4.5, '2025-05-20 21:08:48.277156', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (131, 3, 'FinalA', 4.9, '2025-05-20 21:08:48.277156', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (132, 3, 'FinalB', 3.8, '2025-05-20 21:08:48.277156', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (133, 3, 'Final', 8.7, '2025-05-20 21:08:48.277156', 3);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (134, 3, 'A1', 5.0, '2025-05-20 21:49:06.101357', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (135, 3, 'A2', 5.0, '2025-05-20 21:49:06.101357', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (136, 3, 'B1', 2.6, '2025-05-20 21:49:06.101357', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (137, 3, 'B2', 1.2, '2025-05-20 21:49:06.101357', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (138, 3, 'FinalA', 5.0, '2025-05-20 21:49:06.101357', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (139, 3, 'FinalB', 1.9, '2025-05-20 21:49:06.101357', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (140, 3, 'Final', 6.9, '2025-05-20 21:49:06.101357', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (148, 2, 'A1', 3.9, '2025-05-23 12:43:37.104874', 8);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (149, 2, 'A2', 4.6, '2025-05-23 12:43:37.104874', 8);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (150, 2, 'B1', 4.5, '2025-05-23 12:43:37.104874', 8);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (151, 2, 'B2', 4.1, '2025-05-23 12:43:37.104874', 8);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (152, 2, 'FinalA', 4.3, '2025-05-23 12:43:37.104874', 8);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (153, 2, 'FinalB', 4.3, '2025-05-23 12:43:37.104874', 8);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (154, 2, 'Final', 8.6, '2025-05-23 12:43:37.104874', 8);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (155, 10, 'A1', 4.4, '2025-11-22 23:52:09.957696', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (156, 10, 'A2', 4.9, '2025-11-22 23:52:09.957696', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (157, 10, 'B1', 2.4, '2025-11-22 23:52:09.957696', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (158, 10, 'B2', 3.8, '2025-11-22 23:52:09.957696', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (159, 10, 'FinalA', 4.7, '2025-11-22 23:52:09.957696', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (160, 10, 'FinalB', 3.1, '2025-11-22 23:52:09.957696', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (161, 10, 'Final', 7.8, '2025-11-22 23:52:09.957696', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (162, 1, 'A1', 4.6, '2025-11-22 23:55:15.427304', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (163, 1, 'A2', 5.0, '2025-11-22 23:55:15.427304', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (164, 1, 'B1', 3.7, '2025-11-22 23:55:15.427304', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (165, 1, 'B2', 4.6, '2025-11-22 23:55:15.427304', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (166, 1, 'FinalA', 4.8, '2025-11-22 23:55:15.427304', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (167, 1, 'FinalB', 4.2, '2025-11-22 23:55:15.427304', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (168, 1, 'Final', 9.0, '2025-11-22 23:55:15.427304', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (169, 7, 'A1', 4.7, '2025-11-22 23:56:59.497689', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (170, 7, 'A2', 4.7, '2025-11-22 23:56:59.497689', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (171, 7, 'B1', 3.6, '2025-11-22 23:56:59.497689', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (172, 7, 'B2', 4.0, '2025-11-22 23:56:59.497689', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (173, 7, 'FinalA', 4.7, '2025-11-22 23:56:59.497689', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (174, 7, 'FinalB', 3.8, '2025-11-22 23:56:59.497689', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (175, 7, 'Final', 8.5, '2025-11-22 23:56:59.497689', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (176, 17, 'A1', 4.4, '2025-11-23 00:03:28.925132', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (177, 17, 'A2', 4.5, '2025-11-23 00:03:28.925132', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (178, 17, 'B1', 4.5, '2025-11-23 00:03:28.925132', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (179, 17, 'B2', 5.0, '2025-11-23 00:03:28.925132', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (180, 17, 'FinalA', 4.5, '2025-11-23 00:03:28.925132', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (181, 17, 'FinalB', 4.8, '2025-11-23 00:03:28.925132', 1);
INSERT INTO public.published_scores (id, participant_id, judge, score, published_at, division_id) VALUES (182, 17, 'Final', 9.2, '2025-11-23 00:03:28.925132', 1);


--
-- TOC entry 4008 (class 0 OID 16442)
-- Dependencies: 229
-- Data for Name: registrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.registrations (id, tournament_id, school_id, participant_rank, status, created_at, updated_at, user_id, participant_id, height_feet, height_inches, weight, age_at_event) VALUES (4, 3, 8, '', 1, '2025-11-25 13:47:06.360407', '2025-11-25 14:06:47.706759', 11, 19, NULL, NULL, NULL, NULL);
INSERT INTO public.registrations (id, tournament_id, school_id, participant_rank, status, created_at, updated_at, user_id, participant_id, height_feet, height_inches, weight, age_at_event) VALUES (6, 3, 11, NULL, 1, '2025-11-25 22:17:21.274468', '2025-11-26 23:39:10.427609', 14, 19, NULL, NULL, NULL, NULL);
INSERT INTO public.registrations (id, tournament_id, school_id, participant_rank, status, created_at, updated_at, user_id, participant_id, height_feet, height_inches, weight, age_at_event) VALUES (3, 3, 9, NULL, 1, '2025-11-24 22:46:49.4398', '2025-11-27 22:50:02.43115', 10, 20, NULL, NULL, NULL, NULL);
INSERT INTO public.registrations (id, tournament_id, school_id, participant_rank, status, created_at, updated_at, user_id, participant_id, height_feet, height_inches, weight, age_at_event) VALUES (2, 3, 8, NULL, 1, '2025-11-24 22:36:22.804625', '2025-12-02 22:57:39.730836', 9, 21, NULL, NULL, NULL, NULL);
INSERT INTO public.registrations (id, tournament_id, school_id, participant_rank, status, created_at, updated_at, user_id, participant_id, height_feet, height_inches, weight, age_at_event) VALUES (1, 1, 9, '', 1, '2025-11-24 16:55:37.248463', '2025-12-02 22:57:43.025452', 8, 22, NULL, NULL, NULL, NULL);
INSERT INTO public.registrations (id, tournament_id, school_id, participant_rank, status, created_at, updated_at, user_id, participant_id, height_feet, height_inches, weight, age_at_event) VALUES (7, 4, 9, NULL, 1, '2025-12-02 23:03:28.389351', '2025-12-02 23:07:34.671768', 9, 23, NULL, NULL, NULL, NULL);
INSERT INTO public.registrations (id, tournament_id, school_id, participant_rank, status, created_at, updated_at, user_id, participant_id, height_feet, height_inches, weight, age_at_event) VALUES (9, 4, 8, NULL, 1, '2025-12-02 23:12:28.002496', '2025-12-02 23:12:50.924468', 16, 24, NULL, NULL, NULL, NULL);
INSERT INTO public.registrations (id, tournament_id, school_id, participant_rank, status, created_at, updated_at, user_id, participant_id, height_feet, height_inches, weight, age_at_event) VALUES (8, 4, 9, NULL, 1, '2025-12-02 23:11:16.185462', '2025-12-02 23:12:55.344366', 15, 25, NULL, NULL, NULL, NULL);
INSERT INTO public.registrations (id, tournament_id, school_id, participant_rank, status, created_at, updated_at, user_id, participant_id, height_feet, height_inches, weight, age_at_event) VALUES (11, 4, 9, 'black', 0, '2025-12-11 17:40:19.828112', '2025-12-11 17:44:18.327009', 20, NULL, 5, 11, 89.00, NULL);


--
-- TOC entry 4009 (class 0 OID 16449)
-- Dependencies: 230
-- Data for Name: registrations_divisions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (1, 3);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (2, 3);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (3, 4);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (3, 1);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (4, 1);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (6, 4);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (7, 3);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (7, 8);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (7, 2);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (8, 3);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (8, 8);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (8, 2);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (9, 3);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (9, 8);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (9, 2);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (11, 2);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (11, 8);
INSERT INTO public.registrations_divisions (registration_id, division_id) VALUES (11, 3);


--
-- TOC entry 4011 (class 0 OID 16455)
-- Dependencies: 232
-- Data for Name: schools; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.schools (id, school_name, school_address, school_contact, school_phone, school_logo, created_at, updated_at, registration_token, registration_link, registration_qr_code, expires_at) VALUES (11, 'Union UTA Martial Arts', '2020 Morris Avenue, Union, NJ 07083', 'Robert Nichols', '(908) 687-5559', NULL, '2025-05-08 23:16:02.944615', '2025-11-25 14:17:00.745096', 'fe61f204-afe7-47d4-b0ab-b8e810ccb931', 'http://localhost:5173/register?token=fe61f204-afe7-47d4-b0ab-b8e810ccb931&school_id=11', '\x', '2026-02-23 14:17:00.744');
INSERT INTO public.schools (id, school_name, school_address, school_contact, school_phone, school_logo, created_at, updated_at, registration_token, registration_link, registration_qr_code, expires_at) VALUES (8, 'Wushu Taekwon-Do Academy', '456 U.S. 22 West', 'Chris Leyesa', '(732) 789-4744', '\x20', '2025-03-11 22:54:48.869172', '2025-11-25 13:46:25.338839', 'b3db92bf-e368-4383-a2a9-b825a6673fcc', 'http://localhost:5173/register?token=b3db92bf-e368-4383-a2a9-b825a6673fcc&school_id=8', '\x', '2026-02-23 13:46:25.338');
INSERT INTO public.schools (id, school_name, school_address, school_contact, school_phone, school_logo, created_at, updated_at, registration_token, registration_link, registration_qr_code, expires_at) VALUES (12, 'Independent', 'N/A', 'Self', 'N/A', NULL, '2025-11-25 17:47:30.340745', '2025-11-25 17:47:30.340745', NULL, NULL, NULL, NULL);
INSERT INTO public.schools (id, school_name, school_address, school_contact, school_phone, school_logo, created_at, updated_at, registration_token, registration_link, registration_qr_code, expires_at) VALUES (9, 'Perth Amboy Martial Arts', '165 Smith St', 'Kevin Torres', '(732) 877-9229', '\x', '2026-02-22 22:45:59.528', '2025-12-02 23:02:01.802984', 'ddb62d18-7b33-4b5f-aae8-24954b6d84f4', 'http://localhost:5173/register?token=ddb62d18-7b33-4b5f-aae8-24954b6d84f4&school_id=9', '\x89504e470d0a1a0a0000000d494844520000012c0000012c0806000000797d8e7500000002494441547801ec1a7ed200000bde49444154edc1418e24419224416145feffcbbc8539f4c96c663de01559da1022fc2355550b4caaaa969854552d31a9aa5a625255b5c4a4aa6a894955d51293aaaa252655554b4caaaa969854552d31a9aa5a625255b5c4a4aa6a899f7c08c8566a4e80bc49cd53406ed43c05a4fe6f6abe05c8899aa7806ca5e6a94955d51293aaaa252655554b4caaaa969854552d31a9aa5ae2277f819adf06e41bd47c02c8899a4f003951f30920276a6e80dca8790ac88d9a1b20276ade04e446cd8d9a1320376a9e52f3db80bc695255b5c4a4aa6a894955d51293aaaa252655554bfce48b80bc49cd9bd4dc003901f226206f02f2093527406ed47c0b901b354f01794acd0d901b35276abe05c89bd47cc3a4aa6a894955d51293aaaa252655554b4caaaa969854552df193fa0f20376ade04e4b7a9f91620376a4ed4dc00790a48ed36a9aa5a625255b5c4a4aa6a894955d51293aaaa252655554bfca4fe43cd0d9037a9790ac88d9a132037406ed43c05e446cd0d901335376a6e80bc49cd9b809ca8a9ffdda4aa6a894955d51293aaaa252655554b4caaaa96f8c917a9f96fa3e64d406ed4bc49cd0d90add49c00b9517303e41b80dca879939a8d2655554b4caaaa969854552d31a9aa5a625255b5c4a4aa6a899ffc0540360272a3e604c88d9a1b20276a6e80dca8f906353740be05c88d9a6f507303e446cd09903701f96f33a9aa5a625255b5c4a4aa6a894955d51293aaaa252655554be01fa9ff01e446cd09904fa87913907f999a1b204fa97913901b3527403ea1a63e33a9aa5a625255b5c4a4aa6a894955d51293aaaa257ef22120376a4e807c42cd099037a9b901f2949a1b204fa9f997a9b901f22620376a4e80dca8b901f22620276a9e0272a3e62920376a6e803ca5e6a94955d51293aaaa252655554b4caaaa969854552d31a9aa5ae2271f52f3263537409e52f3263527406e80dca879939aa780bc09c88d9a1b209500791390a7d4dc00f96d93aaaa252655554b4caaaa969854552d31a9aa5ae2271f02f22d6a9e0272a3e604c88d9a133537406e809ca8b90172a3e604c89bd4dc00f917003951f309354f01b9517302e446cd09901b35bf4dcd9b2655554b4caaaa969854552d31a9aa5a625255b5c4a4aa6a899f7c919a1b206f52f30d406ed43c05e44d6a3e01e429359f50f314906f0172a2e646cd0d90a780fc36353740be615255b5c4a4aa6a894955d51293aaaa252655554b4caaaa96f8c95fa0e61bd4dc00794acd0d907f199013353740de04e446cd7f1b206f527303e444cd0d901b3527403ea1e604c88d9aa72655554b4caaaa969854552d31a9aa5a625255b5c44f3ea4e629209f50f3949a6f507303e446cd9bd49c00b9517303e45b80bc49cd9bd49c00f9849aa7d43ca5e6bfcda4aa6a894955d51293aaaa252655554b4caaaa969854552d817fe46540be41cd0d90a7d4dc00f96d6a6e809ca8b901f22d6a9e0272a3e62920376ade04e446cd370079939a1b204fa9796a5255b5c4a4aa6a894955d51293aaaa252655554b4caaaa96f8c98780dca8790ac88d9a1320376abe41cd0d901b3527406e803c05e446cdb700b951f30d6a6e80dca8791390dfa6e604c827d47cc3a4aa6a894955d51293aaaa252655554b4caaaa96c03ff201204fa9b901f2949a1b20376a4e80fc36359f0072a2e613404ed4dc00f9849a37013951f32f0072a2e65b809ca8f9049013356f9a54552d31a9aa5a625255b5c4a4aa6a894955d51293aaaa257ef217a8390172a3e606c8536adea4e62920376a4e80bc09c88d9a1b35df02e4b701b9517302e4136a7e9b9a8d2655554b4caaaa969854552d31a9aa5a625255b5c4a4aa6a899ffc05409e02f2149037a9f96d6a3e01e444cd27809ca8f9849a1b20276a6e80dca8f96d6a9e0272a3e64d404ed4dc00b951f30d93aaaa252655554b4caaaa969854552d31a9aa5a02ffc80780dca8790ac88d9a1320376a9e02f2263537404ed4dc00f96fa4e604c827d4bc09c8899a7f19901b354f0179939aa72655554b4caaaa969854552d31a9aa5a625255b5c4a4aa6a899f7c11906f0172a3e61b80dca8794acd6f03f209354fa9b9017203e444cdb700b951f31490370179939a13206f9a54552d31a9aa5a625255b5c4a4aa6a894955d51293aaaa257ef21700794acd536a3e01e444cd5340de04e44d6abe45cd0d901b3527403ea1e604c88d9a6f01f20d6a6e809ca8b9017203e41b2655554b4caaaa969854552d31a9aa5a625255b5c4a4aa6a09fc231f00f22d6a4e807c42cd3700f9163527406ed4dc003951f30920ff3235ff3220276ade04e44d6ade34a9aa5a625255b5c4a4aa6a894955d51293aaaa257ef217a8790ac89bd4dc00f90635df02e45fa6e65b80fc3620376ade02e44d6a3e01e404c88d9aa72655554b4caaaa969854552d31a9aa5a625255b5c4a4aa6a899ffc05409e52f32620376a4e80dca83901f20920bf0dc88d9aa780dca8f99701b9517302e446cd0d9013354fa9f91620376abe615255b5c4a4aa6a894955d51293aaaa252655554b4caaaa96c03ff225403ea1e604c88d9a370139517303e429359f0072a2e606c88d9a1320376a3e01e444cdb700794acd27809ca8b901f2949aa780bc49cd9b2655554b4caaaa969854552d31a9aa5a625255b504fe910f00794acd0d90dfa6e62920376a6e803ca5e62920376a6e807c8b9a7f199013353740be41cd0d901b3527406ed4dc00794acd5393aaaa252655554b4caaaa969854552d31a9aa5a625255b5c44fbe08c89bd47c02c80990a7d4dc00b951f32620276afe7540dea4e629206f527303e42d406ed4dc00f906356f9a54552d31a9aa5a625255b5c4a4aa6a894955d51293aaaa257ef2213537404ed47c02c809906f51f3949a1b20276a6e80dca8390172a3e65fa6e606c80d9013359f50f31490a7d4dc00d908c88d9aa72655554b4caaaa969854552d31a9aa5a625255b504fe919701794acd6f0372a3e629205ba93901f2093537404ed47c02c8899a3701b9517303e444cd53406ed47c0b9013356f9a54552d31a9aa5a625255b5c4a4aa6a894955d51293aaaa257ef22120376a4e80dc00794acd0d901b35276a6e809ca8f9163537404ed4dc0079939a7f819a1320376a9e527303e446cd09901b35df00e446cd6f9b54552d31a9aa5a625255b5c4a4aa6a894955d51293aaaa257ef221354fa9b90172a3e604c88d9aa780bc49cd0d901335ff0220dfa2e604c88d9a3701f99701790ac88d9aa780dca8390172a3e6a94955d51293aaaa252655554b4caaaa969854552df193bf00c8899a6f01f2949a6f517302e446cd5340dea4e613406ed49ca8b90172a3e644cd0d901b3527406ed4dc00f96d404ed4dc00f96d93aaaa252655554b4caaaa969854552d31a9aa5a625255b504fe91fa1f406ed49c00b9517303e429353740ea736a7e1b901b356f02f2263527406ed43c35a9aa5a625255b5c4a4aa6a894955d51293aaaa257ef221205ba9790ac8899a4fa8790ac88d9a1320376a6e809ca8f91620376a6e809ca8f90490a7d4dc00790b901b35df02e444cd9b2655554b4caaaa969854552d31a9aa5a625255b5c4a4aa6a09fc231f0072a3e6b701b9517302e45bd4fc3620376aea7340dea4e64d404ed47c02c8536a9e9a54552d31a9aa5a625255b5c4a4aa6a894955d51293aaaa257ef24540dea4e64d6a6e809ca8b901f22620376a9e52f326209f507302e446cd53403ea1e64d6a4e80dc00f96d407edba4aa6a894955d51293aaaa252655554b4caaaa96f849fd07901b35ff3220276a6e80dca83901f2093537404ed4fc0b80fc36356f027202e44d6ade34a9aa5a625255b5c4a4aa6a894955d51293aaaa252655554bfca4febf00794acd6f0372a3e606c8536a6e807c0b90a7d4dc003951f30920df00e446cd09901b3537404e80dca8796a5255b5c4a4aa6a894955d51293aaaa252655554b4caaaa96f8c917a9f997a9f997a9790ac80d901b352740fe756a9e02f22d6a4e803c05e446cd0d9013356f52f3a64955d51293aaaa252655554b4caaaa969854552df193bf00c846409e52f32620376a6e809ca8f90490133537403ea1e604c8b7a8791390370179939a1320376a7edba4aa6a894955d51293aaaa252655554b4caaaa969854552d817fa4aa6a814955d51293aaaa252655554b4caaaa969854552d31a9aa5a625255b5c4a4aa6a894955d51293aaaa252655554b4caaaa96f87fccfcbe8eaf5ca6a80000000049454e44ae426082', '2026-03-02 23:02:01.802');


--
-- TOC entry 4013 (class 0 OID 16465)
-- Dependencies: 234
-- Data for Name: scores; Type: TABLE DATA; Schema: public; Owner: wushu
--

INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (1, 4, 'B1', 2.5, '2025-02-19 03:21:54.62767', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (113, 1, 'B1', 4.8, '2025-02-24 02:47:57.911293', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (114, 1, 'A1', 4.5, '2025-02-24 02:49:30.155503', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (16, 3, 'A2', 4.7, '2025-02-20 03:17:34.721705', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (17, 5, 'A2', 4.7, '2025-02-20 03:41:08.844364', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (18, 5, 'A1', 4.4, '2025-02-20 03:41:28.251313', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (19, 5, 'A1', 3.8, '2025-02-20 03:50:38.78287', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (20, 5, 'A1', 3.6, '2025-02-20 20:51:32.028728', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (21, 5, 'A1', 3.6, '2025-02-20 21:39:13.434779', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (22, 5, 'A1', 3.5, '2025-02-20 21:39:21.901464', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (23, 5, 'A1', 3.5, '2025-02-20 21:39:35.307473', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (24, 5, 'B1', 5.0, '2025-02-20 21:40:12.201298', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (25, 5, 'A1', 3.5, '2025-02-20 21:40:21.336875', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (26, 5, 'A2', 4.7, '2025-02-20 21:40:32.355039', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (27, 5, 'A2', 4.6, '2025-02-20 21:40:41.977042', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (28, 5, 'A2', 4.6, '2025-02-20 21:40:47.843202', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (29, 5, 'A2', 4.6, '2025-02-20 21:43:50.953652', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (30, 5, 'A2', 4.6, '2025-02-20 22:06:17.449775', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (31, 5, 'A2', 4.6, '2025-02-20 22:06:27.223383', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (32, 5, 'A2', 4.2, '2025-02-20 22:06:54.365685', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (33, 2, 'B1', 2.7, '2025-02-21 01:59:41.266939', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (34, 2, 'B1', 2.7, '2025-02-21 02:10:04.042637', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (35, 2, 'B1', 2.7, '2025-02-21 02:10:08.49486', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (36, 2, 'B1', 2.7, '2025-02-21 02:10:43.269568', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (37, 2, 'B1', 2.7, '2025-02-21 02:10:51.850681', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (38, 2, 'B1', 2.7, '2025-02-21 02:11:13.602577', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (39, 2, 'B1', 2.7, '2025-02-21 02:12:03.555103', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (40, 2, 'B1', 2.7, '2025-02-21 02:12:32.328096', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (41, 2, 'B1', 2.7, '2025-02-21 02:12:49.99917', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (42, 2, 'B1', 2.7, '2025-02-21 02:32:58.548029', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (43, 2, 'B1', 2.7, '2025-02-21 02:42:45.337306', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (44, 4, 'B1', 2.5, '2025-02-21 02:42:50.94866', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (45, 4, 'A1', 4.6, '2025-02-21 02:43:08.267163', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (46, 4, 'A1', 4.6, '2025-02-21 02:43:33.394167', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (47, 4, 'A1', 4.3, '2025-02-21 02:44:00.823248', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (48, 4, 'A1', 4.0, '2025-02-21 02:44:16.385858', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (49, 4, 'A1', 3.7, '2025-02-21 02:44:30.943892', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (50, 4, 'A1', 3.7, '2025-02-21 02:44:47.154845', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (51, 4, 'A1', 3.7, '2025-02-21 02:45:08.259965', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (52, 4, 'B1', 2.5, '2025-02-21 02:55:40.715161', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (53, 4, 'B2', 5.0, '2025-02-21 02:55:53.203552', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (54, 4, 'B2', 1.1, '2025-02-21 02:55:57.83578', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (55, 2, 'A1', 4.9, '2025-02-21 02:56:24.495592', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (56, 2, 'A1', 4.9, '2025-02-21 02:56:30.517538', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (57, 2, 'A1', 4.9, '2025-02-21 03:02:57.159905', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (58, 2, 'A1', 4.6, '2025-02-21 03:03:07.87757', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (59, 2, 'A1', 4.5, '2025-02-21 03:04:59.379483', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (132, 1, 'A2', 5.0, '2025-02-24 03:17:16.449432', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (133, 1, 'FinalA', 4.8, '2025-02-24 03:17:21.794577', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (134, 1, 'FinalB', 4.5, '2025-02-24 03:17:21.800858', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (135, 1, 'Final', 9.3, '2025-02-24 03:17:21.806532', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (136, 1, 'FinalA', 4.8, '2025-02-26 02:18:54.690659', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (137, 1, 'FinalB', 4.5, '2025-02-26 02:18:54.70433', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (138, 1, 'Final', 9.3, '2025-02-26 02:18:54.709079', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (139, 1, 'A1', 4.4, '2025-02-26 18:19:01.232335', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (140, 1, 'FinalA', 4.8, '2025-02-26 18:19:15.486227', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (141, 1, 'FinalB', 4.5, '2025-02-26 18:19:15.494091', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (142, 1, 'Final', 9.3, '2025-02-26 18:19:15.49854', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (143, 1, 'A1', 4.4, '2025-03-03 01:32:39.274741', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (144, 1, 'A1', 4.3, '2025-03-03 01:32:53.824106', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (145, 1, 'A1', 4.2, '2025-03-03 01:33:21.711892', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (146, 1, 'A1', 4.2, '2025-03-03 01:33:29.620047', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (147, 1, 'A1', 4.2, '2025-03-03 01:34:03.83641', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (148, 3, 'A1', 5.0, '2025-03-03 01:34:34.925925', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (149, 3, 'A1', 4.7, '2025-03-03 01:35:10.56756', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (150, 3, 'A2', 4.6, '2025-03-03 01:35:28.659181', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (151, 3, 'B1', 3.3, '2025-03-03 01:35:39.991816', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (152, 3, 'B2', 4.4, '2025-03-03 01:35:48.813009', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (153, 3, 'FinalA', 4.9, '2025-03-03 01:36:15.452257', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (154, 3, 'FinalB', 3.9, '2025-03-03 01:36:15.461904', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (155, 3, 'Final', 8.7, '2025-03-03 01:36:15.466109', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (112, 1, 'B2', 4.2, '2025-02-24 02:47:08.930516', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (156, 3, 'FinalA', 4.9, '2025-03-10 19:29:41.276868', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (157, 3, 'FinalB', 3.9, '2025-03-10 19:29:41.285205', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (158, 3, 'Final', 8.7, '2025-03-10 19:29:41.288305', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (159, 1, 'B1', 2.3, '2025-03-10 19:37:59.821142', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (160, 2, 'A2', 4.8, '2025-03-10 19:39:35.828373', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (161, 2, 'B2', 1.6, '2025-03-10 19:39:49.440975', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (162, 2, 'FinalA', 4.9, '2025-03-10 19:39:57.501757', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (163, 2, 'FinalB', 2.2, '2025-03-10 19:39:57.517475', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (164, 2, 'Final', 7.0, '2025-03-10 19:39:57.521781', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (165, 2, 'A1', 4.3, '2025-03-12 21:48:02.655828', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (166, 2, 'B1', 4.2, '2025-03-12 21:48:22.925665', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (167, 2, 'FinalA', 4.9, '2025-03-12 21:48:43.953993', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (168, 2, 'FinalB', 2.2, '2025-03-12 21:48:43.969926', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (169, 2, 'Final', 7.0, '2025-03-12 21:48:43.973678', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (170, 2, 'FinalA', 4.9, '2025-03-13 14:26:25.461621', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (171, 2, 'FinalB', 2.2, '2025-03-13 14:26:25.479522', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (172, 2, 'Final', 7.0, '2025-03-13 14:26:25.483493', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (173, 1, 'FinalA', 4.8, '2025-03-13 23:21:32.506411', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (174, 1, 'FinalB', 4.5, '2025-03-13 23:21:32.525847', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (175, 1, 'Final', 9.3, '2025-03-13 23:21:32.529895', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (176, 8, 'A1', 4.6, '2025-03-14 00:07:30.724634', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (177, 8, 'A2', 5.0, '2025-03-14 00:07:48.792426', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (178, 8, 'B1', 3.5, '2025-03-14 00:08:00.856589', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (179, 8, 'B2', 3.5, '2025-03-14 00:08:06.640831', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (180, 8, 'FinalA', 4.8, '2025-03-14 00:08:21.82302', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (181, 8, 'FinalB', 3.5, '2025-03-14 00:08:21.826899', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (182, 8, 'Final', 8.3, '2025-03-14 00:08:21.831083', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (183, 10, 'A1', 4.9, '2025-03-14 23:52:40.704526', NULL);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (184, 10, 'A1', 4.9, '2025-03-19 17:58:43.821901', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (185, 10, 'A2', 5.0, '2025-03-19 17:59:56.969606', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (186, 10, 'B1', 3.4, '2025-03-19 18:00:01.423884', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (187, 10, 'B2', 3.6, '2025-03-19 18:00:05.731879', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (188, 10, 'FinalA', 5.0, '2025-03-19 18:00:10.641921', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (189, 10, 'FinalB', 3.5, '2025-03-19 18:00:10.648276', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (190, 10, 'Final', 8.5, '2025-03-19 18:00:10.651747', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (191, 10, 'A1', 4.6, '2025-03-19 20:52:28.390195', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (192, 10, 'A2', 5.0, '2025-03-19 20:52:48.88037', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (193, 10, 'B1', 3.9, '2025-03-19 20:52:56.003567', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (194, 10, 'B2', 3.6, '2025-03-19 20:52:59.389902', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (195, 10, 'FinalA', 5.0, '2025-03-19 20:53:15.677168', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (196, 10, 'FinalB', 3.5, '2025-03-19 20:53:15.736831', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (197, 10, 'Final', 8.5, '2025-03-19 20:53:15.746471', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (198, 10, 'A1', 4.6, '2025-03-19 20:54:25.36415', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (199, 10, 'FinalA', 5.0, '2025-03-19 21:01:13.236387', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (200, 10, 'FinalB', 3.5, '2025-03-19 21:01:13.244433', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (201, 10, 'Final', 8.5, '2025-03-19 21:01:13.252013', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (202, 8, 'A1', 5.0, '2025-03-19 21:02:57.978904', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (203, 8, 'A2', 5.0, '2025-03-19 21:03:10.497461', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (204, 8, 'B1', 1.9, '2025-03-19 21:03:18.515664', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (205, 8, 'B2', 4.5, '2025-03-19 21:03:23.887938', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (206, 8, 'FinalA', 5.0, '2025-03-19 21:03:45.421069', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (207, 8, 'FinalB', 3.2, '2025-03-19 21:03:45.477476', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (208, 8, 'Final', 8.2, '2025-03-19 21:03:45.484761', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (209, 8, 'FinalA', 5.0, '2025-03-19 21:04:13.515462', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (210, 8, 'FinalB', 3.2, '2025-03-19 21:04:13.526207', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (211, 8, 'Final', 8.2, '2025-03-19 21:04:13.534066', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (212, 8, 'B1', 3.9, '2025-03-19 21:05:25.067833', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (213, 1, 'A1', 4.6, '2025-03-24 15:58:25.835243', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (214, 1, 'A2', 5.0, '2025-03-24 15:58:36.340579', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (215, 1, 'B1', 3.7, '2025-03-24 15:58:41.649934', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (216, 1, 'B2', 4.6, '2025-03-24 15:58:46.848173', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (217, 1, 'FinalA', 4.8, '2025-03-24 15:58:59.675412', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (218, 1, 'FinalB', 4.2, '2025-03-24 15:58:59.696973', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (219, 1, 'Final', 9.0, '2025-03-24 15:58:59.703795', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (220, 1, 'FinalA', 4.8, '2025-03-24 15:59:28.335256', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (221, 1, 'FinalB', 4.2, '2025-03-24 15:59:28.355063', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (222, 1, 'Final', 9.0, '2025-03-24 15:59:28.360596', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (223, 1, 'A1', 4.9, '2025-05-20 16:56:53.768432', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (224, 1, 'A2', 5.0, '2025-05-20 16:56:59.232725', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (225, 1, 'B1', 1.4, '2025-05-20 16:57:05.231064', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (226, 1, 'B2', 2.2, '2025-05-20 16:57:11.666464', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (227, 1, 'FinalA', 5.0, '2025-05-20 16:57:23.170886', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (228, 1, 'FinalB', 1.8, '2025-05-20 16:57:23.17727', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (229, 1, 'Final', 6.8, '2025-05-20 16:57:23.182983', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (230, 3, 'A1', 4.8, '2025-05-20 21:07:31.093443', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (231, 3, 'A2', 5.0, '2025-05-20 21:07:45.347467', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (232, 3, 'B1', 3.1, '2025-05-20 21:07:52.198856', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (233, 3, 'B2', 4.5, '2025-05-20 21:07:56.662769', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (234, 3, 'FinalA', 4.9, '2025-05-20 21:08:17.189928', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (235, 3, 'FinalB', 3.8, '2025-05-20 21:08:17.196068', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (236, 3, 'Final', 8.7, '2025-05-20 21:08:17.201076', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (237, 3, 'FinalA', 4.9, '2025-05-20 21:08:42.722583', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (238, 3, 'FinalB', 3.8, '2025-05-20 21:08:42.729725', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (239, 3, 'Final', 8.7, '2025-05-20 21:08:42.735269', 3);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (240, 3, 'A1', 5.0, '2025-05-20 21:48:32.899096', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (241, 3, 'A2', 5.0, '2025-05-20 21:48:37.092524', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (242, 3, 'B1', 2.6, '2025-05-20 21:48:45.891811', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (243, 3, 'B2', 1.2, '2025-05-20 21:48:51.932753', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (244, 3, 'FinalA', 5.0, '2025-05-20 21:49:01.313078', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (245, 3, 'FinalB', 1.9, '2025-05-20 21:49:01.320161', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (246, 3, 'Final', 6.9, '2025-05-20 21:49:01.325661', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (247, 2, 'A1', 3.9, '2025-05-22 15:38:21.079242', 8);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (248, 2, 'A2', 4.6, '2025-05-22 15:38:50.99202', 8);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (249, 2, 'B1', 4.5, '2025-05-22 15:38:59.227886', 8);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (250, 2, 'B2', 4.1, '2025-05-22 15:39:07.215606', 8);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (251, 2, 'FinalA', 4.3, '2025-05-22 15:39:19.004594', 8);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (252, 2, 'FinalB', 4.3, '2025-05-22 15:39:19.010808', 8);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (253, 2, 'Final', 8.6, '2025-05-22 15:39:19.016338', 8);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (254, 2, 'A1', 3.7, '2025-05-23 12:42:47.909379', 8);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (255, 2, 'A2', 4.3, '2025-05-23 12:43:04.281121', 8);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (256, 2, 'B1', 4.8, '2025-05-23 12:43:11.209706', 8);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (257, 2, 'B2', 2.8, '2025-05-23 12:43:19.375795', 8);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (258, 2, 'FinalA', 4.3, '2025-05-23 12:43:31.65128', 8);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (259, 2, 'FinalB', 4.3, '2025-05-23 12:43:31.655962', 8);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (260, 2, 'Final', 8.6, '2025-05-23 12:43:31.659826', 8);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (261, 2, 'A1', 4.4, '2025-05-23 14:28:43.165361', 8);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (262, 10, 'A1', 4.4, '2025-11-22 23:50:23.546513', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (263, 10, 'A1', 4.4, '2025-11-22 23:50:31.750505', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (264, 10, 'A1', 5.0, '2025-11-22 23:50:54.162603', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (265, 10, 'A2', 4.9, '2025-11-22 23:51:08.92015', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (266, 10, 'B2', 3.8, '2025-11-22 23:51:26.06548', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (267, 10, 'B1', 2.4, '2025-11-22 23:51:38.109596', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (268, 10, 'FinalA', 4.7, '2025-11-22 23:52:00.439286', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (269, 10, 'FinalB', 3.1, '2025-11-22 23:52:00.4451', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (270, 10, 'Final', 7.8, '2025-11-22 23:52:00.449092', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (271, 1, 'B2', 2.4, '2025-11-22 23:53:03.088028', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (272, 1, 'B1', 0.9, '2025-11-22 23:53:13.033338', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (273, 1, 'A2', 4.7, '2025-11-22 23:53:49.438243', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (274, 1, 'A2', 4.7, '2025-11-22 23:54:14.042195', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (275, 1, 'A1', 4.7, '2025-11-22 23:54:39.465959', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (276, 1, 'A1', 5.0, '2025-11-22 23:55:00.136199', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (277, 1, 'FinalA', 4.8, '2025-11-22 23:55:10.945454', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (278, 1, 'FinalB', 4.2, '2025-11-22 23:55:10.951444', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (279, 1, 'Final', 9.0, '2025-11-22 23:55:10.955651', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (280, 7, 'A1', 4.7, '2025-11-22 23:56:09.979522', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (281, 7, 'A2', 4.7, '2025-11-22 23:56:21.694751', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (282, 7, 'B2', 4.0, '2025-11-22 23:56:31.547945', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (283, 7, 'B1', 3.6, '2025-11-22 23:56:38.419588', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (284, 7, 'FinalA', 4.7, '2025-11-22 23:56:55.763816', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (285, 7, 'FinalB', 3.8, '2025-11-22 23:56:55.769576', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (286, 7, 'Final', 8.5, '2025-11-22 23:56:55.775324', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (287, 17, 'A1', 4.4, '2025-11-23 00:02:14.861524', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (288, 17, 'A2', 4.5, '2025-11-23 00:02:38.036345', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (289, 17, 'B1', 4.5, '2025-11-23 00:02:47.531416', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (290, 17, 'B2', 5.0, '2025-11-23 00:03:08.980822', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (291, 17, 'FinalA', 4.5, '2025-11-23 00:03:22.927125', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (292, 17, 'FinalB', 4.8, '2025-11-23 00:03:22.932781', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (293, 17, 'Final', 9.2, '2025-11-23 00:03:22.937182', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (294, 18, 'A1', 5.0, '2025-11-27 00:18:32.492724', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (295, 18, 'A2', 4.9, '2025-11-27 00:19:02.826593', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (296, 18, 'B1', 3.4, '2025-11-27 00:19:10.131884', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (297, 18, 'B2', 2.1, '2025-11-27 00:19:15.980618', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (298, 18, 'A1', 4.9, '2025-11-27 22:50:43.960527', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (299, 18, 'A2', 5.0, '2025-11-27 22:50:58.762823', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (300, 18, 'B1', 4.4, '2025-11-27 22:51:03.820662', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (301, 18, 'B2', 5.0, '2025-11-27 22:51:09.823776', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (302, 20, 'B1', 3.8, '2025-11-27 23:02:46.423264', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (303, 20, 'B2', 1.7, '2025-11-27 23:02:55.540538', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (304, 20, 'A1', 4.6, '2025-11-27 23:07:11.112773', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (305, 20, 'A2', 4.9, '2025-11-27 23:07:31.513686', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (306, 20, 'A1', 4.6, '2025-11-27 23:23:46.066456', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (307, 20, 'A2', 4.2, '2025-11-27 23:24:06.055903', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (308, 20, 'B1', 3.7, '2025-11-27 23:24:13.780713', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (309, 20, 'B2', 1.8, '2025-11-27 23:24:20.351207', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (310, 18, 'A1', 4.5, '2025-11-27 23:36:15.531773', 1);
INSERT INTO public.scores (id, participant_id, judge, score, created_at, division_id) VALUES (311, 18, 'B1', 3.9, '2025-11-27 23:36:29.59895', 1);


--
-- TOC entry 4015 (class 0 OID 16475)
-- Dependencies: 236
-- Data for Name: tournament_details; Type: TABLE DATA; Schema: public; Owner: wushu
--

INSERT INTO public.tournament_details (argument, value) VALUES ('JudgeA2_open', 1);
INSERT INTO public.tournament_details (argument, value) VALUES ('JudgeB2_open', 1);
INSERT INTO public.tournament_details (argument, value) VALUES ('JudgeB1_open', 1);
INSERT INTO public.tournament_details (argument, value) VALUES ('JudgeA1_open', 1);
INSERT INTO public.tournament_details (argument, value) VALUES ('Judge_B2', 0);
INSERT INTO public.tournament_details (argument, value) VALUES ('Judge_B1', 0);
INSERT INTO public.tournament_details (argument, value) VALUES ('Judge_A1', 0);
INSERT INTO public.tournament_details (argument, value) VALUES ('Judge_A2', 0);
INSERT INTO public.tournament_details (argument, value) VALUES ('Active_ID', 0);
INSERT INTO public.tournament_details (argument, value) VALUES ('OnDeck_ID', 0);


--
-- TOC entry 4016 (class 0 OID 16480)
-- Dependencies: 237
-- Data for Name: tournament_divisions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tournament_divisions (tournament_id, division_id) VALUES (2, 2);
INSERT INTO public.tournament_divisions (tournament_id, division_id) VALUES (2, 3);
INSERT INTO public.tournament_divisions (tournament_id, division_id) VALUES (2, 4);
INSERT INTO public.tournament_divisions (tournament_id, division_id) VALUES (2, 8);
INSERT INTO public.tournament_divisions (tournament_id, division_id) VALUES (2, 1);
INSERT INTO public.tournament_divisions (tournament_id, division_id) VALUES (1, 2);
INSERT INTO public.tournament_divisions (tournament_id, division_id) VALUES (1, 3);
INSERT INTO public.tournament_divisions (tournament_id, division_id) VALUES (1, 4);
INSERT INTO public.tournament_divisions (tournament_id, division_id) VALUES (1, 8);
INSERT INTO public.tournament_divisions (tournament_id, division_id) VALUES (1, 1);
INSERT INTO public.tournament_divisions (tournament_id, division_id) VALUES (3, 1);
INSERT INTO public.tournament_divisions (tournament_id, division_id) VALUES (3, 4);
INSERT INTO public.tournament_divisions (tournament_id, division_id) VALUES (4, 3);
INSERT INTO public.tournament_divisions (tournament_id, division_id) VALUES (4, 8);
INSERT INTO public.tournament_divisions (tournament_id, division_id) VALUES (4, 2);


--
-- TOC entry 4017 (class 0 OID 16485)
-- Dependencies: 238
-- Data for Name: tournament_participants; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (10, 3, '2025-03-13 14:32:05.034488', '2025-03-13 14:32:05.034488', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (10, 1, '2025-03-13 14:32:09.698217', '2025-03-13 14:32:09.698217', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (1, 3, '2025-03-14 23:30:55.721469', '2025-03-14 23:30:55.721469', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (1, 1, '2025-03-14 23:30:58.481066', '2025-03-14 23:30:58.481066', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (7, 1, '2025-03-14 23:31:04.998472', '2025-03-14 23:31:04.998472', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (3, 3, '2025-03-14 23:31:19.075999', '2025-03-14 23:31:19.075999', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (3, 2, '2025-03-14 23:31:20.989105', '2025-03-14 23:31:20.989105', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (3, 1, '2025-03-14 23:31:22.862934', '2025-03-14 23:31:22.862934', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (9, 2, '2025-03-14 23:31:27.71688', '2025-03-14 23:31:27.71688', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (6, 2, '2025-03-14 23:31:34.07531', '2025-03-14 23:31:34.07531', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (6, 3, '2025-03-14 23:31:36.820649', '2025-03-14 23:31:36.820649', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (2, 3, '2025-03-14 23:31:51.071328', '2025-03-14 23:31:51.071328', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (2, 1, '2025-03-14 23:31:59.126476', '2025-03-14 23:31:59.126476', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (11, 3, '2025-03-14 23:32:04.143814', '2025-03-14 23:32:04.143814', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (11, 1, '2025-03-14 23:32:06.235451', '2025-03-14 23:32:06.235451', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (5, 4, '2025-03-19 20:50:17.639216', '2025-03-19 20:50:17.639216', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (8, 4, '2025-03-23 22:41:23.18145', '2025-03-23 22:41:23.18145', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (8, 3, '2025-03-24 13:22:15.689194', '2025-03-24 13:22:15.689194', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (5, 8, '2025-05-22 15:36:04.717285', '2025-05-22 15:36:04.717285', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (4, 8, '2025-05-22 15:36:17.980684', '2025-05-22 15:36:17.980684', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (11, 8, '2025-05-22 15:36:49.25421', '2025-05-22 15:36:49.25421', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (2, 8, '2025-05-22 15:37:08.87655', '2025-05-22 15:37:08.87655', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (16, 8, '2025-11-22 23:46:43.650184', '2025-11-22 23:46:43.650184', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (16, 2, '2025-11-22 23:46:48.96347', '2025-11-22 23:46:48.96347', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (17, 4, '2025-11-22 23:48:54.639155', '2025-11-22 23:48:54.639155', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (17, 1, '2025-11-22 23:48:58.043583', '2025-11-22 23:48:58.043583', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (18, 1, '2025-11-25 14:06:47.706759', '2025-11-25 14:06:47.706759', 3);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (19, 4, '2025-11-26 23:39:10.427609', '2025-11-26 23:39:10.427609', 3);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (20, 4, '2025-11-27 22:50:02.43115', '2025-11-27 22:50:02.43115', 3);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (20, 1, '2025-11-27 22:50:02.43115', '2025-11-27 22:50:02.43115', 3);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (21, 3, '2025-12-02 22:57:39.730836', '2025-12-02 22:57:39.730836', 3);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (22, 3, '2025-12-02 22:57:43.025452', '2025-12-02 22:57:43.025452', 1);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (23, 3, '2025-12-02 23:07:34.671768', '2025-12-02 23:07:34.671768', 4);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (23, 8, '2025-12-02 23:07:34.671768', '2025-12-02 23:07:34.671768', 4);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (23, 2, '2025-12-02 23:07:34.671768', '2025-12-02 23:07:34.671768', 4);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (24, 3, '2025-12-02 23:12:50.924468', '2025-12-02 23:12:50.924468', 4);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (24, 8, '2025-12-02 23:12:50.924468', '2025-12-02 23:12:50.924468', 4);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (24, 2, '2025-12-02 23:12:50.924468', '2025-12-02 23:12:50.924468', 4);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (25, 3, '2025-12-02 23:12:55.344366', '2025-12-02 23:12:55.344366', 4);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (25, 8, '2025-12-02 23:12:55.344366', '2025-12-02 23:12:55.344366', 4);
INSERT INTO public.tournament_participants (participant_id, division_id, created_at, updated_at, tournament_id) VALUES (25, 2, '2025-12-02 23:12:55.344366', '2025-12-02 23:12:55.344366', 4);


--
-- TOC entry 4018 (class 0 OID 16493)
-- Dependencies: 239
-- Data for Name: tournament_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tournament_results (id, tournament_id, participant_id, division_id, total_score, rank, score_breakdown, created_at) VALUES (5, 3, 20, 1, 6.13, NULL, '{"avg_a": "4.58", "avg_b": "2.75", "deductions": "1.20", "raw_scores": [{"judge": "B1", "score": "3.8"}, {"judge": "B2", "score": "1.7"}, {"judge": "A1", "score": "4.6"}, {"judge": "A2", "score": "4.9"}, {"judge": "A1", "score": "4.6"}, {"judge": "A2", "score": "4.2"}, {"judge": "B1", "score": "3.7"}, {"judge": "B2", "score": "1.8"}]}', '2025-11-27 23:24:34.970949');
INSERT INTO public.tournament_results (id, tournament_id, participant_id, division_id, total_score, rank, score_breakdown, created_at) VALUES (1, 3, 18, 1, 8.02, NULL, '{"avg_a": "4.86", "avg_b": "3.76", "deductions": "0.60", "raw_scores": [{"judge": "A1", "score": "5.0"}, {"judge": "A2", "score": "4.9"}, {"judge": "B1", "score": "3.4"}, {"judge": "B2", "score": "2.1"}, {"judge": "A1", "score": "4.9"}, {"judge": "A2", "score": "5.0"}, {"judge": "B1", "score": "4.4"}, {"judge": "B2", "score": "5.0"}, {"judge": "A1", "score": "4.5"}, {"judge": "B1", "score": "3.9"}]}', '2025-11-27 23:36:38.621074');


--
-- TOC entry 4020 (class 0 OID 16502)
-- Dependencies: 241
-- Data for Name: tournament_schools; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tournament_schools (tournament_id, school_id) VALUES (3, 9);
INSERT INTO public.tournament_schools (tournament_id, school_id) VALUES (3, 8);
INSERT INTO public.tournament_schools (tournament_id, school_id) VALUES (3, 11);
INSERT INTO public.tournament_schools (tournament_id, school_id) VALUES (3, 12);
INSERT INTO public.tournament_schools (tournament_id, school_id) VALUES (4, 12);
INSERT INTO public.tournament_schools (tournament_id, school_id) VALUES (4, 9);
INSERT INTO public.tournament_schools (tournament_id, school_id) VALUES (4, 11);
INSERT INTO public.tournament_schools (tournament_id, school_id) VALUES (4, 8);


--
-- TOC entry 4021 (class 0 OID 16507)
-- Dependencies: 242
-- Data for Name: tournaments; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tournaments (tournament_id, tournament_title, tournament_start_date, tournament_end_date, tournament_hours, tournament_contact, tournament_address, tournament_city, tournament_state, tournament_country, tournament_email, is_active, updated_at, created_at, tournament_logo, color_primary, color_background, details_content, judges_config, registration_start_date, registration_end_date) VALUES (2, 'Winter Open 2025', '2025-11-24', '2025-11-26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, '2025-11-24 16:53:47.333577', '2025-11-24 16:53:42.959847', NULL, '#1E40AF', '#F3F4F6', NULL, '{"A1": true, "A2": true, "B1": true, "B2": true}', NULL, NULL);
INSERT INTO public.tournaments (tournament_id, tournament_title, tournament_start_date, tournament_end_date, tournament_hours, tournament_contact, tournament_address, tournament_city, tournament_state, tournament_country, tournament_email, is_active, updated_at, created_at, tournament_logo, color_primary, color_background, details_content, judges_config, registration_start_date, registration_end_date) VALUES (3, 'Winter Cup 2026', '2025-11-12', '2025-11-15', NULL, '9086937777', '8 Stone House Dr', 'Whitehouse Station', 'NJ', NULL, 'rsetti@msn.com', false, '2025-12-11 02:27:31.206089', '2025-11-24 22:10:08.8431', '', '#d01616', '#d01616', 'Taking place alongside the USAWKF Junior Team Trials, the Winter Presidential Wushu Cup offers athletes an additional exciting competition with the option to qualify for the USA Kungfu Team (Kungfu Team Trials).

Event details and schedules can additionally be found at www.PresidentialWushuCup.com.

Tickets are required for all non-athletes, for both Team Trials and Winter Presidential Wushu Cup, with the exception of one coach per team, judges and VIPs:

$40 for the entire competition pass
$20 for a single-day pass', '{"A1": true, "A2": false, "B1": true, "B2": false}', NULL, NULL);
INSERT INTO public.tournaments (tournament_id, tournament_title, tournament_start_date, tournament_end_date, tournament_hours, tournament_contact, tournament_address, tournament_city, tournament_state, tournament_country, tournament_email, is_active, updated_at, created_at, tournament_logo, color_primary, color_background, details_content, judges_config, registration_start_date, registration_end_date) VALUES (4, 'New tournament for Test', '2025-12-01', '2025-12-06', NULL, '9086937777', '8 Stone House Dr', 'Whitehouse Station', 'NJ', NULL, 'rsetti@msn.com', true, '2025-12-11 02:27:44.181417', '2025-12-02 22:56:15.926383', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAANgAAADYCAYAAACJIC3tAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYxIDY0LjE0MDk0OSwgMjAxMC8xMi8wNy0xMDo1NzowMSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNS4xIFdpbmRvd3MiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6NjNGNDYyOTk5RTA0MTFFNzgwQ0REMDNGODQ3MTc3NEQiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NjNGNDYyOUE5RTA0MTFFNzgwQ0REMDNGODQ3MTc3NEQiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDo2M0Y0NjI5NzlFMDQxMUU3ODBDREQwM0Y4NDcxNzc0RCIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDo2M0Y0NjI5ODlFMDQxMUU3ODBDREQwM0Y4NDcxNzc0RCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Po+xb7sAAPJLSURBVHja7J0FnF3l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', '#1E40AF', '#F3F4F6', '', '{"A1": true, "A2": true, "B1": true, "B2": true}', '2025-12-01', '2025-12-31');
INSERT INTO public.tournaments (tournament_id, tournament_title, tournament_start_date, tournament_end_date, tournament_hours, tournament_contact, tournament_address, tournament_city, tournament_state, tournament_country, tournament_email, is_active, updated_at, created_at, tournament_logo, color_primary, color_background, details_content, judges_config, registration_start_date, registration_end_date) VALUES (1, 'Legacy Tournament', '2025-11-24', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, '2025-12-11 02:25:30.865849', '2025-11-24 16:48:18.357118', NULL, '#1E40AF', '#F3F4F6', '', '{"A1": true, "A2": true, "B1": true, "B2": true}', '2025-12-01', '2025-12-31');


--
-- TOC entry 4023 (class 0 OID 16520)
-- Dependencies: 244
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (1, 'admin', '$2b$10$kzPBq/podcAC36lvN8QjyOkGTXu7IsX81hnHoolZnWGKNdf3hf7um', 'admin', '2025-03-23 16:33:46.734346', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767', true, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (2, 'headjudge', '$2b$10$bHx.unxdANriEbpbY68jG.RQ08rs9e34vVP1e2RhHXpp7ex9mbXiq', 'head_judge', '2025-03-23 16:33:46.734346', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767', true, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (3, 'judgea1', '$2b$10$rSnus9aYn21g0rli3FK6KevCEGwdLPVPzMTSX./FkYKnqgnOkYbHC', 'judge_a', '2025-03-23 16:33:46.734346', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767', true, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (4, 'judgea2', '$2b$10$52QtWSZCzNaXr8zJjAh3nexcNqR0gRuQrYKYzz31Vj86ndS6i8eyq', 'judge_a', '2025-03-23 16:33:46.734346', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767', true, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (5, 'judgeb1', '$2b$10$M6HNp8o5OLsN1aLfPjQPMuKbbNAo5quWH1ARn8zS8oihHDsK2hPjW', 'judge_b', '2025-03-23 16:33:46.734346', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767', true, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (6, 'judgeb2', '$2b$10$N7o8XfuhKQE6cwCNsRkVeO/N9SrJZhOCf.1IMdF/e92.cCmY0YqTe', 'judge_b', '2025-03-23 16:33:46.734346', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767', true, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (8, 'fff@fff.fff', '$2b$10$MIoeaTAIDPPp4V38e0Da5e.QnTN5D.7y5WwPfbavTseM0YMbuNjVC', 'participant', '2025-11-25 21:16:58.126452', 'fff@fff.fff', 'sdfsdfsfsdf', '', 'sdsdfsdfsdf', '2025-11-13', 'M', NULL, NULL, NULL, '', '', '', '', '', '', '', '', '2025-11-26 23:36:13.197767', true, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (9, 'rsetti@msn.com', '$2b$10$M6Qh2EDvnQuEnW1J9OJwIeQDt8oVZzSdK9SBz4W/tU6txcwurMYYO', 'participant', '2025-11-25 21:16:58.126452', 'rsetti@msn.com', 'Ricardo', NULL, 'Balbachevsky Settissss', '2025-11-12', 'M', NULL, NULL, NULL, '9086937777', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767', true, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (10, 'rsetti2@msn.com', '$2b$10$bohq.JFHnimfPyPSwysI5.czDd31LbAlNJ8FCpnBeHPWgaO1cmGMS', 'participant', '2025-11-25 21:16:58.126452', 'rsetti2@msn.com', 'Ricardo', NULL, 'Balbachevsky Setti', '2025-10-27', 'M', NULL, NULL, NULL, '9086937777', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767', true, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (11, 'rsetti3@msn.com', '$2b$10$M7X3uKqpugyf2kRV3XFUke8KXItgsFcW1vdb6EUrMMreepg.uuLyC', 'participant', '2025-11-25 21:16:58.126452', 'rsetti3@msn.com', 'Ricardo', '', 'Balbachevsky Setti', '2025-10-31', 'M', NULL, NULL, NULL, '9086937777', '', '', '', '', '', '', '', '2025-11-26 23:36:13.197767', true, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (13, 'rsetti6@msn.com', '$2b$10$51k.0/a4KTH7k.0i2QcZTuUEPXMnDKgkdEz2Dg9LMhztekiYcD1Eu', 'participant', '2025-11-25 22:15:02.934759', 'rsetti6@msn.com', 'Ricardo', NULL, 'Balbachevsky Setti', '2025-11-20', 'M', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767', true, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (14, 'rsetti7@msn.com', '$2b$10$cX0Bp1m9.eCjaoTQys.63e1fmIPjdDhMRJMQBqlwUVGMv2R04tpfW', 'participant', '2025-11-25 22:17:21.353375', 'rsetti7@msn.com', 'Ricardo', NULL, 'Balbachevsky Setti', '2025-11-11', 'M', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:58.57539', true, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (15, 'pauloborelli@uol.com.br', '$2b$10$45.N4Q1lj3mImJmWIiI42u7ELZZ2y9ESW0KvNLoEzngVaHHkT238y', 'participant', '2025-12-02 23:11:16.288236', 'pauloborelli@uol.com.br', 'Paulo', NULL, 'Borelli', '1978-01-01', 'M', 5, 11, 90.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-02 23:11:16.288236', true, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (16, 'alicelobo@hotmail.com', '$2b$10$E86pLnfNfYS/EyufRpuNBO2xCcym95NTF4hn5reOq81Wy5QlIweom', 'participant', '2025-12-02 23:12:28.104537', 'alicelobo@hotmail.com', 'Alice', NULL, 'Lobo', '1978-02-19', 'F', 5, 8, 50.00, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-02 23:12:28.104537', true, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (20, 'ricsetti15@gmail.com', '$2b$10$HCxPmZbKeadbsyUCNOhZO./8Cm1QYkN5DgJHyaFFx3.QVIXyx9zKW', 'participant', '2025-12-10 16:22:27.776476', 'ricsetti15@gmail.com', 'Ricardo', NULL, 'Balbachevsky Setti', '2025-12-22', 'M', NULL, NULL, NULL, '9086937777', NULL, NULL, '8 Stone House Dr', 'Whitehouse Station', 'NJ', 'USA', '08889', '2025-12-10 16:22:27.776476', true, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (21, 'ricsetti16@gmail.com', '$2b$10$.E4H2WIXV1Z/iMUakl8w.umGF9qjmbEFNm.ysgfHvr/E51DNb2dFK', 'participant', '2025-12-10 17:23:05.234253', 'ricsetti16@gmail.com', 'Ricardo', NULL, 'Balbachevsky Setti', '2025-12-05', 'M', NULL, NULL, NULL, '9086937777', NULL, NULL, '8 Stone House Dr', 'Whitehouse Station', 'NJ', 'USA', '08889', '2025-12-10 17:23:05.234253', false, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (22, 'ricsetti20@gmail.com', '$2b$10$MVTsaWRJ/FWIGj2RbPg0Qul5HDGiovADnjuU4Saav2C.o0LnIUBQu', 'participant', '2025-12-10 17:25:12.84859', 'ricsetti20@gmail.com', 'Ricardo', NULL, 'Balbachevsky Setti', '2025-12-11', 'M', NULL, NULL, NULL, '9086937777', NULL, NULL, '8 Stone House Dr', 'Whitehouse Station', 'NJ', 'USA', '08889', '2025-12-10 17:25:12.84859', false, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (17, 'ricsetti@gmail.com', '$2b$10$7f8eAoba1EJAVFo1eqCDye1rZnTzDc3PcfdUZZ5A/ilI8gyfXOS2u', 'participant', '2025-12-10 01:14:03.571438', 'ricsetti@gmail.com', 'Ricardo', NULL, 'Ten', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-12-10 01:14:03.571438', true, NULL, NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (19, 'ricsetti14@gmail.com', '$2b$10$BlF/ne2A.eHDe3S61OJ3t.j78BlJa7z4E6ryUA0H01PYcISM60VMS', 'participant', '2025-12-10 15:44:52.894234', 'ricsetti14@gmail.com', 'Ricardo', NULL, 'Balbachevsky Setti', '2025-12-03', 'M', NULL, NULL, NULL, '9086937777', NULL, NULL, '8 Stone House Dr', 'Whitehouse Station', 'NJ', 'USA', '08889', '2025-12-10 15:44:52.894234', false, '7012cdcb-0129-4e01-b9ac-d7637c1659bd', NULL, NULL);
INSERT INTO public.users (id, username, password, role, created_at, email, first_name, middle_name, last_name, birthdate, gender, height_feet, height_inches, weight, phone, emergency_contact_name, emergency_contact_phone, street, city, state, country, zip_code, updated_at, is_verified, verification_token, reset_password_token, reset_password_expires) VALUES (23, 'ricsetti21@gmail.com', '$2b$10$0002DL7gOZZOKHwvoCzguOcPSYF3RF.v0SVXsHi9/hvJ14ioAyAMe', 'participant', '2025-12-10 17:40:28.367391', 'ricsetti21@gmail.com', 'Ricardo', NULL, 'Balbachevsky Setti', '2025-12-02', 'M', NULL, NULL, NULL, '9086937777', NULL, NULL, '8 Stone House Dr', 'Whitehouse Station', 'NJ', 'USA', '08889', '2025-12-10 17:40:28.367391', true, NULL, NULL, NULL);


--
-- TOC entry 4044 (class 0 OID 0)
-- Dependencies: 220
-- Name: deductions_deduction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.deductions_deduction_id_seq', 4, true);


--
-- TOC entry 4045 (class 0 OID 0)
-- Dependencies: 222
-- Name: divisions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.divisions_id_seq', 9, true);


--
-- TOC entry 4046 (class 0 OID 0)
-- Dependencies: 224
-- Name: participant_deductions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.participant_deductions_id_seq', 140, true);


--
-- TOC entry 4047 (class 0 OID 0)
-- Dependencies: 226
-- Name: participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.participants_id_seq', 25, true);


--
-- TOC entry 4048 (class 0 OID 0)
-- Dependencies: 228
-- Name: published_scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.published_scores_id_seq', 182, true);


--
-- TOC entry 4049 (class 0 OID 0)
-- Dependencies: 231
-- Name: registrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.registrations_id_seq', 11, true);


--
-- TOC entry 4050 (class 0 OID 0)
-- Dependencies: 233
-- Name: schools_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schools_id_seq', 12, true);


--
-- TOC entry 4051 (class 0 OID 0)
-- Dependencies: 235
-- Name: scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.scores_id_seq', 311, true);


--
-- TOC entry 4052 (class 0 OID 0)
-- Dependencies: 240
-- Name: tournament_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tournament_results_id_seq', 7, true);


--
-- TOC entry 4053 (class 0 OID 0)
-- Dependencies: 243
-- Name: tournaments_tournament_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tournaments_tournament_id_seq', 4, true);


--
-- TOC entry 4054 (class 0 OID 0)
-- Dependencies: 245
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 23, true);


--
-- TOC entry 3785 (class 2606 OID 16544)
-- Name: deductions deductions_deduction_code_key; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.deductions
    ADD CONSTRAINT deductions_deduction_code_key UNIQUE (deduction_code);


--
-- TOC entry 3787 (class 2606 OID 16546)
-- Name: deductions deductions_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.deductions
    ADD CONSTRAINT deductions_pkey PRIMARY KEY (deduction_id);


--
-- TOC entry 3789 (class 2606 OID 16548)
-- Name: divisions divisions_division_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.divisions
    ADD CONSTRAINT divisions_division_name_key UNIQUE (division_name);


--
-- TOC entry 3791 (class 2606 OID 16550)
-- Name: divisions divisions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.divisions
    ADD CONSTRAINT divisions_pkey PRIMARY KEY (id);


--
-- TOC entry 3793 (class 2606 OID 16552)
-- Name: participant_deductions participant_deductions_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions
    ADD CONSTRAINT participant_deductions_pkey PRIMARY KEY (id);


--
-- TOC entry 3795 (class 2606 OID 16554)
-- Name: participants participants_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_pkey PRIMARY KEY (id);


--
-- TOC entry 3797 (class 2606 OID 16556)
-- Name: published_scores published_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores
    ADD CONSTRAINT published_scores_pkey PRIMARY KEY (id);


--
-- TOC entry 3801 (class 2606 OID 16558)
-- Name: registrations_divisions registrations_divisions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations_divisions
    ADD CONSTRAINT registrations_divisions_pkey PRIMARY KEY (registration_id, division_id);


--
-- TOC entry 3799 (class 2606 OID 16560)
-- Name: registrations registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_pkey PRIMARY KEY (id);


--
-- TOC entry 3804 (class 2606 OID 16562)
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- TOC entry 3806 (class 2606 OID 16564)
-- Name: scores scores_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_pkey PRIMARY KEY (id);


--
-- TOC entry 3808 (class 2606 OID 16566)
-- Name: tournament_details tournament_details_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.tournament_details
    ADD CONSTRAINT tournament_details_pkey PRIMARY KEY (argument);


--
-- TOC entry 3810 (class 2606 OID 16568)
-- Name: tournament_divisions tournament_divisions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_divisions
    ADD CONSTRAINT tournament_divisions_pkey PRIMARY KEY (tournament_id, division_id);


--
-- TOC entry 3812 (class 2606 OID 16570)
-- Name: tournament_participants tournament_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_pkey PRIMARY KEY (participant_id, division_id);


--
-- TOC entry 3814 (class 2606 OID 16572)
-- Name: tournament_results tournament_results_participant_id_division_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_results
    ADD CONSTRAINT tournament_results_participant_id_division_id_key UNIQUE (participant_id, division_id);


--
-- TOC entry 3816 (class 2606 OID 16574)
-- Name: tournament_results tournament_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_results
    ADD CONSTRAINT tournament_results_pkey PRIMARY KEY (id);


--
-- TOC entry 3818 (class 2606 OID 16576)
-- Name: tournament_schools tournament_schools_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_schools
    ADD CONSTRAINT tournament_schools_pkey PRIMARY KEY (tournament_id, school_id);


--
-- TOC entry 3820 (class 2606 OID 16578)
-- Name: tournaments tournaments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_pkey PRIMARY KEY (tournament_id);


--
-- TOC entry 3822 (class 2606 OID 16580)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 3824 (class 2606 OID 16582)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3826 (class 2606 OID 16584)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 3802 (class 1259 OID 16585)
-- Name: idx_schools_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_schools_name ON public.schools USING btree (school_name);


--
-- TOC entry 3830 (class 2606 OID 16586)
-- Name: participants fk_school; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT fk_school FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 3827 (class 2606 OID 16591)
-- Name: participant_deductions participant_deductions_deduction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions
    ADD CONSTRAINT participant_deductions_deduction_id_fkey FOREIGN KEY (deduction_id) REFERENCES public.deductions(deduction_id) ON DELETE CASCADE;


--
-- TOC entry 3828 (class 2606 OID 16596)
-- Name: participant_deductions participant_deductions_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions
    ADD CONSTRAINT participant_deductions_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE SET NULL;


--
-- TOC entry 3829 (class 2606 OID 16601)
-- Name: participant_deductions participant_deductions_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions
    ADD CONSTRAINT participant_deductions_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 3831 (class 2606 OID 16606)
-- Name: participants participants_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 3832 (class 2606 OID 16611)
-- Name: participants participants_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(tournament_id);


--
-- TOC entry 3833 (class 2606 OID 16616)
-- Name: published_scores published_scores_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores
    ADD CONSTRAINT published_scores_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE SET NULL;


--
-- TOC entry 3834 (class 2606 OID 16621)
-- Name: published_scores published_scores_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores
    ADD CONSTRAINT published_scores_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 3839 (class 2606 OID 16626)
-- Name: registrations_divisions registrations_divisions_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations_divisions
    ADD CONSTRAINT registrations_divisions_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE CASCADE;


--
-- TOC entry 3840 (class 2606 OID 16631)
-- Name: registrations_divisions registrations_divisions_registration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations_divisions
    ADD CONSTRAINT registrations_divisions_registration_id_fkey FOREIGN KEY (registration_id) REFERENCES public.registrations(id) ON DELETE CASCADE;


--
-- TOC entry 3835 (class 2606 OID 16636)
-- Name: registrations registrations_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id);


--
-- TOC entry 3836 (class 2606 OID 16641)
-- Name: registrations registrations_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- TOC entry 3837 (class 2606 OID 16646)
-- Name: registrations registrations_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(tournament_id);


--
-- TOC entry 3838 (class 2606 OID 16651)
-- Name: registrations registrations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 3841 (class 2606 OID 16656)
-- Name: scores scores_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE SET NULL;


--
-- TOC entry 3842 (class 2606 OID 16661)
-- Name: scores scores_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 3843 (class 2606 OID 16666)
-- Name: tournament_divisions tournament_divisions_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_divisions
    ADD CONSTRAINT tournament_divisions_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE CASCADE;


--
-- TOC entry 3844 (class 2606 OID 16671)
-- Name: tournament_participants tournament_participants_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE CASCADE;


--
-- TOC entry 3845 (class 2606 OID 16676)
-- Name: tournament_participants tournament_participants_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 3846 (class 2606 OID 16681)
-- Name: tournament_results tournament_results_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_results
    ADD CONSTRAINT tournament_results_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE CASCADE;


--
-- TOC entry 3847 (class 2606 OID 16686)
-- Name: tournament_results tournament_results_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_results
    ADD CONSTRAINT tournament_results_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 3848 (class 2606 OID 16691)
-- Name: tournament_results tournament_results_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_results
    ADD CONSTRAINT tournament_results_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(tournament_id) ON DELETE CASCADE;


--
-- TOC entry 3849 (class 2606 OID 16696)
-- Name: tournament_schools tournament_schools_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_schools
    ADD CONSTRAINT tournament_schools_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 3850 (class 2606 OID 16701)
-- Name: tournament_schools tournament_schools_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_schools
    ADD CONSTRAINT tournament_schools_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(tournament_id) ON DELETE CASCADE;


--
-- TOC entry 4035 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE participants; Type: ACL; Schema: public; Owner: wushu
--

GRANT ALL ON TABLE public.participants TO postgres;


-- Completed on 2025-12-11 21:45:57 EST

--
-- PostgreSQL database dump complete
--

\unrestrict G2Lrl4xiHCdMs8VaatNIR6DeF6ZRXXgIC98jZv2eImlXbWiUl3rkZTPeMRUed5H

