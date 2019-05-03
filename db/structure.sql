SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: estimate_cost_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.estimate_cost_type AS ENUM (
    'ground_transportation',
    'lodging',
    'meals',
    'misc',
    'registration',
    'rental_vehicle',
    'air',
    'taxi',
    'personal_auto',
    'transit_other',
    'train'
);


--
-- Name: request_absence_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.request_absence_type AS ENUM (
    'consulting',
    'vacation_monthly',
    'personal',
    'sick',
    'jury_duty',
    'death_in_family',
    'research_days',
    'work_from_home'
);


--
-- Name: request_participation_category; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.request_participation_category AS ENUM (
    'presenter',
    'member',
    'committee_chair',
    'committee_member',
    'other',
    'site_visit',
    'training'
);


--
-- Name: request_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.request_status AS ENUM (
    'pending',
    'pending_department',
    'approved',
    'denied'
);


--
-- Name: request_travel_category; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.request_travel_category AS ENUM (
    'business',
    'professional_development',
    'discretionary'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departments (
    id bigint NOT NULL,
    name character varying,
    head_id bigint,
    admin_assistant_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.departments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- Name: estimates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.estimates (
    id bigint NOT NULL,
    request_id bigint,
    amount numeric,
    recurrence integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    cost_type public.estimate_cost_type
);


--
-- Name: estimates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.estimates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: estimates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.estimates_id_seq OWNED BY public.estimates.id;


--
-- Name: event_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_requests (
    id bigint NOT NULL,
    recurring_event_id bigint,
    start_date date,
    end_date date,
    location character varying,
    url character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    request_id bigint
);


--
-- Name: event_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.event_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.event_requests_id_seq OWNED BY public.event_requests.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id bigint NOT NULL,
    request_id bigint,
    creator_id bigint,
    content text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: recurring_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recurring_events (
    id bigint NOT NULL,
    name character varying,
    description text,
    url character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: recurring_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recurring_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recurring_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recurring_events_id_seq OWNED BY public.recurring_events.id;


--
-- Name: requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.requests (
    id bigint NOT NULL,
    creator_id bigint,
    start_date date,
    end_date date,
    request_type character varying,
    purpose character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    participation public.request_participation_category,
    travel_category public.request_travel_category,
    absence_type public.request_absence_type,
    status public.request_status
);


--
-- Name: requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.requests_id_seq OWNED BY public.requests.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: staff_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff_profiles (
    id bigint NOT NULL,
    user_id bigint,
    department_id bigint,
    supervisor_id bigint,
    biweekly boolean,
    given_name character varying,
    surname character varying,
    email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: staff_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.staff_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: staff_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.staff_profiles_id_seq OWNED BY public.staff_profiles.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    provider character varying DEFAULT 'cas'::character varying NOT NULL,
    uid character varying NOT NULL,
    remember_created_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- Name: estimates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates ALTER COLUMN id SET DEFAULT nextval('public.estimates_id_seq'::regclass);


--
-- Name: event_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_requests ALTER COLUMN id SET DEFAULT nextval('public.event_requests_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: recurring_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_events ALTER COLUMN id SET DEFAULT nextval('public.recurring_events_id_seq'::regclass);


--
-- Name: requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requests ALTER COLUMN id SET DEFAULT nextval('public.requests_id_seq'::regclass);


--
-- Name: staff_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_profiles ALTER COLUMN id SET DEFAULT nextval('public.staff_profiles_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: estimates estimates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT estimates_pkey PRIMARY KEY (id);


--
-- Name: event_requests event_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_requests
    ADD CONSTRAINT event_requests_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: recurring_events recurring_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_events
    ADD CONSTRAINT recurring_events_pkey PRIMARY KEY (id);


--
-- Name: requests requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.requests
    ADD CONSTRAINT requests_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: staff_profiles staff_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_profiles
    ADD CONSTRAINT staff_profiles_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_estimates_on_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_estimates_on_request_id ON public.estimates USING btree (request_id);


--
-- Name: index_event_requests_on_recurring_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_requests_on_recurring_event_id ON public.event_requests USING btree (recurring_event_id);


--
-- Name: index_event_requests_on_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_requests_on_request_id ON public.event_requests USING btree (request_id);


--
-- Name: index_notes_on_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_request_id ON public.notes USING btree (request_id);


--
-- Name: index_staff_profiles_on_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_staff_profiles_on_department_id ON public.staff_profiles USING btree (department_id);


--
-- Name: index_staff_profiles_on_supervisor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_staff_profiles_on_supervisor_id ON public.staff_profiles USING btree (supervisor_id);


--
-- Name: index_staff_profiles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_staff_profiles_on_user_id ON public.staff_profiles USING btree (user_id);


--
-- Name: index_users_on_provider; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_provider ON public.users USING btree (provider);


--
-- Name: index_users_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_uid ON public.users USING btree (uid);


--
-- Name: index_users_on_uid_and_provider; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_uid_and_provider ON public.users USING btree (uid, provider);


--
-- Name: event_requests fk_rails_1b72073f7f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_requests
    ADD CONSTRAINT fk_rails_1b72073f7f FOREIGN KEY (recurring_event_id) REFERENCES public.recurring_events(id);


--
-- Name: estimates fk_rails_255208b07c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estimates
    ADD CONSTRAINT fk_rails_255208b07c FOREIGN KEY (request_id) REFERENCES public.requests(id);


--
-- Name: staff_profiles fk_rails_71cb8bacdd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_profiles
    ADD CONSTRAINT fk_rails_71cb8bacdd FOREIGN KEY (supervisor_id) REFERENCES public.users(id);


--
-- Name: staff_profiles fk_rails_873ad824ec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_profiles
    ADD CONSTRAINT fk_rails_873ad824ec FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: notes fk_rails_93363d2800; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_93363d2800 FOREIGN KEY (request_id) REFERENCES public.requests(id);


--
-- Name: staff_profiles fk_rails_c6a3999052; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_profiles
    ADD CONSTRAINT fk_rails_c6a3999052 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20190422190732'),
('20190423135726'),
('20190423154000'),
('20190426171418'),
('20190426191700'),
('20190430155019'),
('20190430204306'),
('20190430205002'),
('20190501162629'),
('20190501172949'),
('20190501184807'),
('20190501185336'),
('20190501192018'),
('20190502174401'),
('20190503140654');


