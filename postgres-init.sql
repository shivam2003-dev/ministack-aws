-- Optional PostgreSQL initialization script
-- This file is automatically run when the container starts
-- Uncomment or modify as needed

-- Create sample database
CREATE DATABASE IF NOT EXISTS app_db;

-- Create sample schema
CREATE SCHEMA IF NOT EXISTS app_schema;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE app_db TO admin;
GRANT ALL PRIVILEGES ON SCHEMA app_schema TO admin;

-- You can add initial tables here:
-- CREATE TABLE IF NOT EXISTS app_schema.users (
--   id SERIAL PRIMARY KEY,
--   name VARCHAR(100) NOT NULL,
--   email VARCHAR(100) UNIQUE,
--   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );
