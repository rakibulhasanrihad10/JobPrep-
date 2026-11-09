-- Baseline migration for JobPrep database.
-- Initial schema setup for local development and CI quality gates.

-- Enable pgcrypto for UUID and cryptographic functions if not already enabled.
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
