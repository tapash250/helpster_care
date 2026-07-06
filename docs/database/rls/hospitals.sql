-- =============================================================================
-- RLS — Hospitals  |  AGENTS.md §70, §78
-- View: hospital assignment AND hospital.view
-- Edit: hospital.update AND Admin | Delete: Super Admin only
-- =============================================================================

-- Helper: can the current user access this hospital? (ReBAC) -----------------
CREATE OR REPLACE FUNCTION can_access_hospital(p_hospital_id UUID) RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
    SELECT
        is_super_admin()
        OR EXISTS (
            SELECT 1
            FROM hospital_assignments ha
            WHERE ha.user_id = auth.uid()
              AND ha.hospital_id = p_hospital_id
              AND ha.is_active
        );
$$;

CREATE OR REPLACE FUNCTION is_admin() RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
    SELECT EXISTS (
        SELECT 1
        FROM user_roles ur
        JOIN roles r ON r.id = ur.role_id
        WHERE ur.user_id = auth.uid()
          AND r.code IN ('ADMIN', 'SUPER_ADMIN')
    );
$$;

ALTER TABLE hospitals            ENABLE ROW LEVEL SECURITY;
ALTER TABLE hospital_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments          ENABLE ROW LEVEL SECURITY;
ALTER TABLE wards                ENABLE ROW LEVEL SECURITY;
ALTER TABLE beds                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE operating_theatres   ENABLE ROW LEVEL SECURITY;

-- hospitals ------------------------------------------------------------------
CREATE POLICY rls_hospitals_select ON hospitals
    FOR SELECT USING (
        has_permission('hospital.view') AND can_access_hospital(id)
    );

CREATE POLICY rls_hospitals_insert ON hospitals
    FOR INSERT WITH CHECK (
        has_permission('hospital.create') AND is_admin()
    );

CREATE POLICY rls_hospitals_update ON hospitals
    FOR UPDATE USING (
        has_permission('hospital.update') AND is_admin()
    );

CREATE POLICY rls_hospitals_delete ON hospitals
    FOR DELETE USING (is_super_admin());

-- hospital_assignments -------------------------------------------------------
CREATE POLICY rls_hospital_assignments_select ON hospital_assignments
    FOR SELECT USING (
        user_id = auth.uid() OR is_admin()
    );

CREATE POLICY rls_hospital_assignments_write ON hospital_assignments
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- Child resources inherit hospital access ------------------------------------
CREATE POLICY rls_departments_select ON departments
    FOR SELECT USING (can_access_hospital(hospital_id));
CREATE POLICY rls_wards_select ON wards
    FOR SELECT USING (can_access_hospital(hospital_id));
CREATE POLICY rls_ot_select ON operating_theatres
    FOR SELECT USING (can_access_hospital(hospital_id));

-- beds: access via the ward's hospital
CREATE POLICY rls_beds_select ON beds
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM wards w
            WHERE w.id = beds.ward_id
              AND can_access_hospital(w.hospital_id)
        )
    );
