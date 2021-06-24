-- init script
CREATE USER metadata WITH PASSWORD 'metadata' CREATEDB;
CREATE DATABASE metadata OWNER metadata;
GRANT ALL PRIVILEGES ON DATABASE metadata TO metadata;
