-- =============================================================================
-- RLS — Identity (users, roles, permissions)  |  AGENTS.md §65-§76, §86
-- RLS is mandatory and is never disabled, even for administrators.
-- Permissions are loaded from the database, never from the JWT (§74).
-- =============================================================================

-- Helper functions (composable, reusable — §76) -----------------------------

-- Current authenticated user id (Supabase auth.uid()).
CREATE OR REPLACE FUNCTION current_user_id() RETURNS UUID
LANGUAGE sql STABLE AS $$
    SELECT auth.uid();
$$;

-- Does the current user hold a permission (via any active role)?
CREATE OR REPLACE FUNCTION has_permission(p_permission TEXT) RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
    SELECT EXISTS (
        SELECT 1
        FROM user_roles ur
        JOIN role_permissions rp ON rp.role_id = ur.role_id
        JOIN permissions p       ON p.id = rp.permission_id
        WHERE ur.user_id = auth.uid()
          AND p.code = p_permission
    );
$$;

-- Is the current user a Super Admin?
CREATE OR REPLACE FUNCTION is_super_admin() RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
    SELECT EXISTS (
        SELECT 1
        FROM user_roles ur
        JOIN roles r ON r.id = ur.role_id
        WHERE ur.user_id = auth.uid()
          AND r.code = 'SUPER_ADMIN'
    );
$$;

-- Enable RLS -----------------------------------------------------------------
ALTER TABLE users            ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles            ENABLE ROW LEVEL SECURITY;
ALTER TABLE permissions      ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles       ENABLE ROW LEVEL SECURITY;

-- users ----------------------------------------------------------------------
-- A user may read their own record; user managers may read all.
CREATE POLICY rls_users_select ON users
    FOR SELECT USING (
        id = auth.uid() OR has_permission('user.manage')
    );

CREATE POLICY rls_users_update ON users
    FOR UPDATE USING (
        id = auth.uid() OR has_permission('user.manage')
    );

CREATE POLICY rls_users_insert ON users
    FOR INSERT WITH CHECK (has_permission('user.manage'));

CREATE POLICY rls_users_delete ON users
    FOR DELETE USING (is_super_admin());

-- roles / permissions catalogues: readable by authenticated, writable by managers
CREATE POLICY rls_roles_select ON roles
    FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY rls_roles_write ON roles
    FOR ALL USING (has_permission('user.manage'))
    WITH CHECK (has_permission('user.manage'));

CREATE POLICY rls_permissions_select ON permissions
    FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY rls_permissions_write ON permissions
    FOR ALL USING (is_super_admin()) WITH CHECK (is_super_admin());

-- role_permissions / user_roles: managed by user managers --------------------
CREATE POLICY rls_role_permissions_all ON role_permissions
    FOR ALL USING (has_permission('user.manage'))
    WITH CHECK (has_permission('user.manage'));

CREATE POLICY rls_user_roles_select ON user_roles
    FOR SELECT USING (user_id = auth.uid() OR has_permission('user.manage'));
CREATE POLICY rls_user_roles_write ON user_roles
    FOR ALL USING (has_permission('user.manage'))
    WITH CHECK (has_permission('user.manage'));
