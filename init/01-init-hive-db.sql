-- ============================================================
-- PostgreSQL Initialisation Script
-- Runs automatically on first container boot (empty data dir)
-- Creates the Hive Metastore database and dedicated user
-- ============================================================

-- Create the dedicated Hive metastore user
CREATE USER hive WITH PASSWORD 'hive_secure_2024';

-- Create the Hive metastore database owned by hive user
CREATE DATABASE hive_metastore OWNER hive;

-- Grant all privileges on the hive_metastore database to hive user
GRANT ALL PRIVILEGES ON DATABASE hive_metastore TO hive;


