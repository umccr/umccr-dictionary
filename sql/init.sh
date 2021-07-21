#!/usr/bin/env bash
set -e

# init script

POSTGRES="psql --username ${POSTGRES_USER}"

echo "Creating database and role..."

$POSTGRES <<-EOSQL
CREATE USER "${PG_USER}" WITH PASSWORD '${PG_PASS}' CREATEDB;
CREATE DATABASE "${PG_NAME}" OWNER "${PG_USER}";
GRANT ALL PRIVILEGES ON DATABASE "${PG_NAME}" TO "${PG_USER}";
EOSQL
