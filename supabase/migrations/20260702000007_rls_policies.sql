-- Migration: rls_policies
-- Purpose:   Row-Level Security policies for all business tables (AGENTS.md §63–§86)
--            Policies are mandatory — never disabled, even for admins.
-- Reversible: yes

-- === UP =====================================================================

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Current authenticated user id.
CREATE OR REPLACE FUNCTION current_user_id() RETURNS UUID
LANGUAGE sql STABLE AS $$
    SELECT auth.uid();
$$;

-- Does the current user hold a permission via any active role?
CREATE OR REPLACE FUNCTION has_permission(p_permission TEXT) RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
    SELECT EXISTS (
        SELECT 1
        FROM user_roles ur
        JOIN role_permissions rp ON rp.role_id = ur.role_id
        JOIN permissions p       ON p.id = rp.permission_id
        WHERE ur.user_id = auth.uid()
          AND ur.is_active
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
          AND ur.is_active
          AND r.code = 'SUPER_ADMIN'
    );
$$;

-- Is the current user an Admin (or Super Admin)?
CREATE OR REPLACE FUNCTION is_admin() RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
    SELECT EXISTS (
        SELECT 1
        FROM user_roles ur
        JOIN roles r ON r.id = ur.role_id
        WHERE ur.user_id = auth.uid()
          AND ur.is_active
          AND r.code IN ('ADMIN', 'SUPER_ADMIN')
    );
$$;

-- Can the current user access this hospital?
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

-- Can the current user access this patient?
CREATE OR REPLACE FUNCTION can_access_patient(p_patient_id UUID) RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
    SELECT
        is_super_admin()
        OR EXISTS (
            SELECT 1
            FROM patient_assignments pa
            WHERE pa.patient_id = p_patient_id
              AND pa.user_id = auth.uid()
              AND pa.is_active
        )
        OR EXISTS (
            SELECT 1
            FROM patients p
            JOIN hospital_assignments ha
              ON ha.hospital_id = p.hospital_id
            WHERE p.id = p_patient_id
              AND ha.user_id = auth.uid()
              AND ha.is_active
              AND is_admin()
        );
$$;

-- ============================================================================
-- USERS & AUTHORIZATION (identity)
-- ============================================================================

ALTER TABLE users            ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles            ENABLE ROW LEVEL SECURITY;
ALTER TABLE permissions      ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles       ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions         ENABLE ROW LEVEL SECURITY;

CREATE POLICY rls_users_select ON users
    FOR SELECT USING (id = auth.uid() OR has_permission('user.manage'));
CREATE POLICY rls_users_update ON users
    FOR UPDATE USING (id = auth.uid() OR has_permission('user.manage'));
CREATE POLICY rls_users_insert ON users
    FOR INSERT WITH CHECK (has_permission('user.manage'));
CREATE POLICY rls_users_delete ON users
    FOR DELETE USING (is_super_admin());

CREATE POLICY rls_roles_select ON roles
    FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY rls_roles_write ON roles
    FOR ALL USING (has_permission('user.manage'))
    WITH CHECK (has_permission('user.manage'));

CREATE POLICY rls_permissions_select ON permissions
    FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY rls_permissions_write ON permissions
    FOR ALL USING (is_super_admin()) WITH CHECK (is_super_admin());

CREATE POLICY rls_role_permissions_select ON role_permissions
    FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY rls_role_permissions_write ON role_permissions
    FOR ALL USING (has_permission('user.manage'))
    WITH CHECK (has_permission('user.manage'));

CREATE POLICY rls_user_roles_select ON user_roles
    FOR SELECT USING (user_id = auth.uid() OR has_permission('user.manage'));
CREATE POLICY rls_user_roles_write ON user_roles
    FOR ALL USING (has_permission('user.manage'))
    WITH CHECK (has_permission('user.manage'));

CREATE POLICY rls_sessions_select ON sessions
    FOR SELECT USING (user_id = auth.uid());
CREATE POLICY rls_sessions_delete ON sessions
    FOR DELETE USING (user_id = auth.uid() OR is_super_admin());

-- ============================================================================
-- ORGANIZATIONS
-- ============================================================================

ALTER TABLE hospitals            ENABLE ROW LEVEL SECURITY;
ALTER TABLE hospital_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments          ENABLE ROW LEVEL SECURITY;
ALTER TABLE wards                ENABLE ROW LEVEL SECURITY;
ALTER TABLE beds                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE operating_theatres   ENABLE ROW LEVEL SECURITY;

-- hospital_type is public lookup, no RLS needed

CREATE POLICY rls_hospitals_select ON hospitals
    FOR SELECT USING (has_permission('hospital.view') AND can_access_hospital(id));
CREATE POLICY rls_hospitals_insert ON hospitals
    FOR INSERT WITH CHECK (has_permission('hospital.create') AND is_admin());
CREATE POLICY rls_hospitals_update ON hospitals
    FOR UPDATE USING (has_permission('hospital.update') AND is_admin());
CREATE POLICY rls_hospitals_delete ON hospitals
    FOR DELETE USING (is_super_admin());

CREATE POLICY rls_hospital_assignments_select ON hospital_assignments
    FOR SELECT USING (user_id = auth.uid() OR is_admin());
CREATE POLICY rls_hospital_assignments_write ON hospital_assignments
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY rls_departments_select ON departments
    FOR SELECT USING (can_access_hospital(hospital_id));
CREATE POLICY rls_departments_write ON departments
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY rls_wards_select ON wards
    FOR SELECT USING (can_access_hospital(hospital_id));
CREATE POLICY rls_wards_write ON wards
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY rls_beds_select ON beds
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM wards w WHERE w.id = beds.ward_id AND can_access_hospital(w.hospital_id))
    );
CREATE POLICY rls_beds_write ON beds
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

CREATE POLICY rls_ot_select ON operating_theatres
    FOR SELECT USING (can_access_hospital(hospital_id));
CREATE POLICY rls_ot_write ON operating_theatres
    FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- ============================================================================
-- PATIENTS
-- ============================================================================

ALTER TABLE patients             ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_assignments  ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_contacts     ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_addresses    ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_guardians    ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_notes        ENABLE ROW LEVEL SECURITY;
-- patient_status is lookup, readable by all authenticated

CREATE POLICY rls_patients_select ON patients
    FOR SELECT USING (has_permission('patient.read') AND can_access_patient(id));
CREATE POLICY rls_patients_insert ON patients
    FOR INSERT WITH CHECK (has_permission('patient.create'));
CREATE POLICY rls_patients_update ON patients
    FOR UPDATE USING (has_permission('patient.update') AND can_access_patient(id));
CREATE POLICY rls_patients_delete ON patients
    FOR DELETE USING (has_permission('patient.delete') AND is_super_admin());

CREATE POLICY rls_patient_assignments_select ON patient_assignments
    FOR SELECT USING (can_access_patient(patient_id));
CREATE POLICY rls_patient_assignments_write ON patient_assignments
    FOR ALL USING (has_permission('patient.assign'))
    WITH CHECK (has_permission('patient.assign'));

CREATE POLICY rls_patient_contacts_select ON patient_contacts
    FOR SELECT USING (can_access_patient(patient_id));
CREATE POLICY rls_patient_contacts_write ON patient_contacts
    FOR ALL USING (can_access_patient(patient_id))
    WITH CHECK (can_access_patient(patient_id));

CREATE POLICY rls_patient_addresses_select ON patient_addresses
    FOR SELECT USING (can_access_patient(patient_id));
CREATE POLICY rls_patient_addresses_write ON patient_addresses
    FOR ALL USING (can_access_patient(patient_id))
    WITH CHECK (can_access_patient(patient_id));

CREATE POLICY rls_patient_guardians_select ON patient_guardians
    FOR SELECT USING (can_access_patient(patient_id));
CREATE POLICY rls_patient_guardians_write ON patient_guardians
    FOR ALL USING (can_access_patient(patient_id))
    WITH CHECK (can_access_patient(patient_id));

CREATE POLICY rls_patient_status_history_select ON patient_status_history
    FOR SELECT USING (can_access_patient(patient_id));
-- Inserts to status history come from Edge Functions
CREATE POLICY rls_patient_status_history_insert ON patient_status_history
    FOR INSERT WITH CHECK (has_permission('patient.update') AND can_access_patient(
        (SELECT patient_id FROM patient_status_history WHERE id = patient_status_history.id)
    ));

CREATE POLICY rls_patient_notes_select ON patient_notes
    FOR SELECT USING (can_access_patient(patient_id));
CREATE POLICY rls_patient_notes_write ON patient_notes
    FOR ALL USING (can_access_patient(patient_id))
    WITH CHECK (can_access_patient(patient_id));

-- ============================================================================
-- CLINICAL
-- ============================================================================

ALTER TABLE treatments              ENABLE ROW LEVEL SECURITY;
ALTER TABLE diagnoses               ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions           ENABLE ROW LEVEL SECURITY;
ALTER TABLE conservative_treatments ENABLE ROW LEVEL SECURITY;
ALTER TABLE surgical_treatments     ENABLE ROW LEVEL SECURITY;
ALTER TABLE surgeries               ENABLE ROW LEVEL SECURITY;
ALTER TABLE ot_schedules            ENABLE ROW LEVEL SECURITY;
ALTER TABLE followups               ENABLE ROW LEVEL SECURITY;

-- Treatment access follows patient access
CREATE POLICY rls_treatments_select ON treatments
    FOR SELECT USING (has_permission('patient.read') AND can_access_patient(patient_id));
CREATE POLICY rls_treatments_insert ON treatments
    FOR INSERT WITH CHECK (has_permission('patient.update') AND can_access_patient(patient_id));
CREATE POLICY rls_treatments_update ON treatments
    FOR UPDATE USING (has_permission('patient.update') AND can_access_patient(patient_id));
CREATE POLICY rls_treatments_delete ON treatments
    FOR DELETE USING (is_super_admin());

CREATE POLICY rls_diagnoses_select ON diagnoses
    FOR SELECT USING (can_access_patient(patient_id));
CREATE POLICY rls_diagnoses_write ON diagnoses
    FOR ALL USING (has_permission('patient.update') AND can_access_patient(patient_id))
    WITH CHECK (can_access_patient(patient_id));

CREATE POLICY rls_prescriptions_select ON prescriptions
    FOR SELECT USING (can_access_patient(patient_id));
CREATE POLICY rls_prescriptions_write ON prescriptions
    FOR ALL USING (has_permission('patient.update') AND can_access_patient(patient_id))
    WITH CHECK (can_access_patient(patient_id));

CREATE POLICY rls_conservative_tx_select ON conservative_treatments
    FOR SELECT USING (can_access_patient((SELECT patient_id FROM treatments WHERE id = treatment_id)));
CREATE POLICY rls_conservative_tx_write ON conservative_treatments
    FOR ALL USING (has_permission('patient.update') AND can_access_patient(
        (SELECT patient_id FROM treatments WHERE id = treatment_id)))
    WITH CHECK (true);

CREATE POLICY rls_surgical_tx_select ON surgical_treatments
    FOR SELECT USING (can_access_patient((SELECT patient_id FROM treatments WHERE id = treatment_id)));
CREATE POLICY rls_surgical_tx_write ON surgical_treatments
    FOR ALL USING (has_permission('patient.update') AND can_access_patient(
        (SELECT patient_id FROM treatments WHERE id = treatment_id)))
    WITH CHECK (true);

CREATE POLICY rls_surgeries_select ON surgeries
    FOR SELECT USING (can_access_patient(patient_id));
CREATE POLICY rls_surgeries_write ON surgeries
    FOR ALL USING (has_permission('patient.update') AND can_access_patient(patient_id))
    WITH CHECK (can_access_patient(patient_id));

CREATE POLICY rls_ot_schedules_select ON ot_schedules
    FOR SELECT USING (can_access_patient(patient_id));
CREATE POLICY rls_ot_schedules_insert ON ot_schedules
    FOR INSERT WITH CHECK (has_permission('patient.update') AND can_access_patient(patient_id));
CREATE POLICY rls_ot_schedules_update ON ot_schedules
    FOR UPDATE USING (has_permission('patient.update') AND can_access_patient(patient_id));
CREATE POLICY rls_ot_schedules_delete ON ot_schedules
    FOR DELETE USING (is_super_admin());

CREATE POLICY rls_followups_select ON followups
    FOR SELECT USING (can_access_patient(patient_id));
CREATE POLICY rls_followups_write ON followups
    FOR ALL USING (has_permission('patient.update') AND can_access_patient(patient_id))
    WITH CHECK (can_access_patient(patient_id));

-- ============================================================================
-- DOCUMENTS
-- ============================================================================

ALTER TABLE documents          ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_versions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE attachments        ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY rls_documents_select ON documents
    FOR SELECT USING (has_permission('patient.read') AND can_access_patient(patient_id) AND NOT is_deleted);
CREATE POLICY rls_documents_insert ON documents
    FOR INSERT WITH CHECK (has_permission('document.upload') AND can_access_patient(patient_id));
CREATE POLICY rls_documents_update ON documents
    FOR UPDATE USING (has_permission('document.upload') AND can_access_patient(patient_id));
CREATE POLICY rls_documents_delete ON documents
    FOR DELETE USING (has_permission('document.delete') AND is_super_admin());

CREATE POLICY rls_document_versions_select ON document_versions
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM documents d WHERE d.id = document_id AND can_access_patient(d.patient_id))
    );
CREATE POLICY rls_document_versions_insert ON document_versions
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM documents d WHERE d.id = document_id AND has_permission('document.upload') AND can_access_patient(d.patient_id))
    );

