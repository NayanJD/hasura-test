SET check_function_bodies = false;
CREATE TABLE public."user" (
    id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    gender text NOT NULL
);
CREATE FUNCTION public.search_users(i_lat double precision, i_lng double precision, distance double precision) RETURNS SETOF public."user"
    LANGUAGE sql STABLE
    AS $$
SELECT
  u.id,
  u.first_name,
  u.last_name,
  u.gender as gender
from
  public.user u
  join user_tracking ut on u.id = ut.user_id
where
  sqrt(
    power(111 * cos(radians(ut.lat)) * (ut.lng - i_lng), 2) + power((ut.lat - i_lat) * 111, 2)
  ) < distance
order by
  sqrt(
    power(111 * cos(radians(ut.lat)) * (ut.lng - i_lng), 2) + power((ut.lat - i_lat) * 111, 2)
  );
$$;
CREATE FUNCTION public.user_by_pagination(page_number integer, page_size integer) RETURNS SETOF public."user"
    LANGUAGE sql STABLE
    AS $$
    SELECT u.id, u.first_name as firstName, u.last_name as lastName, 
    u.gender as gender
    from public.user u 
    order by u.id
    limit page_size
    offset (page_number - 1) * page_size;
$$;
CREATE TABLE public.gender_enum (
    value text NOT NULL
);
CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;
CREATE TABLE public.user_tracking (
    user_id integer NOT NULL,
    lat double precision NOT NULL,
    lng double precision NOT NULL
);
ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);
ALTER TABLE ONLY public.gender_enum
    ADD CONSTRAINT gender_enum_pkey PRIMARY KEY (value);
ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.user_tracking
    ADD CONSTRAINT user_tracking_pkey PRIMARY KEY (user_id);
ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_gender_fkey FOREIGN KEY (gender) REFERENCES public.gender_enum(value) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.user_tracking
    ADD CONSTRAINT user_tracking_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;
