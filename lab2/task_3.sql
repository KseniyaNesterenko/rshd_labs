CREATE TABLESPACE zjq75 LOCATION '/var/db/postgres0/zjq75';
CREATE TABLESPACE cou57 LOCATION '/var/db/postgres0/cou57';

CREATE DATABASE darkbrowncity WITH TEMPLATE template0 OWNER postgres0;

CREATE ROLE new_role LOGIN PASSWORD 'new';
GRANT CONNECT ON DATABASE darkbrowncity TO new_role;

CREATE TABLE test_table1 (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    value INTEGER
) TABLESPACE zjq75;


CREATE TABLE test_table2 (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    value INTEGER
) TABLESPACE cou57;

INSERT INTO test_table1 (name, value) VALUES
('A', 1),
('B', 2),
('C', 3);

INSERT INTO test_table2 (name, value) VALUES
('A', 1),
('B', 2),
('C', 3);

GRANT INSERT ON TABLE "public"." test_table1" TO new_role;
GRANT USAGE, SELECT ON SEQUENCE PUBLIC.TEST_TABLE1_ID_SEQ TO NEW_ROLE;
GRANT INSERT ON TABLE "public"."test_table2" TO new_role;
GRANT USAGE, SELECT ON SEQUENCE PUBLIC.TEST_TABLE2_ID_SEQ TO NEW_ROLE;


SELECT
  CASE WHEN ROW_NUMBER() OVER (PARTITION BY COALESCE(t.spcname, 'pg_default') ORDER BY c.relname) = 1
       THEN COALESCE(t.spcname, 'pg_default')
  END AS spcname,
  c.relname
FROM pg_tablespace t
FULL JOIN pg_class c ON c.reltablespace = t.oid
ORDER BY COALESCE(t.spcname, 'pg_default'), c.relname;


