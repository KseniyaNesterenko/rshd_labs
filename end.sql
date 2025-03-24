WITH spaced_tables AS (
  SELECT
    COALESCE(t.spcname, 'pg_default') AS spcname,
    c.relname,
    ROW_NUMBER() OVER (PARTITION BY COALESCE(t.spcname, 'pg_default') ORDER BY c.relname) AS rn
  FROM pg_tablespace t
  FULL JOIN pg_class c ON c.reltablespace = t.oid
  ORDER BY spcname, c.relname
)
SELECT
  CASE WHEN rn = 1 THEN spcname ELSE NULL END AS spcname,
  relname
FROM spaced_tables;


INSERT INTO test_table1 (name, value) VALUES ('Ab', 1);

ALTER TABLE public.test_table1 DROP CONSTRAINT test_table1_pkey;

CREATE UNIQUE INDEX test_table1_pkey_index
ON public.test_table1 (id)
TABLESPACE zjq75;

ALTER TABLE public.test_table1
ADD CONSTRAINT test_table1_pkey
PRIMARY KEY USING INDEX test_table1_pkey_index;


ALTER TABLE public.test_table2 DROP CONSTRAINT test_table2_pkey;

CREATE UNIQUE INDEX test_table2_pkey_index
ON public.test_table2 (id)
TABLESPACE cou57;

ALTER TABLE public.test_table2
ADD CONSTRAINT test_table2_pkey
PRIMARY KEY USING INDEX test_table2_pkey_index;


CREATE  ROLE  new_role  LOGIN  PASSWORD  'new';