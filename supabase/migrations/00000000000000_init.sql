-- Migration: initial extensions and shared conventions.
-- One logical change per migration; never edit an applied migration (AGENTS.md §42).
-- Keywords UPPERCASE, identifiers snake_case, 4-space indent (§192).

-- Required extensions ------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Shared trigger: keep updated_at fresh on every UPDATE (§191).
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- NOTE: Concrete tables (users, roles, patients, hospitals, treatments, …)
-- are introduced in subsequent chronological migrations. Every business table
-- MUST include: id UUID PK, created_at, updated_at, created_by, updated_by,
-- have RLS enabled, and expose SELECT/INSERT/UPDATE/DELETE policies (§40, §75).
