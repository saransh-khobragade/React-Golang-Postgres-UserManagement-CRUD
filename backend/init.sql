-- PostgreSQL initialization script
-- This script runs automatically when the container starts for the first time

-- Create the test_db database if it doesn't exist
SELECT 'CREATE DATABASE test_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'test_db')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE test_db TO postgres;

-- Connect to test_db and create extensions if needed
\c test_db;

-- Create any additional extensions or setup here
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Log the initialization
SELECT 'Database test_db initialized successfully' as status; 

-- Create users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    age INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);