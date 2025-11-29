--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

-- Started on 2025-11-27 23:51:46 EST

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
-- TOC entry 217 (class 1259 OID 16391)
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
-- TOC entry 218 (class 1259 OID 16398)
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
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 218
-- Name: deductions_deduction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.deductions_deduction_id_seq OWNED BY public.deductions.deduction_id;


--
-- TOC entry 219 (class 1259 OID 16399)
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
-- TOC entry 220 (class 1259 OID 16405)
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
-- TOC entry 3898 (class 0 OID 0)
-- Dependencies: 220
-- Name: divisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.divisions_id_seq OWNED BY public.divisions.id;


--
-- TOC entry 221 (class 1259 OID 16406)
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
-- TOC entry 222 (class 1259 OID 16411)
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
-- TOC entry 3899 (class 0 OID 0)
-- Dependencies: 222
-- Name: participant_deductions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.participant_deductions_id_seq OWNED BY public.participant_deductions.id;


--
-- TOC entry 223 (class 1259 OID 16412)
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
-- TOC entry 224 (class 1259 OID 16418)
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
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 224
-- Name: participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.participants_id_seq OWNED BY public.participants.id;


--
-- TOC entry 225 (class 1259 OID 16419)
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
-- TOC entry 226 (class 1259 OID 16425)
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
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 226
-- Name: published_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.published_scores_id_seq OWNED BY public.published_scores.id;


--
-- TOC entry 239 (class 1259 OID 24632)
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
    participant_id integer
);


ALTER TABLE public.registrations OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 24656)
-- Name: registrations_divisions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.registrations_divisions (
    registration_id integer NOT NULL,
    division_id integer NOT NULL
);


ALTER TABLE public.registrations_divisions OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 24631)
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
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 238
-- Name: registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.registrations_id_seq OWNED BY public.registrations.id;


--
-- TOC entry 227 (class 1259 OID 16426)
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
-- TOC entry 228 (class 1259 OID 16433)
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
-- TOC entry 3904 (class 0 OID 0)
-- Dependencies: 228
-- Name: schools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.schools_id_seq OWNED BY public.schools.id;


--
-- TOC entry 229 (class 1259 OID 16434)
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
-- TOC entry 230 (class 1259 OID 16440)
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
-- TOC entry 3905 (class 0 OID 0)
-- Dependencies: 230
-- Name: scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wushu
--

ALTER SEQUENCE public.scores_id_seq OWNED BY public.scores.id;


--
-- TOC entry 231 (class 1259 OID 16441)
-- Name: tournament_details; Type: TABLE; Schema: public; Owner: wushu
--

CREATE TABLE public.tournament_details (
    argument character varying(50) NOT NULL,
    value integer NOT NULL
);


ALTER TABLE public.tournament_details OWNER TO wushu;

--
-- TOC entry 235 (class 1259 OID 24604)
-- Name: tournament_divisions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_divisions (
    tournament_id integer NOT NULL,
    division_id integer NOT NULL
);


ALTER TABLE public.tournament_divisions OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16444)
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
-- TOC entry 243 (class 1259 OID 24723)
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
-- TOC entry 242 (class 1259 OID 24722)
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
-- TOC entry 3906 (class 0 OID 0)
-- Dependencies: 242
-- Name: tournament_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tournament_results_id_seq OWNED BY public.tournament_results.id;


--
-- TOC entry 241 (class 1259 OID 24685)
-- Name: tournament_schools; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_schools (
    tournament_id integer NOT NULL,
    school_id integer NOT NULL
);


ALTER TABLE public.tournament_schools OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 24620)
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
    details_content text
);


ALTER TABLE public.tournaments OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 24619)
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
-- TOC entry 3907 (class 0 OID 0)
-- Dependencies: 236
-- Name: tournaments_tournament_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tournaments_tournament_id_seq OWNED BY public.tournaments.tournament_id;


--
-- TOC entry 233 (class 1259 OID 16449)
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
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 16453)
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
-- TOC entry 3908 (class 0 OID 0)
-- Dependencies: 234
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 3611 (class 2604 OID 16454)
-- Name: deductions deduction_id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.deductions ALTER COLUMN deduction_id SET DEFAULT nextval('public.deductions_deduction_id_seq'::regclass);


--
-- TOC entry 3612 (class 2604 OID 16455)
-- Name: divisions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.divisions ALTER COLUMN id SET DEFAULT nextval('public.divisions_id_seq'::regclass);


--
-- TOC entry 3616 (class 2604 OID 16456)
-- Name: participant_deductions id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions ALTER COLUMN id SET DEFAULT nextval('public.participant_deductions_id_seq'::regclass);


--
-- TOC entry 3618 (class 2604 OID 16457)
-- Name: participants id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants ALTER COLUMN id SET DEFAULT nextval('public.participants_id_seq'::regclass);


--
-- TOC entry 3620 (class 2604 OID 16458)
-- Name: published_scores id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores ALTER COLUMN id SET DEFAULT nextval('public.published_scores_id_seq'::regclass);


--
-- TOC entry 3639 (class 2604 OID 24635)
-- Name: registrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations ALTER COLUMN id SET DEFAULT nextval('public.registrations_id_seq'::regclass);


--
-- TOC entry 3622 (class 2604 OID 16459)
-- Name: schools id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schools ALTER COLUMN id SET DEFAULT nextval('public.schools_id_seq'::regclass);


--
-- TOC entry 3625 (class 2604 OID 16460)
-- Name: scores id; Type: DEFAULT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores ALTER COLUMN id SET DEFAULT nextval('public.scores_id_seq'::regclass);


--
-- TOC entry 3643 (class 2604 OID 24726)
-- Name: tournament_results id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_results ALTER COLUMN id SET DEFAULT nextval('public.tournament_results_id_seq'::regclass);


--
-- TOC entry 3633 (class 2604 OID 24623)
-- Name: tournaments tournament_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournaments ALTER COLUMN tournament_id SET DEFAULT nextval('public.tournaments_tournament_id_seq'::regclass);


--
-- TOC entry 3630 (class 2604 OID 16461)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 3865 (class 0 OID 16391)
-- Dependencies: 217
-- Data for Name: deductions; Type: TABLE DATA; Schema: public; Owner: wushu
--

INSERT INTO public.deductions VALUES (1, 'Hand Forms/Shape', 'Fist', '* Face of fist uneven\n* Thumb not pressing on second segment of middle finger', 0.1, 5);
INSERT INTO public.deductions VALUES (2, 'Hand Forms/Shape', 'Sword Finger', '* Supporting leg bent\n* Raised leg bent', 0.3, 6);
INSERT INTO public.deductions VALUES (3, 'Hand Forms/Shape', 'Palm', '* Four fingers not straight and together\n* Thumb is not bent in tightly', 0.1, 7);
INSERT INTO public.deductions VALUES (4, 'Hand Forms/Shape', 'Hook', '* Five fingers not pinched together\n* Wrist not hooked completely', 0.1, 8);


--
-- TOC entry 3867 (class 0 OID 16399)
-- Dependencies: 219
-- Data for Name: divisions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.divisions VALUES (2, 'Northern Traditional Weapons', '2025-03-13 11:02:45.532262', '2025-03-13 11:02:45.532262', false);
INSERT INTO public.divisions VALUES (3, 'Northern Bare Hands', '2025-03-13 11:02:45.532262', '2025-03-24 13:44:18.089647', false);
INSERT INTO public.divisions VALUES (4, 'Southern Bare Hands', '2025-03-19 20:50:03.059138', '2025-03-27 23:18:43.431666', false);
INSERT INTO public.divisions VALUES (8, 'Northern Long Weapons', '2025-05-22 15:35:37.86546', '2025-05-22 15:35:37.86546', false);
INSERT INTO public.divisions VALUES (1, 'Southern Traditional Weapons', '2025-03-13 11:02:45.532262', '2025-03-13 11:02:45.532262', true);
INSERT INTO public.divisions VALUES (9, 'Test', '2025-11-24 22:25:56.458055', '2025-11-24 22:25:56.458055', false);


--
-- TOC entry 3869 (class 0 OID 16406)
-- Dependencies: 221
-- Data for Name: participant_deductions; Type: TABLE DATA; Schema: public; Owner: wushu
--

