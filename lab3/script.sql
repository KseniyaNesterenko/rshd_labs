INSERT INTO test_table1 (name, value) VALUES
  ('AATESTEAA', 266661),
  ('BBTESTEBB', 22);

INSERT INTO test_table2 (name, value) VALUES
  ('AATESTEAA', 26662),
  ('BBTESTEBB', 23);

DROP TABLE IF EXISTS test_table1;
DROP TABLE IF EXISTS test_table2;

DELETE FROM test_table1 WHERE id NOT IN (SELECT id FROM test_table1 ORDER BY id LIMIT 3);
DELETE FROM test_table2 WHERE id NOT IN (SELECT id FROM test_table1 ORDER BY id LIMIT 3);


echo "data_directory = '/var/db/postgres0/jtp68'" >> /var/lib/postgresql/data/postgresql.conf

INSERT INTO test_table2 (name, value) VALUES
  ('x', 23);