-- To use IF statements, hence to be able to check if the user exists before
-- attempting creation, we need to switch to procedural SQL (PL/pgSQL)
-- instead of standard SQL.
-- More: https://www.postgresql.org/docs/9.3/plpgsql-overview.html
-- To preserve compatibility with <9.0, DO blocks are not used; instead,
-- a function is created and dropped.
CREATE OR REPLACE FUNCTION __tmp_create_user() returns void as $$
BEGIN
  IF NOT EXISTS (
          SELECT                       -- SELECT list can stay empty for this
          FROM   pg_catalog.pg_user
          WHERE  usename = '{{ docker_postgres_exporter_user }}') THEN
    CREATE USER {{ docker_postgres_exporter_user }};
  END IF;
END;
$$ language plpgsql;

SELECT __tmp_create_user();
DROP FUNCTION __tmp_create_user();

ALTER USER {{ docker_postgres_exporter_user }} WITH PASSWORD '{{ docker_postgres_exporter_password }}';
ALTER USER {{ docker_postgres_exporter_user }} SET SEARCH_PATH TO {{ docker_postgres_exporter_user}},pg_catalog;

-- If deploying as non-superuser (for example in AWS RDS), uncomment the GRANT
-- line below and replace <MASTER_USER> with your root user.
-- GRANT postgres_exporter TO <MASTER_USER>;

GRANT CONNECT ON DATABASE postgres TO {{ docker_postgres_exporter_user }};

GRANT pg_monitor to {{ docker_postgres_exporter_user }};
