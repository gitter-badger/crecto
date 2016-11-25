-- +micrate Up
BEGIN;

CREATE TABLE users(
  id INTEGER NOT NULL,
  name character varying NOT NULL,
  things integer,
  stuff integer,
  nope float,
  yep bool,
  created_at timestamp without time zone,
  updated_at timestamp without time zone
);

CREATE SEQUENCE users_id_seq
  START WITH 1121
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

ALTER SEQUENCE users_id_seq OWNED BY users.id;
ALTER TABLE ONLY users ADD CONSTRAINT users_pkey PRIMARY KEY (id);
ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);

CREATE UNIQUE INDEX users_4ijlkjdf ON users (id);

COMMIT;

-- +micrate Down
DROP INDEX users_4ijlkjdf;
DROP TABLE users;