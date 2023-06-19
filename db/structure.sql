SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
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
    'train',
    'parking'
);


--
-- Name: request_absence_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.request_absence_type AS ENUM (
    'consulting',
    'vacation',
    'personal',
    'sick',
    'jury_duty',
    'death_in_family',
    'research_days'
);


--
-- Name: request_action; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.request_action AS ENUM (
    'approved',
    'canceled',
    'changes_requested',
    'denied',
    'recorded',
    'pending'
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
    'training',
    'vendor_visit',
    'donor_visit',
    'participant'
);


--
-- Name: request_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.request_status AS ENUM (
    'approved',
    'canceled',
    'changes_requested',
    'denied',
    'recorded',
    'pending'
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

SET default_table_access_method = heap;

--
-- Name: admin_assistants_departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_assistants_departments (
    department_id bigint NOT NULL,
    admin_assistant_id bigint NOT NULL
);


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: delegates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delegates (
    id bigint NOT NULL,
    delegate_id bigint,
    delegator_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: delegates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delegates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delegates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delegates_id_seq OWNED BY public.delegates.id;


--
-- Name: departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departments (
    id bigint NOT NULL,
    name character varying,
    head_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    number character varying
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
    cost_type public.estimate_cost_type,
    description character varying
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
-- Name: locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locations (
    id bigint NOT NULL,
    building character varying,
    admin_assistant_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


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
    travel_category public.request_travel_category,
    absence_type public.request_absence_type,
    status public.request_status,
    event_title character varying,
    start_time character varying,
    end_time character varying,
    hours_requested numeric,
    participation public.request_participation_category,
    virtual_event boolean
);


--
-- Name: requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.requests_id_seq
    START WITH 10000
    INCREMENT BY 1
    MINVALUE 10000
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
    biweekly boolean,
    given_name character varying,
    surname character varying,
    email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    supervisor_id bigint,
    location_id bigint,
    vacation_balance numeric,
    sick_balance numeric,
    personal_balance numeric,
    standard_hours_per_week numeric
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
-- Name: state_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.state_changes (
    id bigint NOT NULL,
    agent_id bigint,
    request_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    action public.request_action,
    delegate_id bigint
);


--
-- Name: state_changes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.state_changes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: state_changes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.state_changes_id_seq OWNED BY public.state_changes.id;


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
-- Name: delegates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delegates ALTER COLUMN id SET DEFAULT nextval('public.delegates_id_seq'::regclass);


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
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


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
-- Name: state_changes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_changes ALTER COLUMN id SET DEFAULT nextval('public.state_changes_id_seq'::regclass);


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
-- Name: delegates delegates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delegates
    ADD CONSTRAINT delegates_pkey PRIMARY KEY (id);


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
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


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
-- Name: state_changes state_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_changes
    ADD CONSTRAINT state_changes_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_delegates_on_delegate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delegates_on_delegate_id ON public.delegates USING btree (delegate_id);


--
-- Name: index_delegates_on_delegator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delegates_on_delegator_id ON public.delegates USING btree (delegator_id);


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
-- Name: index_staff_profiles_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_staff_profiles_on_location_id ON public.staff_profiles USING btree (location_id);


--
-- Name: index_staff_profiles_on_supervisor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_staff_profiles_on_supervisor_id ON public.staff_profiles USING btree (supervisor_id);


--
-- Name: index_staff_profiles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_staff_profiles_on_user_id ON public.staff_profiles USING btree (user_id);


--
-- Name: index_state_changes_on_delegate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_state_changes_on_delegate_id ON public.state_changes USING btree (delegate_id);


--
-- Name: index_state_changes_on_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_state_changes_on_request_id ON public.state_changes USING btree (request_id);


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
-- Name: state_changes fk_rails_481f096ec0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_changes
    ADD CONSTRAINT fk_rails_481f096ec0 FOREIGN KEY (request_id) REFERENCES public.requests(id);


--
-- Name: staff_profiles fk_rails_71cb8bacdd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_profiles
    ADD CONSTRAINT fk_rails_71cb8bacdd FOREIGN KEY (supervisor_id) REFERENCES public.staff_profiles(id);


--
-- Name: staff_profiles fk_rails_767875b248; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_profiles
    ADD CONSTRAINT fk_rails_767875b248 FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: state_changes fk_rails_77c5fcac7d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.state_changes
    ADD CONSTRAINT fk_rails_77c5fcac7d FOREIGN KEY (delegate_id) REFERENCES public.staff_profiles(id);


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
-- Name: delegates fk_rails_a968507922; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delegates
    ADD CONSTRAINT fk_rails_a968507922 FOREIGN KEY (delegator_id) REFERENCES public.staff_profiles(id);


--
-- Name: delegates fk_rails_ba46e66b89; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delegates
    ADD CONSTRAINT fk_rails_ba46e66b89 FOREIGN KEY (delegate_id) REFERENCES public.staff_profiles(id);


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
('20190502145256'),
('20190502174401'),
('20190503140654'),
('20190503152336'),
('20190506181109'),
('20190603185001'),
('20190606115402'),
('20190612114950'),
('20190613143042'),
('20190613150050'),
('20190613173252'),
('20190613185106'),
('20190614132041'),
('20190718132916'),
('20190826190425'),
('20190827172900'),
('20190918150741'),
('20191021131520'),
('20191021193122'),
('20191028173311'),
('20191029130508'),
('20191030122935'),
('20191125161410'),
('20191203144321'),
('20200124122301'),
('20200124122321'),
('20200129183415'),
('20200226200516'),
('20200227204519'),
('20200303200344'),
('20230601221141');