INSERT INTO public.participant_deductions VALUES (14, 5, 1, '2025-02-20 03:50:25.40272', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (15, 5, 1, '2025-02-20 03:50:27.762947', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (16, 5, 3, '2025-02-20 03:50:32.296349', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (17, 5, 2, '2025-02-20 03:50:34.330336', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (18, 5, 1, '2025-02-20 20:51:32.04023', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (19, 5, 1, '2025-02-20 20:51:32.046907', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (70, 3, 2, '2025-03-03 01:35:10.579346', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (71, 3, 3, '2025-03-03 01:35:28.668441', 'A2', 1);
INSERT INTO public.participant_deductions VALUES (72, 2, 1, '2025-03-10 19:39:35.846454', 'A2', 1);
INSERT INTO public.participant_deductions VALUES (73, 2, 3, '2025-03-10 19:39:36.015219', 'A2', 1);
INSERT INTO public.participant_deductions VALUES (74, 2, 1, '2025-03-12 21:48:02.679764', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (75, 2, 3, '2025-03-12 21:48:02.688533', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (76, 8, 3, '2025-03-14 00:07:30.744422', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (77, 8, 2, '2025-03-14 00:07:30.807297', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (78, 10, 3, '2025-03-14 23:52:40.727588', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (83, 1, 2, '2025-03-24 15:58:25.845291', 'A1', NULL);
INSERT INTO public.participant_deductions VALUES (84, 1, 3, '2025-03-24 15:58:25.853283', 'A1', NULL);
INSERT INTO public.participant_deductions VALUES (85, 1, 4, '2025-05-20 16:56:53.780699', 'A1', NULL);
INSERT INTO public.participant_deductions VALUES (86, 3, 4, '2025-05-20 21:07:31.103244', 'A1', NULL);
INSERT INTO public.participant_deductions VALUES (87, 3, 3, '2025-05-20 21:07:31.110293', 'A1', NULL);
INSERT INTO public.participant_deductions VALUES (88, 2, 3, '2025-05-22 15:38:21.089962', 'A1', NULL);
INSERT INTO public.participant_deductions VALUES (89, 2, 3, '2025-05-22 15:38:21.096345', 'A1', NULL);
INSERT INTO public.participant_deductions VALUES (90, 2, 2, '2025-05-22 15:38:21.103175', 'A1', NULL);
INSERT INTO public.participant_deductions VALUES (91, 2, 2, '2025-05-22 15:38:21.10802', 'A1', NULL);
INSERT INTO public.participant_deductions VALUES (92, 2, 2, '2025-05-22 15:38:21.114254', 'A1', NULL);
INSERT INTO public.participant_deductions VALUES (93, 2, 4, '2025-05-22 15:38:51.008685', 'A2', NULL);
INSERT INTO public.participant_deductions VALUES (94, 2, 2, '2025-05-22 15:38:51.015882', 'A2', NULL);
INSERT INTO public.participant_deductions VALUES (97, 2, 3, '2025-05-23 12:43:04.288008', 'A2', 8);
INSERT INTO public.participant_deductions VALUES (98, 2, 3, '2025-05-23 12:43:04.293016', 'A2', 8);
INSERT INTO public.participant_deductions VALUES (99, 2, 3, '2025-05-23 12:43:04.298913', 'A2', 8);
INSERT INTO public.participant_deductions VALUES (103, 2, 2, '2025-05-23 14:28:43.193166', 'A1', 8);
INSERT INTO public.participant_deductions VALUES (104, 10, 3, '2025-11-22 23:50:23.55629', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (105, 10, 3, '2025-11-22 23:50:23.562855', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (106, 10, 2, '2025-11-22 23:50:23.568184', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (108, 10, 4, '2025-11-22 23:51:08.92626', 'A2', 1);
INSERT INTO public.participant_deductions VALUES (112, 1, 2, '2025-11-22 23:54:14.050248', 'A2', 1);
INSERT INTO public.participant_deductions VALUES (113, 1, 2, '2025-11-22 23:54:39.474072', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (114, 7, 2, '2025-11-22 23:56:09.987129', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (115, 7, 2, '2025-11-22 23:56:21.702441', 'A2', 1);
INSERT INTO public.participant_deductions VALUES (116, 17, 1, '2025-11-23 00:02:14.86946', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (117, 17, 1, '2025-11-23 00:02:14.874976', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (118, 17, 1, '2025-11-23 00:02:14.880055', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (119, 17, 1, '2025-11-23 00:02:14.885259', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (120, 17, 1, '2025-11-23 00:02:14.890831', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (121, 17, 1, '2025-11-23 00:02:14.896006', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (122, 17, 4, '2025-11-23 00:02:38.043802', 'A2', 1);
INSERT INTO public.participant_deductions VALUES (123, 17, 4, '2025-11-23 00:02:38.049566', 'A2', 1);
INSERT INTO public.participant_deductions VALUES (124, 17, 4, '2025-11-23 00:02:38.054922', 'A2', 1);
INSERT INTO public.participant_deductions VALUES (125, 17, 4, '2025-11-23 00:02:38.058881', 'A2', 1);
INSERT INTO public.participant_deductions VALUES (126, 17, 4, '2025-11-23 00:02:38.062905', 'A2', 1);
INSERT INTO public.participant_deductions VALUES (127, 18, 3, '2025-11-27 00:19:02.835179', 'A2', 1);
INSERT INTO public.participant_deductions VALUES (128, 18, 3, '2025-11-27 22:50:43.97018', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (133, 20, 2, '2025-11-27 23:06:54.630271', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (134, 20, 3, '2025-11-27 23:07:00.150721', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (135, 20, 4, '2025-11-27 23:07:25.156658', 'A2', 1);
INSERT INTO public.participant_deductions VALUES (136, 20, 2, '2025-11-27 23:23:58.932811', 'A2', 1);
INSERT INTO public.participant_deductions VALUES (137, 20, 2, '2025-11-27 23:24:02.004323', 'A2', 1);
INSERT INTO public.participant_deductions VALUES (138, 20, 3, '2025-11-27 23:24:02.859956', 'A2', 1);
INSERT INTO public.participant_deductions VALUES (139, 18, 3, '2025-11-27 23:36:08.364487', 'A1', 1);
INSERT INTO public.participant_deductions VALUES (140, 18, 2, '2025-11-27 23:36:11.099913', 'A1', 1);


--
-- TOC entry 3871 (class 0 OID 16412)
-- Dependencies: 223
-- Data for Name: participants; Type: TABLE DATA; Schema: public; Owner: wushu
--

INSERT INTO public.participants VALUES (1, 9, 'Ralph', NULL, 'Cespedes', NULL, NULL, NULL, NULL, 'M', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:10.520292', NULL, 1);
INSERT INTO public.participants VALUES (7, 8, 'Audrey', NULL, 'Chiang', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:25.44711', NULL, 1);
INSERT INTO public.participants VALUES (3, 8, 'Gina', NULL, 'Ku', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:37.360592', NULL, 1);
INSERT INTO public.participants VALUES (6, 8, 'Soveida', NULL, 'Monteiro', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:52.304767', NULL, 1);
INSERT INTO public.participants VALUES (11, 9, 'Sam', NULL, 'Rodriguez', NULL, NULL, NULL, NULL, 'M', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:56:10.634019', NULL, 1);
INSERT INTO public.participants VALUES (4, 9, 'Fiorella', NULL, 'Vargas', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:56:18.014433', NULL, 1);
INSERT INTO public.participants VALUES (5, 9, 'Maria', NULL, 'Vargas', NULL, NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-14 23:32:43.266092', NULL, 1);
INSERT INTO public.participants VALUES (2, 9, 'Jarely', NULL, 'Osorio', '2025-03-17', NULL, NULL, NULL, 'M', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:56:01.626954', NULL, 1);
INSERT INTO public.participants VALUES (9, 8, 'Victoria', NULL, 'McKay', '2025-03-04', NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:44.382807', NULL, 1);
INSERT INTO public.participants VALUES (8, 8, 'Leona', NULL, 'Castillo', '2025-03-03', NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:55:04.691326', NULL, 1);
INSERT INTO public.participants VALUES (10, 8, 'Rehana', NULL, 'Carre', '2025-03-03', NULL, NULL, NULL, 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-03-13 09:54:46.878039', NULL, 1);
INSERT INTO public.participants VALUES (16, 11, 'James', 'T', 'Kirk', '1980-01-01', 5, 10, 100.00, 'M', '908 908 8888', 'Janice', '908 888 8888', '1 Chronos Pl', 'Main', 'War', 'Chronos', '12345', NULL, 'Black', 1);
INSERT INTO public.participants VALUES (17, 11, 'Jean-Luc', '', 'Picard', '1980-01-01', 5, 9, 86.00, 'M', '908 908 7777', 'Beverly Crusher', '', '10th Forward', 'Main Deck', 'Captain', 'Enterprise', '11111', NULL, 'Black', 1);
INSERT INTO public.participants VALUES (18, 8, 'Ricardo', '', 'Balbachevsky Setti', '2025-10-31', NULL, NULL, NULL, 'M', '9086937777', '', '', '', '', '', '', '', NULL, '', 3);
INSERT INTO public.participants VALUES (19, 11, 'Ricardo', NULL, 'Balbachevsky Setti', '2025-11-11', NULL, NULL, NULL, 'M', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 3);
INSERT INTO public.participants VALUES (20, 9, 'Ricardo', NULL, 'Balbachevsky Setti', '2025-10-27', NULL, NULL, NULL, 'M', '9086937777', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 3);


--
-- TOC entry 3873 (class 0 OID 16419)
-- Dependencies: 225
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
INSERT INTO public.published_scores VALUES (85, 10, 'A1', 4.9, '2025-03-19 20:53:28.861551', 3);
INSERT INTO public.published_scores VALUES (86, 10, 'A2', 5.0, '2025-03-19 20:53:28.86715', 3);
INSERT INTO public.published_scores VALUES (87, 10, 'B1', 3.4, '2025-03-19 20:53:28.868685', 3);
INSERT INTO public.published_scores VALUES (88, 10, 'B2', 3.6, '2025-03-19 20:53:28.870132', 3);
INSERT INTO public.published_scores VALUES (89, 10, 'FinalA', 5.0, '2025-03-19 20:53:28.8716', 3);
INSERT INTO public.published_scores VALUES (90, 10, 'FinalB', 3.5, '2025-03-19 20:53:28.872722', 3);
INSERT INTO public.published_scores VALUES (91, 10, 'Final', 8.5, '2025-03-19 20:53:28.874037', 3);
INSERT INTO public.published_scores VALUES (92, 8, 'A1', 5.0, '2025-03-19 21:05:47.118456', 3);
INSERT INTO public.published_scores VALUES (93, 8, 'A2', 5.0, '2025-03-19 21:05:47.170867', 3);
INSERT INTO public.published_scores VALUES (94, 8, 'B1', 1.9, '2025-03-19 21:05:47.171714', 3);
INSERT INTO public.published_scores VALUES (95, 8, 'B2', 4.5, '2025-03-19 21:05:47.172589', 3);
INSERT INTO public.published_scores VALUES (96, 8, 'FinalA', 5.0, '2025-03-19 21:05:47.174016', 3);
INSERT INTO public.published_scores VALUES (97, 8, 'FinalB', 3.2, '2025-03-19 21:05:47.175428', 3);
INSERT INTO public.published_scores VALUES (98, 8, 'Final', 8.2, '2025-03-19 21:05:47.176814', 3);
INSERT INTO public.published_scores VALUES (113, 1, 'A1', 4.9, '2025-05-20 16:57:34.421151', 3);
INSERT INTO public.published_scores VALUES (114, 1, 'A2', 5.0, '2025-05-20 16:57:34.422726', 3);
INSERT INTO public.published_scores VALUES (115, 1, 'B1', 1.4, '2025-05-20 16:57:34.42316', 3);
INSERT INTO public.published_scores VALUES (116, 1, 'B2', 2.2, '2025-05-20 16:57:34.423567', 3);
INSERT INTO public.published_scores VALUES (117, 1, 'FinalA', 5.0, '2025-05-20 16:57:34.424004', 3);
INSERT INTO public.published_scores VALUES (118, 1, 'FinalB', 1.8, '2025-05-20 16:57:34.424539', 3);
INSERT INTO public.published_scores VALUES (119, 1, 'Final', 6.8, '2025-05-20 16:57:34.425082', 3);
INSERT INTO public.published_scores VALUES (127, 3, 'A1', 4.8, '2025-05-20 21:08:48.277156', 3);
INSERT INTO public.published_scores VALUES (128, 3, 'A2', 5.0, '2025-05-20 21:08:48.277156', 3);
INSERT INTO public.published_scores VALUES (129, 3, 'B1', 3.1, '2025-05-20 21:08:48.277156', 3);
INSERT INTO public.published_scores VALUES (130, 3, 'B2', 4.5, '2025-05-20 21:08:48.277156', 3);
INSERT INTO public.published_scores VALUES (131, 3, 'FinalA', 4.9, '2025-05-20 21:08:48.277156', 3);
INSERT INTO public.published_scores VALUES (132, 3, 'FinalB', 3.8, '2025-05-20 21:08:48.277156', 3);
INSERT INTO public.published_scores VALUES (133, 3, 'Final', 8.7, '2025-05-20 21:08:48.277156', 3);
INSERT INTO public.published_scores VALUES (134, 3, 'A1', 5.0, '2025-05-20 21:49:06.101357', 1);
INSERT INTO public.published_scores VALUES (135, 3, 'A2', 5.0, '2025-05-20 21:49:06.101357', 1);
INSERT INTO public.published_scores VALUES (136, 3, 'B1', 2.6, '2025-05-20 21:49:06.101357', 1);
INSERT INTO public.published_scores VALUES (137, 3, 'B2', 1.2, '2025-05-20 21:49:06.101357', 1);
INSERT INTO public.published_scores VALUES (138, 3, 'FinalA', 5.0, '2025-05-20 21:49:06.101357', 1);
INSERT INTO public.published_scores VALUES (139, 3, 'FinalB', 1.9, '2025-05-20 21:49:06.101357', 1);
INSERT INTO public.published_scores VALUES (140, 3, 'Final', 6.9, '2025-05-20 21:49:06.101357', 1);
INSERT INTO public.published_scores VALUES (148, 2, 'A1', 3.9, '2025-05-23 12:43:37.104874', 8);
INSERT INTO public.published_scores VALUES (149, 2, 'A2', 4.6, '2025-05-23 12:43:37.104874', 8);
INSERT INTO public.published_scores VALUES (150, 2, 'B1', 4.5, '2025-05-23 12:43:37.104874', 8);
INSERT INTO public.published_scores VALUES (151, 2, 'B2', 4.1, '2025-05-23 12:43:37.104874', 8);
INSERT INTO public.published_scores VALUES (152, 2, 'FinalA', 4.3, '2025-05-23 12:43:37.104874', 8);
INSERT INTO public.published_scores VALUES (153, 2, 'FinalB', 4.3, '2025-05-23 12:43:37.104874', 8);
INSERT INTO public.published_scores VALUES (154, 2, 'Final', 8.6, '2025-05-23 12:43:37.104874', 8);
INSERT INTO public.published_scores VALUES (155, 10, 'A1', 4.4, '2025-11-22 23:52:09.957696', 1);
INSERT INTO public.published_scores VALUES (156, 10, 'A2', 4.9, '2025-11-22 23:52:09.957696', 1);
INSERT INTO public.published_scores VALUES (157, 10, 'B1', 2.4, '2025-11-22 23:52:09.957696', 1);
INSERT INTO public.published_scores VALUES (158, 10, 'B2', 3.8, '2025-11-22 23:52:09.957696', 1);
INSERT INTO public.published_scores VALUES (159, 10, 'FinalA', 4.7, '2025-11-22 23:52:09.957696', 1);
INSERT INTO public.published_scores VALUES (160, 10, 'FinalB', 3.1, '2025-11-22 23:52:09.957696', 1);
INSERT INTO public.published_scores VALUES (161, 10, 'Final', 7.8, '2025-11-22 23:52:09.957696', 1);
INSERT INTO public.published_scores VALUES (162, 1, 'A1', 4.6, '2025-11-22 23:55:15.427304', 1);
INSERT INTO public.published_scores VALUES (163, 1, 'A2', 5.0, '2025-11-22 23:55:15.427304', 1);
INSERT INTO public.published_scores VALUES (164, 1, 'B1', 3.7, '2025-11-22 23:55:15.427304', 1);
INSERT INTO public.published_scores VALUES (165, 1, 'B2', 4.6, '2025-11-22 23:55:15.427304', 1);
INSERT INTO public.published_scores VALUES (166, 1, 'FinalA', 4.8, '2025-11-22 23:55:15.427304', 1);
INSERT INTO public.published_scores VALUES (167, 1, 'FinalB', 4.2, '2025-11-22 23:55:15.427304', 1);
INSERT INTO public.published_scores VALUES (168, 1, 'Final', 9.0, '2025-11-22 23:55:15.427304', 1);
INSERT INTO public.published_scores VALUES (169, 7, 'A1', 4.7, '2025-11-22 23:56:59.497689', 1);
INSERT INTO public.published_scores VALUES (170, 7, 'A2', 4.7, '2025-11-22 23:56:59.497689', 1);
INSERT INTO public.published_scores VALUES (171, 7, 'B1', 3.6, '2025-11-22 23:56:59.497689', 1);
INSERT INTO public.published_scores VALUES (172, 7, 'B2', 4.0, '2025-11-22 23:56:59.497689', 1);
INSERT INTO public.published_scores VALUES (173, 7, 'FinalA', 4.7, '2025-11-22 23:56:59.497689', 1);
INSERT INTO public.published_scores VALUES (174, 7, 'FinalB', 3.8, '2025-11-22 23:56:59.497689', 1);
INSERT INTO public.published_scores VALUES (175, 7, 'Final', 8.5, '2025-11-22 23:56:59.497689', 1);
INSERT INTO public.published_scores VALUES (176, 17, 'A1', 4.4, '2025-11-23 00:03:28.925132', 1);
INSERT INTO public.published_scores VALUES (177, 17, 'A2', 4.5, '2025-11-23 00:03:28.925132', 1);
INSERT INTO public.published_scores VALUES (178, 17, 'B1', 4.5, '2025-11-23 00:03:28.925132', 1);
INSERT INTO public.published_scores VALUES (179, 17, 'B2', 5.0, '2025-11-23 00:03:28.925132', 1);
INSERT INTO public.published_scores VALUES (180, 17, 'FinalA', 4.5, '2025-11-23 00:03:28.925132', 1);
INSERT INTO public.published_scores VALUES (181, 17, 'FinalB', 4.8, '2025-11-23 00:03:28.925132', 1);
INSERT INTO public.published_scores VALUES (182, 17, 'Final', 9.2, '2025-11-23 00:03:28.925132', 1);


--
-- TOC entry 3887 (class 0 OID 24632)
-- Dependencies: 239
-- Data for Name: registrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.registrations VALUES (1, 1, 9, '', 0, '2025-11-24 16:55:37.248463', '2025-11-24 16:55:37.248463', 8, NULL);
INSERT INTO public.registrations VALUES (2, 3, 8, NULL, 0, '2025-11-24 22:36:22.804625', '2025-11-24 22:36:43.879285', 9, NULL);
INSERT INTO public.registrations VALUES (4, 3, 8, '', 1, '2025-11-25 13:47:06.360407', '2025-11-25 14:06:47.706759', 11, 19);
INSERT INTO public.registrations VALUES (6, 3, 11, NULL, 1, '2025-11-25 22:17:21.274468', '2025-11-26 23:39:10.427609', 14, 19);
INSERT INTO public.registrations VALUES (3, 3, 9, NULL, 1, '2025-11-24 22:46:49.4398', '2025-11-27 22:50:02.43115', 10, 20);


--
-- TOC entry 3888 (class 0 OID 24656)
-- Dependencies: 240
-- Data for Name: registrations_divisions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.registrations_divisions VALUES (1, 3);
INSERT INTO public.registrations_divisions VALUES (2, 3);
INSERT INTO public.registrations_divisions VALUES (3, 4);
INSERT INTO public.registrations_divisions VALUES (3, 1);
INSERT INTO public.registrations_divisions VALUES (4, 1);
INSERT INTO public.registrations_divisions VALUES (6, 4);


--
-- TOC entry 3875 (class 0 OID 16426)
-- Dependencies: 227
-- Data for Name: schools; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.schools VALUES (9, 'Perth Amboy Martial Arts', '165 Smith St', 'Kevin Torres', '(732) 877-9229', '', '2026-02-22 22:45:59.528');
INSERT INTO public.schools VALUES (11, 'Union UTA Martial Arts', '2020 Morris Avenue, Union, NJ 07083', 'Robert Nichols', '(908) 687-5559', NULL, '2025-05-08 23:16:02.944615', '2025-11-25 14:17:00.745096', 'fe61f204-afe7-47d4-b0ab-b8e810ccb931', 'http://localhost:5173/register?token=fe61f204-afe7-47d4-b0ab-b8e810ccb931&school_id=11', '', '2026-02-23 14:17:00.744');
INSERT INTO public.schools VALUES (8, 'Wushu Taekwon-Do Academy', '456 U.S. 22 West', 'Chris Leyesa', '(732) 789-4744', '\x20', '2025-03-11 22:54:48.869172', '2025-11-25 13:46:25.338839', 'b3db92bf-e368-4383-a2a9-b825a6673fcc', 'http://localhost:5173/register?token=b3db92bf-e368-4383-a2a9-b825a6673fcc&school_id=8', '', '2026-02-23 13:46:25.338');
INSERT INTO public.schools VALUES (12, 'Independent', 'N/A', 'Self', 'N/A', NULL, '2025-11-25 17:47:30.340745', '2025-11-25 17:47:30.340745', NULL, NULL, NULL, NULL);


--
-- TOC entry 3877 (class 0 OID 16434)
-- Dependencies: 229
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
INSERT INTO public.scores VALUES (184, 10, 'A1', 4.9, '2025-03-19 17:58:43.821901', 3);
INSERT INTO public.scores VALUES (185, 10, 'A2', 5.0, '2025-03-19 17:59:56.969606', 3);
INSERT INTO public.scores VALUES (186, 10, 'B1', 3.4, '2025-03-19 18:00:01.423884', 3);
INSERT INTO public.scores VALUES (187, 10, 'B2', 3.6, '2025-03-19 18:00:05.731879', 3);
INSERT INTO public.scores VALUES (188, 10, 'FinalA', 5.0, '2025-03-19 18:00:10.641921', 3);
INSERT INTO public.scores VALUES (189, 10, 'FinalB', 3.5, '2025-03-19 18:00:10.648276', 3);
INSERT INTO public.scores VALUES (190, 10, 'Final', 8.5, '2025-03-19 18:00:10.651747', 3);
INSERT INTO public.scores VALUES (191, 10, 'A1', 4.6, '2025-03-19 20:52:28.390195', 3);
INSERT INTO public.scores VALUES (192, 10, 'A2', 5.0, '2025-03-19 20:52:48.88037', 3);
INSERT INTO public.scores VALUES (193, 10, 'B1', 3.9, '2025-03-19 20:52:56.003567', 3);
INSERT INTO public.scores VALUES (194, 10, 'B2', 3.6, '2025-03-19 20:52:59.389902', 3);
INSERT INTO public.scores VALUES (195, 10, 'FinalA', 5.0, '2025-03-19 20:53:15.677168', 3);
INSERT INTO public.scores VALUES (196, 10, 'FinalB', 3.5, '2025-03-19 20:53:15.736831', 3);
INSERT INTO public.scores VALUES (197, 10, 'Final', 8.5, '2025-03-19 20:53:15.746471', 3);
INSERT INTO public.scores VALUES (198, 10, 'A1', 4.6, '2025-03-19 20:54:25.36415', 3);
INSERT INTO public.scores VALUES (199, 10, 'FinalA', 5.0, '2025-03-19 21:01:13.236387', 3);
INSERT INTO public.scores VALUES (200, 10, 'FinalB', 3.5, '2025-03-19 21:01:13.244433', 3);
INSERT INTO public.scores VALUES (201, 10, 'Final', 8.5, '2025-03-19 21:01:13.252013', 3);
INSERT INTO public.scores VALUES (202, 8, 'A1', 5.0, '2025-03-19 21:02:57.978904', 3);
INSERT INTO public.scores VALUES (203, 8, 'A2', 5.0, '2025-03-19 21:03:10.497461', 3);
INSERT INTO public.scores VALUES (204, 8, 'B1', 1.9, '2025-03-19 21:03:18.515664', 3);
INSERT INTO public.scores VALUES (205, 8, 'B2', 4.5, '2025-03-19 21:03:23.887938', 3);
INSERT INTO public.scores VALUES (206, 8, 'FinalA', 5.0, '2025-03-19 21:03:45.421069', 3);
INSERT INTO public.scores VALUES (207, 8, 'FinalB', 3.2, '2025-03-19 21:03:45.477476', 3);
INSERT INTO public.scores VALUES (208, 8, 'Final', 8.2, '2025-03-19 21:03:45.484761', 3);
INSERT INTO public.scores VALUES (209, 8, 'FinalA', 5.0, '2025-03-19 21:04:13.515462', 3);
INSERT INTO public.scores VALUES (210, 8, 'FinalB', 3.2, '2025-03-19 21:04:13.526207', 3);
INSERT INTO public.scores VALUES (211, 8, 'Final', 8.2, '2025-03-19 21:04:13.534066', 3);
INSERT INTO public.scores VALUES (212, 8, 'B1', 3.9, '2025-03-19 21:05:25.067833', 3);
INSERT INTO public.scores VALUES (213, 1, 'A1', 4.6, '2025-03-24 15:58:25.835243', 1);
INSERT INTO public.scores VALUES (214, 1, 'A2', 5.0, '2025-03-24 15:58:36.340579', 1);
INSERT INTO public.scores VALUES (215, 1, 'B1', 3.7, '2025-03-24 15:58:41.649934', 1);
INSERT INTO public.scores VALUES (216, 1, 'B2', 4.6, '2025-03-24 15:58:46.848173', 1);
INSERT INTO public.scores VALUES (217, 1, 'FinalA', 4.8, '2025-03-24 15:58:59.675412', 1);
INSERT INTO public.scores VALUES (218, 1, 'FinalB', 4.2, '2025-03-24 15:58:59.696973', 1);
INSERT INTO public.scores VALUES (219, 1, 'Final', 9.0, '2025-03-24 15:58:59.703795', 1);
INSERT INTO public.scores VALUES (220, 1, 'FinalA', 4.8, '2025-03-24 15:59:28.335256', 1);
INSERT INTO public.scores VALUES (221, 1, 'FinalB', 4.2, '2025-03-24 15:59:28.355063', 1);
INSERT INTO public.scores VALUES (222, 1, 'Final', 9.0, '2025-03-24 15:59:28.360596', 1);
INSERT INTO public.scores VALUES (223, 1, 'A1', 4.9, '2025-05-20 16:56:53.768432', 3);
INSERT INTO public.scores VALUES (224, 1, 'A2', 5.0, '2025-05-20 16:56:59.232725', 3);
INSERT INTO public.scores VALUES (225, 1, 'B1', 1.4, '2025-05-20 16:57:05.231064', 3);
INSERT INTO public.scores VALUES (226, 1, 'B2', 2.2, '2025-05-20 16:57:11.666464', 3);
INSERT INTO public.scores VALUES (227, 1, 'FinalA', 5.0, '2025-05-20 16:57:23.170886', 3);
INSERT INTO public.scores VALUES (228, 1, 'FinalB', 1.8, '2025-05-20 16:57:23.17727', 3);
INSERT INTO public.scores VALUES (229, 1, 'Final', 6.8, '2025-05-20 16:57:23.182983', 3);
INSERT INTO public.scores VALUES (230, 3, 'A1', 4.8, '2025-05-20 21:07:31.093443', 3);
INSERT INTO public.scores VALUES (231, 3, 'A2', 5.0, '2025-05-20 21:07:45.347467', 3);
INSERT INTO public.scores VALUES (232, 3, 'B1', 3.1, '2025-05-20 21:07:52.198856', 3);
INSERT INTO public.scores VALUES (233, 3, 'B2', 4.5, '2025-05-20 21:07:56.662769', 3);
INSERT INTO public.scores VALUES (234, 3, 'FinalA', 4.9, '2025-05-20 21:08:17.189928', 3);
INSERT INTO public.scores VALUES (235, 3, 'FinalB', 3.8, '2025-05-20 21:08:17.196068', 3);
INSERT INTO public.scores VALUES (236, 3, 'Final', 8.7, '2025-05-20 21:08:17.201076', 3);
INSERT INTO public.scores VALUES (237, 3, 'FinalA', 4.9, '2025-05-20 21:08:42.722583', 3);
INSERT INTO public.scores VALUES (238, 3, 'FinalB', 3.8, '2025-05-20 21:08:42.729725', 3);
INSERT INTO public.scores VALUES (239, 3, 'Final', 8.7, '2025-05-20 21:08:42.735269', 3);
INSERT INTO public.scores VALUES (240, 3, 'A1', 5.0, '2025-05-20 21:48:32.899096', 1);
INSERT INTO public.scores VALUES (241, 3, 'A2', 5.0, '2025-05-20 21:48:37.092524', 1);
INSERT INTO public.scores VALUES (242, 3, 'B1', 2.6, '2025-05-20 21:48:45.891811', 1);
INSERT INTO public.scores VALUES (243, 3, 'B2', 1.2, '2025-05-20 21:48:51.932753', 1);
INSERT INTO public.scores VALUES (244, 3, 'FinalA', 5.0, '2025-05-20 21:49:01.313078', 1);
INSERT INTO public.scores VALUES (245, 3, 'FinalB', 1.9, '2025-05-20 21:49:01.320161', 1);
INSERT INTO public.scores VALUES (246, 3, 'Final', 6.9, '2025-05-20 21:49:01.325661', 1);
INSERT INTO public.scores VALUES (247, 2, 'A1', 3.9, '2025-05-22 15:38:21.079242', 8);
INSERT INTO public.scores VALUES (248, 2, 'A2', 4.6, '2025-05-22 15:38:50.99202', 8);
INSERT INTO public.scores VALUES (249, 2, 'B1', 4.5, '2025-05-22 15:38:59.227886', 8);
INSERT INTO public.scores VALUES (250, 2, 'B2', 4.1, '2025-05-22 15:39:07.215606', 8);
INSERT INTO public.scores VALUES (251, 2, 'FinalA', 4.3, '2025-05-22 15:39:19.004594', 8);
INSERT INTO public.scores VALUES (252, 2, 'FinalB', 4.3, '2025-05-22 15:39:19.010808', 8);
INSERT INTO public.scores VALUES (253, 2, 'Final', 8.6, '2025-05-22 15:39:19.016338', 8);
INSERT INTO public.scores VALUES (254, 2, 'A1', 3.7, '2025-05-23 12:42:47.909379', 8);
INSERT INTO public.scores VALUES (255, 2, 'A2', 4.3, '2025-05-23 12:43:04.281121', 8);
INSERT INTO public.scores VALUES (256, 2, 'B1', 4.8, '2025-05-23 12:43:11.209706', 8);
INSERT INTO public.scores VALUES (257, 2, 'B2', 2.8, '2025-05-23 12:43:19.375795', 8);
INSERT INTO public.scores VALUES (258, 2, 'FinalA', 4.3, '2025-05-23 12:43:31.65128', 8);
INSERT INTO public.scores VALUES (259, 2, 'FinalB', 4.3, '2025-05-23 12:43:31.655962', 8);
INSERT INTO public.scores VALUES (260, 2, 'Final', 8.6, '2025-05-23 12:43:31.659826', 8);
INSERT INTO public.scores VALUES (261, 2, 'A1', 4.4, '2025-05-23 14:28:43.165361', 8);
INSERT INTO public.scores VALUES (262, 10, 'A1', 4.4, '2025-11-22 23:50:23.546513', 1);
INSERT INTO public.scores VALUES (263, 10, 'A1', 4.4, '2025-11-22 23:50:31.750505', 1);
INSERT INTO public.scores VALUES (264, 10, 'A1', 5.0, '2025-11-22 23:50:54.162603', 1);
INSERT INTO public.scores VALUES (265, 10, 'A2', 4.9, '2025-11-22 23:51:08.92015', 1);
INSERT INTO public.scores VALUES (266, 10, 'B2', 3.8, '2025-11-22 23:51:26.06548', 1);
INSERT INTO public.scores VALUES (267, 10, 'B1', 2.4, '2025-11-22 23:51:38.109596', 1);
INSERT INTO public.scores VALUES (268, 10, 'FinalA', 4.7, '2025-11-22 23:52:00.439286', 1);
INSERT INTO public.scores VALUES (269, 10, 'FinalB', 3.1, '2025-11-22 23:52:00.4451', 1);
INSERT INTO public.scores VALUES (270, 10, 'Final', 7.8, '2025-11-22 23:52:00.449092', 1);
INSERT INTO public.scores VALUES (271, 1, 'B2', 2.4, '2025-11-22 23:53:03.088028', 1);
INSERT INTO public.scores VALUES (272, 1, 'B1', 0.9, '2025-11-22 23:53:13.033338', 1);
INSERT INTO public.scores VALUES (273, 1, 'A2', 4.7, '2025-11-22 23:53:49.438243', 1);
INSERT INTO public.scores VALUES (274, 1, 'A2', 4.7, '2025-11-22 23:54:14.042195', 1);
INSERT INTO public.scores VALUES (275, 1, 'A1', 4.7, '2025-11-22 23:54:39.465959', 1);
INSERT INTO public.scores VALUES (276, 1, 'A1', 5.0, '2025-11-22 23:55:00.136199', 1);
INSERT INTO public.scores VALUES (277, 1, 'FinalA', 4.8, '2025-11-22 23:55:10.945454', 1);
INSERT INTO public.scores VALUES (278, 1, 'FinalB', 4.2, '2025-11-22 23:55:10.951444', 1);
INSERT INTO public.scores VALUES (279, 1, 'Final', 9.0, '2025-11-22 23:55:10.955651', 1);
INSERT INTO public.scores VALUES (280, 7, 'A1', 4.7, '2025-11-22 23:56:09.979522', 1);
INSERT INTO public.scores VALUES (281, 7, 'A2', 4.7, '2025-11-22 23:56:21.694751', 1);
INSERT INTO public.scores VALUES (282, 7, 'B2', 4.0, '2025-11-22 23:56:31.547945', 1);
INSERT INTO public.scores VALUES (283, 7, 'B1', 3.6, '2025-11-22 23:56:38.419588', 1);
INSERT INTO public.scores VALUES (284, 7, 'FinalA', 4.7, '2025-11-22 23:56:55.763816', 1);
INSERT INTO public.scores VALUES (285, 7, 'FinalB', 3.8, '2025-11-22 23:56:55.769576', 1);
INSERT INTO public.scores VALUES (286, 7, 'Final', 8.5, '2025-11-22 23:56:55.775324', 1);
INSERT INTO public.scores VALUES (287, 17, 'A1', 4.4, '2025-11-23 00:02:14.861524', 1);
INSERT INTO public.scores VALUES (288, 17, 'A2', 4.5, '2025-11-23 00:02:38.036345', 1);
INSERT INTO public.scores VALUES (289, 17, 'B1', 4.5, '2025-11-23 00:02:47.531416', 1);
INSERT INTO public.scores VALUES (290, 17, 'B2', 5.0, '2025-11-23 00:03:08.980822', 1);
INSERT INTO public.scores VALUES (291, 17, 'FinalA', 4.5, '2025-11-23 00:03:22.927125', 1);
INSERT INTO public.scores VALUES (292, 17, 'FinalB', 4.8, '2025-11-23 00:03:22.932781', 1);
INSERT INTO public.scores VALUES (293, 17, 'Final', 9.2, '2025-11-23 00:03:22.937182', 1);
INSERT INTO public.scores VALUES (294, 18, 'A1', 5.0, '2025-11-27 00:18:32.492724', 1);
INSERT INTO public.scores VALUES (295, 18, 'A2', 4.9, '2025-11-27 00:19:02.826593', 1);
INSERT INTO public.scores VALUES (296, 18, 'B1', 3.4, '2025-11-27 00:19:10.131884', 1);
INSERT INTO public.scores VALUES (297, 18, 'B2', 2.1, '2025-11-27 00:19:15.980618', 1);
INSERT INTO public.scores VALUES (298, 18, 'A1', 4.9, '2025-11-27 22:50:43.960527', 1);
INSERT INTO public.scores VALUES (299, 18, 'A2', 5.0, '2025-11-27 22:50:58.762823', 1);
INSERT INTO public.scores VALUES (300, 18, 'B1', 4.4, '2025-11-27 22:51:03.820662', 1);
INSERT INTO public.scores VALUES (301, 18, 'B2', 5.0, '2025-11-27 22:51:09.823776', 1);
INSERT INTO public.scores VALUES (302, 20, 'B1', 3.8, '2025-11-27 23:02:46.423264', 1);
INSERT INTO public.scores VALUES (303, 20, 'B2', 1.7, '2025-11-27 23:02:55.540538', 1);
INSERT INTO public.scores VALUES (304, 20, 'A1', 4.6, '2025-11-27 23:07:11.112773', 1);
INSERT INTO public.scores VALUES (305, 20, 'A2', 4.9, '2025-11-27 23:07:31.513686', 1);
INSERT INTO public.scores VALUES (306, 20, 'A1', 4.6, '2025-11-27 23:23:46.066456', 1);
INSERT INTO public.scores VALUES (307, 20, 'A2', 4.2, '2025-11-27 23:24:06.055903', 1);
INSERT INTO public.scores VALUES (308, 20, 'B1', 3.7, '2025-11-27 23:24:13.780713', 1);
INSERT INTO public.scores VALUES (309, 20, 'B2', 1.8, '2025-11-27 23:24:20.351207', 1);
INSERT INTO public.scores VALUES (310, 18, 'A1', 4.5, '2025-11-27 23:36:15.531773', 1);
INSERT INTO public.scores VALUES (311, 18, 'B1', 3.9, '2025-11-27 23:36:29.59895', 1);


--
-- TOC entry 3879 (class 0 OID 16441)
-- Dependencies: 231
-- Data for Name: tournament_details; Type: TABLE DATA; Schema: public; Owner: wushu
--

INSERT INTO public.tournament_details VALUES ('JudgeA2_open', 1);
INSERT INTO public.tournament_details VALUES ('JudgeB2_open', 1);
INSERT INTO public.tournament_details VALUES ('JudgeB1_open', 1);
INSERT INTO public.tournament_details VALUES ('JudgeA1_open', 1);
INSERT INTO public.tournament_details VALUES ('Active_ID', 18);
INSERT INTO public.tournament_details VALUES ('Judge_B2', 0);
INSERT INTO public.tournament_details VALUES ('OnDeck_ID', 20);
INSERT INTO public.tournament_details VALUES ('Judge_A1', 0);
INSERT INTO public.tournament_details VALUES ('Judge_A2', 0);
INSERT INTO public.tournament_details VALUES ('Judge_B1', 0);


--
-- TOC entry 3883 (class 0 OID 24604)
-- Dependencies: 235
-- Data for Name: tournament_divisions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tournament_divisions VALUES (2, 2);
INSERT INTO public.tournament_divisions VALUES (2, 3);
INSERT INTO public.tournament_divisions VALUES (2, 4);
INSERT INTO public.tournament_divisions VALUES (2, 8);
INSERT INTO public.tournament_divisions VALUES (2, 1);
INSERT INTO public.tournament_divisions VALUES (1, 2);
INSERT INTO public.tournament_divisions VALUES (1, 3);
INSERT INTO public.tournament_divisions VALUES (1, 4);
INSERT INTO public.tournament_divisions VALUES (1, 8);
INSERT INTO public.tournament_divisions VALUES (1, 1);
INSERT INTO public.tournament_divisions VALUES (3, 1);
INSERT INTO public.tournament_divisions VALUES (3, 4);


--
-- TOC entry 3880 (class 0 OID 16444)
-- Dependencies: 232
-- Data for Name: tournament_participants; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tournament_participants VALUES (10, 3, '2025-03-13 14:32:05.034488', '2025-03-13 14:32:05.034488', 1);
INSERT INTO public.tournament_participants VALUES (10, 1, '2025-03-13 14:32:09.698217', '2025-03-13 14:32:09.698217', 1);
INSERT INTO public.tournament_participants VALUES (1, 3, '2025-03-14 23:30:55.721469', '2025-03-14 23:30:55.721469', 1);
INSERT INTO public.tournament_participants VALUES (1, 1, '2025-03-14 23:30:58.481066', '2025-03-14 23:30:58.481066', 1);
INSERT INTO public.tournament_participants VALUES (7, 1, '2025-03-14 23:31:04.998472', '2025-03-14 23:31:04.998472', 1);
INSERT INTO public.tournament_participants VALUES (3, 3, '2025-03-14 23:31:19.075999', '2025-03-14 23:31:19.075999', 1);
INSERT INTO public.tournament_participants VALUES (3, 2, '2025-03-14 23:31:20.989105', '2025-03-14 23:31:20.989105', 1);
INSERT INTO public.tournament_participants VALUES (3, 1, '2025-03-14 23:31:22.862934', '2025-03-14 23:31:22.862934', 1);
INSERT INTO public.tournament_participants VALUES (9, 2, '2025-03-14 23:31:27.71688', '2025-03-14 23:31:27.71688', 1);
INSERT INTO public.tournament_participants VALUES (6, 2, '2025-03-14 23:31:34.07531', '2025-03-14 23:31:34.07531', 1);
INSERT INTO public.tournament_participants VALUES (6, 3, '2025-03-14 23:31:36.820649', '2025-03-14 23:31:36.820649', 1);
INSERT INTO public.tournament_participants VALUES (2, 3, '2025-03-14 23:31:51.071328', '2025-03-14 23:31:51.071328', 1);
INSERT INTO public.tournament_participants VALUES (2, 1, '2025-03-14 23:31:59.126476', '2025-03-14 23:31:59.126476', 1);
INSERT INTO public.tournament_participants VALUES (11, 3, '2025-03-14 23:32:04.143814', '2025-03-14 23:32:04.143814', 1);
INSERT INTO public.tournament_participants VALUES (11, 1, '2025-03-14 23:32:06.235451', '2025-03-14 23:32:06.235451', 1);
INSERT INTO public.tournament_participants VALUES (5, 4, '2025-03-19 20:50:17.639216', '2025-03-19 20:50:17.639216', 1);
INSERT INTO public.tournament_participants VALUES (8, 4, '2025-03-23 22:41:23.18145', '2025-03-23 22:41:23.18145', 1);
INSERT INTO public.tournament_participants VALUES (8, 3, '2025-03-24 13:22:15.689194', '2025-03-24 13:22:15.689194', 1);
INSERT INTO public.tournament_participants VALUES (5, 8, '2025-05-22 15:36:04.717285', '2025-05-22 15:36:04.717285', 1);
INSERT INTO public.tournament_participants VALUES (4, 8, '2025-05-22 15:36:17.980684', '2025-05-22 15:36:17.980684', 1);
INSERT INTO public.tournament_participants VALUES (11, 8, '2025-05-22 15:36:49.25421', '2025-05-22 15:36:49.25421', 1);
INSERT INTO public.tournament_participants VALUES (2, 8, '2025-05-22 15:37:08.87655', '2025-05-22 15:37:08.87655', 1);
INSERT INTO public.tournament_participants VALUES (16, 8, '2025-11-22 23:46:43.650184', '2025-11-22 23:46:43.650184', 1);
INSERT INTO public.tournament_participants VALUES (16, 2, '2025-11-22 23:46:48.96347', '2025-11-22 23:46:48.96347', 1);
INSERT INTO public.tournament_participants VALUES (17, 4, '2025-11-22 23:48:54.639155', '2025-11-22 23:48:54.639155', 1);
INSERT INTO public.tournament_participants VALUES (17, 1, '2025-11-22 23:48:58.043583', '2025-11-22 23:48:58.043583', 1);
INSERT INTO public.tournament_participants VALUES (18, 1, '2025-11-25 14:06:47.706759', '2025-11-25 14:06:47.706759', 3);
INSERT INTO public.tournament_participants VALUES (19, 4, '2025-11-26 23:39:10.427609', '2025-11-26 23:39:10.427609', 3);
INSERT INTO public.tournament_participants VALUES (20, 4, '2025-11-27 22:50:02.43115', '2025-11-27 22:50:02.43115', 3);
INSERT INTO public.tournament_participants VALUES (20, 1, '2025-11-27 22:50:02.43115', '2025-11-27 22:50:02.43115', 3);


--
-- TOC entry 3891 (class 0 OID 24723)
-- Dependencies: 243
-- Data for Name: tournament_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tournament_results VALUES (5, 3, 20, 1, 6.13, NULL, '{"avg_a": "4.58", "avg_b": "2.75", "deductions": "1.20", "raw_scores": [{"judge": "B1", "score": "3.8"}, {"judge": "B2", "score": "1.7"}, {"judge": "A1", "score": "4.6"}, {"judge": "A2", "score": "4.9"}, {"judge": "A1", "score": "4.6"}, {"judge": "A2", "score": "4.2"}, {"judge": "B1", "score": "3.7"}, {"judge": "B2", "score": "1.8"}]}', '2025-11-27 23:24:34.970949');
INSERT INTO public.tournament_results VALUES (1, 3, 18, 1, 8.02, NULL, '{"avg_a": "4.86", "avg_b": "3.76", "deductions": "0.60", "raw_scores": [{"judge": "A1", "score": "5.0"}, {"judge": "A2", "score": "4.9"}, {"judge": "B1", "score": "3.4"}, {"judge": "B2", "score": "2.1"}, {"judge": "A1", "score": "4.9"}, {"judge": "A2", "score": "5.0"}, {"judge": "B1", "score": "4.4"}, {"judge": "B2", "score": "5.0"}, {"judge": "A1", "score": "4.5"}, {"judge": "B1", "score": "3.9"}]}', '2025-11-27 23:36:38.621074');


--
-- TOC entry 3889 (class 0 OID 24685)
-- Dependencies: 241
-- Data for Name: tournament_schools; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tournament_schools VALUES (3, 9);
INSERT INTO public.tournament_schools VALUES (3, 8);
INSERT INTO public.tournament_schools VALUES (3, 11);
INSERT INTO public.tournament_schools VALUES (3, 12);


--
-- TOC entry 3885 (class 0 OID 24620)
-- Dependencies: 237
-- Data for Name: tournaments; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tournaments VALUES (2, 'Winter Open 2025', '2025-11-24', '2025-11-26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, '2025-11-24 16:53:47.333577', '2025-11-24 16:53:42.959847', NULL, '#1E40AF', '#F3F4F6', NULL);
INSERT INTO public.tournaments VALUES (1, 'Legacy Tournament', '2025-11-24', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, false, '2025-11-24 16:56:34.722181', '2025-11-24 16:48:18.357118', NULL, '#1E40AF', '#F3F4F6', NULL);
INSERT INTO public.tournaments VALUES (3, 'Winter Cup 2026', '2025-11-12', '2025-11-15', NULL, '9086937777', '8 Stone House Dr', 'Whitehouse Station', 'NJ', NULL, 'rsetti@msn.com', true, '2025-11-25 16:44:20.432258', '2025-11-24 22:10:08.8431', '', '#d01616', '#d01616', 'Taking place alongside the USAWKF Junior Team Trials, the Winter Presidential Wushu Cup offers athletes an additional exciting competition with the option to qualify for the USA Kungfu Team (Kungfu Team Trials).

Event details and schedules can additionally be found at www.PresidentialWushuCup.com.

Tickets are required for all non-athletes, for both Team Trials and Winter Presidential Wushu Cup, with the exception of one coach per team, judges and VIPs:

$40 for the entire competition pass
$20 for a single-day pass');


--
-- TOC entry 3881 (class 0 OID 16449)
-- Dependencies: 233
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users VALUES (1, 'admin', '$2b$10$kzPBq/podcAC36lvN8QjyOkGTXu7IsX81hnHoolZnWGKNdf3hf7um', 'admin', '2025-03-23 16:33:46.734346', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767');
INSERT INTO public.users VALUES (2, 'headjudge', '$2b$10$bHx.unxdANriEbpbY68jG.RQ08rs9e34vVP1e2RhHXpp7ex9mbXiq', 'head_judge', '2025-03-23 16:33:46.734346', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767');
INSERT INTO public.users VALUES (3, 'judgea1', '$2b$10$rSnus9aYn21g0rli3FK6KevCEGwdLPVPzMTSX./FkYKnqgnOkYbHC', 'judge_a', '2025-03-23 16:33:46.734346', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767');
INSERT INTO public.users VALUES (4, 'judgea2', '$2b$10$52QtWSZCzNaXr8zJjAh3nexcNqR0gRuQrYKYzz31Vj86ndS6i8eyq', 'judge_a', '2025-03-23 16:33:46.734346', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767');
INSERT INTO public.users VALUES (5, 'judgeb1', '$2b$10$M6HNp8o5OLsN1aLfPjQPMuKbbNAo5quWH1ARn8zS8oihHDsK2hPjW', 'judge_b', '2025-03-23 16:33:46.734346', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767');
INSERT INTO public.users VALUES (6, 'judgeb2', '$2b$10$N7o8XfuhKQE6cwCNsRkVeO/N9SrJZhOCf.1IMdF/e92.cCmY0YqTe', 'judge_b', '2025-03-23 16:33:46.734346', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767');
INSERT INTO public.users VALUES (8, 'fff@fff.fff', '$2b$10$MIoeaTAIDPPp4V38e0Da5e.QnTN5D.7y5WwPfbavTseM0YMbuNjVC', 'participant', '2025-11-25 21:16:58.126452', 'fff@fff.fff', 'sdfsdfsfsdf', '', 'sdsdfsdfsdf', '2025-11-13', 'M', NULL, NULL, NULL, '', '', '', '', '', '', '', '', '2025-11-26 23:36:13.197767');
INSERT INTO public.users VALUES (9, 'rsetti@msn.com', '$2b$10$M6Qh2EDvnQuEnW1J9OJwIeQDt8oVZzSdK9SBz4W/tU6txcwurMYYO', 'participant', '2025-11-25 21:16:58.126452', 'rsetti@msn.com', 'Ricardo', NULL, 'Balbachevsky Settissss', '2025-11-12', 'M', NULL, NULL, NULL, '9086937777', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767');
INSERT INTO public.users VALUES (10, 'rsetti2@msn.com', '$2b$10$bohq.JFHnimfPyPSwysI5.czDd31LbAlNJ8FCpnBeHPWgaO1cmGMS', 'participant', '2025-11-25 21:16:58.126452', 'rsetti2@msn.com', 'Ricardo', NULL, 'Balbachevsky Setti', '2025-10-27', 'M', NULL, NULL, NULL, '9086937777', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767');
INSERT INTO public.users VALUES (11, 'rsetti3@msn.com', '$2b$10$M7X3uKqpugyf2kRV3XFUke8KXItgsFcW1vdb6EUrMMreepg.uuLyC', 'participant', '2025-11-25 21:16:58.126452', 'rsetti3@msn.com', 'Ricardo', '', 'Balbachevsky Setti', '2025-10-31', 'M', NULL, NULL, NULL, '9086937777', '', '', '', '', '', '', '', '2025-11-26 23:36:13.197767');
INSERT INTO public.users VALUES (13, 'rsetti6@msn.com', '$2b$10$51k.0/a4KTH7k.0i2QcZTuUEPXMnDKgkdEz2Dg9LMhztekiYcD1Eu', 'participant', '2025-11-25 22:15:02.934759', 'rsetti6@msn.com', 'Ricardo', NULL, 'Balbachevsky Setti', '2025-11-20', 'M', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:13.197767');
INSERT INTO public.users VALUES (14, 'rsetti7@msn.com', '$2b$10$cX0Bp1m9.eCjaoTQys.63e1fmIPjdDhMRJMQBqlwUVGMv2R04tpfW', 'participant', '2025-11-25 22:17:21.353375', 'rsetti7@msn.com', 'Ricardo', NULL, 'Balbachevsky Setti', '2025-11-11', 'M', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-26 23:36:58.57539');


--
-- TOC entry 3909 (class 0 OID 0)
-- Dependencies: 218
-- Name: deductions_deduction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.deductions_deduction_id_seq', 4, true);


--
-- TOC entry 3910 (class 0 OID 0)
-- Dependencies: 220
-- Name: divisions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.divisions_id_seq', 9, true);


--
-- TOC entry 3911 (class 0 OID 0)
-- Dependencies: 222
-- Name: participant_deductions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.participant_deductions_id_seq', 140, true);


--
-- TOC entry 3912 (class 0 OID 0)
-- Dependencies: 224
-- Name: participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.participants_id_seq', 20, true);


--
-- TOC entry 3913 (class 0 OID 0)
-- Dependencies: 226
-- Name: published_scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.published_scores_id_seq', 182, true);


--
-- TOC entry 3914 (class 0 OID 0)
-- Dependencies: 238
-- Name: registrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.registrations_id_seq', 6, true);


--
-- TOC entry 3915 (class 0 OID 0)
-- Dependencies: 228
-- Name: schools_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schools_id_seq', 12, true);


--
-- TOC entry 3916 (class 0 OID 0)
-- Dependencies: 230
-- Name: scores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wushu
--

SELECT pg_catalog.setval('public.scores_id_seq', 311, true);


--
-- TOC entry 3917 (class 0 OID 0)
-- Dependencies: 242
-- Name: tournament_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tournament_results_id_seq', 7, true);


--
-- TOC entry 3918 (class 0 OID 0)
-- Dependencies: 236
-- Name: tournaments_tournament_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tournaments_tournament_id_seq', 3, true);


--
-- TOC entry 3919 (class 0 OID 0)
-- Dependencies: 234
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 14, true);


--
-- TOC entry 3654 (class 2606 OID 16463)
-- Name: deductions deductions_deduction_code_key; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.deductions
    ADD CONSTRAINT deductions_deduction_code_key UNIQUE (deduction_code);


--
-- TOC entry 3656 (class 2606 OID 16465)
-- Name: deductions deductions_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.deductions
    ADD CONSTRAINT deductions_pkey PRIMARY KEY (deduction_id);


--
-- TOC entry 3658 (class 2606 OID 16467)
-- Name: divisions divisions_division_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.divisions
    ADD CONSTRAINT divisions_division_name_key UNIQUE (division_name);


--
-- TOC entry 3660 (class 2606 OID 16469)
-- Name: divisions divisions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.divisions
    ADD CONSTRAINT divisions_pkey PRIMARY KEY (id);


--
-- TOC entry 3662 (class 2606 OID 16471)
-- Name: participant_deductions participant_deductions_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions
    ADD CONSTRAINT participant_deductions_pkey PRIMARY KEY (id);


--
-- TOC entry 3664 (class 2606 OID 16473)
-- Name: participants participants_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_pkey PRIMARY KEY (id);


--
-- TOC entry 3666 (class 2606 OID 16475)
-- Name: published_scores published_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores
    ADD CONSTRAINT published_scores_pkey PRIMARY KEY (id);


--
-- TOC entry 3689 (class 2606 OID 24660)
-- Name: registrations_divisions registrations_divisions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations_divisions
    ADD CONSTRAINT registrations_divisions_pkey PRIMARY KEY (registration_id, division_id);


--
-- TOC entry 3687 (class 2606 OID 24643)
-- Name: registrations registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_pkey PRIMARY KEY (id);


--
-- TOC entry 3669 (class 2606 OID 16477)
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- TOC entry 3671 (class 2606 OID 16479)
-- Name: scores scores_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_pkey PRIMARY KEY (id);


--
-- TOC entry 3673 (class 2606 OID 16481)
-- Name: tournament_details tournament_details_pkey; Type: CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.tournament_details
    ADD CONSTRAINT tournament_details_pkey PRIMARY KEY (argument);


--
-- TOC entry 3683 (class 2606 OID 24608)
-- Name: tournament_divisions tournament_divisions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_divisions
    ADD CONSTRAINT tournament_divisions_pkey PRIMARY KEY (tournament_id, division_id);


--
-- TOC entry 3675 (class 2606 OID 16483)
-- Name: tournament_participants tournament_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_pkey PRIMARY KEY (participant_id, division_id);


--
-- TOC entry 3693 (class 2606 OID 24733)
-- Name: tournament_results tournament_results_participant_id_division_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_results
    ADD CONSTRAINT tournament_results_participant_id_division_id_key UNIQUE (participant_id, division_id);


--
-- TOC entry 3695 (class 2606 OID 24731)
-- Name: tournament_results tournament_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_results
    ADD CONSTRAINT tournament_results_pkey PRIMARY KEY (id);


--
-- TOC entry 3691 (class 2606 OID 24689)
-- Name: tournament_schools tournament_schools_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_schools
    ADD CONSTRAINT tournament_schools_pkey PRIMARY KEY (tournament_id, school_id);


--
-- TOC entry 3685 (class 2606 OID 24630)
-- Name: tournaments tournaments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_pkey PRIMARY KEY (tournament_id);


--
-- TOC entry 3677 (class 2606 OID 24713)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 3679 (class 2606 OID 16485)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3681 (class 2606 OID 16487)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 3667 (class 1259 OID 16488)
-- Name: idx_schools_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_schools_name ON public.schools USING btree (school_name);


--
-- TOC entry 3699 (class 2606 OID 16489)
-- Name: participants fk_school; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT fk_school FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 3696 (class 2606 OID 16494)
-- Name: participant_deductions participant_deductions_deduction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions
    ADD CONSTRAINT participant_deductions_deduction_id_fkey FOREIGN KEY (deduction_id) REFERENCES public.deductions(deduction_id) ON DELETE CASCADE;


--
-- TOC entry 3697 (class 2606 OID 16499)
-- Name: participant_deductions participant_deductions_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions
    ADD CONSTRAINT participant_deductions_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE SET NULL;


--
-- TOC entry 3698 (class 2606 OID 16504)
-- Name: participant_deductions participant_deductions_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participant_deductions
    ADD CONSTRAINT participant_deductions_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 3700 (class 2606 OID 16509)
-- Name: participants participants_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- TOC entry 3701 (class 2606 OID 24671)
-- Name: participants participants_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(tournament_id);


--
-- TOC entry 3702 (class 2606 OID 16514)
-- Name: published_scores published_scores_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores
    ADD CONSTRAINT published_scores_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE SET NULL;


--
-- TOC entry 3703 (class 2606 OID 16519)
-- Name: published_scores published_scores_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.published_scores
    ADD CONSTRAINT published_scores_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 3713 (class 2606 OID 24666)
-- Name: registrations_divisions registrations_divisions_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations_divisions
    ADD CONSTRAINT registrations_divisions_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE CASCADE;


--
-- TOC entry 3714 (class 2606 OID 24661)
-- Name: registrations_divisions registrations_divisions_registration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations_divisions
    ADD CONSTRAINT registrations_divisions_registration_id_fkey FOREIGN KEY (registration_id) REFERENCES public.registrations(id) ON DELETE CASCADE;


--
-- TOC entry 3709 (class 2606 OID 24749)
-- Name: registrations registrations_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id);


--
-- TOC entry 3710 (class 2606 OID 24651)
-- Name: registrations registrations_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- TOC entry 3711 (class 2606 OID 24646)
-- Name: registrations registrations_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(tournament_id);


--
-- TOC entry 3712 (class 2606 OID 24716)
-- Name: registrations registrations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 3704 (class 2606 OID 16524)
-- Name: scores scores_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE SET NULL;


--
-- TOC entry 3705 (class 2606 OID 16529)
-- Name: scores scores_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wushu
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 3708 (class 2606 OID 24614)
-- Name: tournament_divisions tournament_divisions_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_divisions
    ADD CONSTRAINT tournament_divisions_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE CASCADE;


--
-- TOC entry 3706 (class 2606 OID 16534)
-- Name: tournament_participants tournament_participants_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE CASCADE;


--
-- TOC entry 3707 (class 2606 OID 16539)
-- Name: tournament_participants tournament_participants_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 3717 (class 2606 OID 24744)
-- Name: tournament_results tournament_results_division_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_results
    ADD CONSTRAINT tournament_results_division_id_fkey FOREIGN KEY (division_id) REFERENCES public.divisions(id) ON DELETE CASCADE;


--
-- TOC entry 3718 (class 2606 OID 24739)
-- Name: tournament_results tournament_results_participant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_results
    ADD CONSTRAINT tournament_results_participant_id_fkey FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- TOC entry 3719 (class 2606 OID 24734)
-- Name: tournament_results tournament_results_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_results
    ADD CONSTRAINT tournament_results_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(tournament_id) ON DELETE CASCADE;


--
-- TOC entry 3715 (class 2606 OID 24695)
-- Name: tournament_schools tournament_schools_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_schools
    ADD CONSTRAINT tournament_schools_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- TOC entry 3716 (class 2606 OID 24690)
-- Name: tournament_schools tournament_schools_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_schools
    ADD CONSTRAINT tournament_schools_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(tournament_id) ON DELETE CASCADE;


--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE participants; Type: ACL; Schema: public; Owner: wushu
--

GRANT ALL ON TABLE public.participants TO postgres;


-- Completed on 2025-11-27 23:51:46 EST

--
-- PostgreSQL database dump complete
--

