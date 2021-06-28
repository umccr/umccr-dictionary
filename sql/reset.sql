-- reset public schema of metadata database
SELECT current_database();

DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO metadata;
GRANT ALL ON SCHEMA public TO public;