CREATE POLICY rls_attachments_select ON attachments
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM documents d WHERE d.id = document_id AND can_access_patient(d.patient_id))
    );
CREATE POLICY rls_attachments_insert ON attachments
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM documents d WHERE d.id = document_id AND has_permission('document.upload') AND can_access_patient(d.patient_id))
    );

CREATE POLICY rls_document_categories_select ON document_categories
    FOR SELECT USING (auth.role() = 'authenticated');

-- ============================================================================
-- WORKFLOW / APPROVALS
-- ============================================================================

ALTER TABLE approvals            ENABLE ROW LEVEL SECURITY;
ALTER TABLE approval_history     ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_states      ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_transitions ENABLE ROW LEVEL SECURITY;

CREATE POLICY rls_approvals_select ON approvals
    FOR SELECT USING (can_access_patient(patient_id));
CREATE POLICY rls_approvals_insert ON approvals
    FOR INSERT WITH CHECK (has_permission('patient.update') AND can_access_patient(patient_id));
CREATE POLICY rls_approvals_update ON approvals
    FOR UPDATE USING (
        (has_permission('patient.approve') OR has_permission('patient.reject'))
        AND can_access_patient(patient_id)
    );
-- No client DELETE on approvals (immutable once created)

CREATE POLICY rls_approval_history_select ON approval_history
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM approvals a WHERE a.id = approval_id AND can_access_patient(a.patient_id))
    );
CREATE POLICY rls_approval_history_insert ON approval_history
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM approvals a WHERE a.id = approval_id AND can_access_patient(a.patient_id))
    );

CREATE POLICY rls_workflow_states_select ON workflow_states
    FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY rls_workflow_transitions_select ON workflow_transitions
    FOR SELECT USING (auth.role() = 'authenticated');

-- ============================================================================
-- AUDIT, NOTIFICATIONS, ANALYTICS
-- ============================================================================

ALTER TABLE audit_logs          ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_timeline   ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_events       ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications       ENABLE ROW LEVEL SECURITY;
ALTER TABLE dashboard_cache     ENABLE ROW LEVEL SECURITY;

-- Audit/logs: insert-only for regular users; read for admins/auditors
CREATE POLICY rls_audit_logs_select ON audit_logs
    FOR SELECT USING (has_permission('audit.view'));
CREATE POLICY rls_audit_logs_insert ON audit_logs
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Activity timeline: readable by authorized patient viewers
CREATE POLICY rls_activity_timeline_select ON activity_timeline
    FOR SELECT USING (
        patient_id IS NULL OR can_access_patient(patient_id)
    );
CREATE POLICY rls_activity_timeline_insert ON activity_timeline
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- System events: read for admins
CREATE POLICY rls_system_events_select ON system_events
    FOR SELECT USING (is_admin());
CREATE POLICY rls_system_events_insert ON system_events
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Notifications: own notifications only
CREATE POLICY rls_notifications_select ON notifications
    FOR SELECT USING (recipient_id = auth.uid());
CREATE POLICY rls_notifications_update ON notifications
    FOR UPDATE USING (recipient_id = auth.uid());
CREATE POLICY rls_notifications_insert ON notifications
    FOR INSERT WITH CHECK (has_permission('notification.send'));

-- Dashboard cache: own cache only
CREATE POLICY rls_dashboard_cache_select ON dashboard_cache
    FOR SELECT USING (user_id = auth.uid());
CREATE POLICY rls_dashboard_cache_write ON dashboard_cache
    FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- ============================================================================
-- TRIGGERS (updated_at auto-maintenance)
-- ============================================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    tbl TEXT;
BEGIN
    FOR tbl IN
        SELECT unnest(ARRAY[
            'users', 'roles', 'hospitals', 'departments', 'wards', 'beds',
            'operating_theatres', 'hospital_assignments', 'patients',
            'patient_assignments', 'patient_contacts', 'patient_addresses',
            'patient_guardians', 'patient_notes', 'treatments', 'diagnoses',
            'prescriptions', 'conservative_treatments', 'surgical_treatments',
            'surgeries', 'ot_schedules', 'followups', 'documents',
            'document_versions', 'approvals', 'notifications',
            'notification_templates', 'dashboard_cache'
        ])
    LOOP
        EXECUTE format(
            'CREATE TRIGGER trg_%s_set_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION set_updated_at()',
            tbl, tbl
        );
    END LOOP;
END;
$$;

-- === DOWN ===================================================================
-- This migration creates policies — dropping them is done per-table.
-- The reverse is: SELECT drop_policies_for_table(table_name) or manual DROP POLICY.
