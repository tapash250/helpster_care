-- =============================================================================
-- RLS — Patients  |  AGENTS.md §72, §77, Appendix C, Appendix I
-- Read/Update: has_permission(patient.*) AND can_access_patient()
-- Delete: patient.delete AND Super Admin only
-- =============================================================================

-- Helper: can the current user access this patient? (ReBAC — §72) ------------
-- Visibility rules:
--   Doctor / Volunteer / Case Manager -> assigned patients only
--   Admin                             -> patients within assigned hospitals
--   Super Admin                       -> all patients
CREATE OR REPLACE FUNCTION can_access_patient(p_patient_id UUID) RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
    SELECT
        is_super_admin()
        -- Directly assigned to the patient
        OR EXISTS (
            SELECT 1
            FROM patient_assignments pa
            WHERE pa.patient_id = p_patient_id
              AND pa.user_id = auth.uid()
              AND pa.is_active
        )
        -- Admin within the patient's hospital
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

ALTER TABLE patients               ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_assignments    ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_contacts       ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_guardians      ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_status_history ENABLE ROW LEVEL SECURITY;

-- patients -------------------------------------------------------------------
CREATE POLICY rls_patients_select ON patients
    FOR SELECT USING (
        has_permission('patient.read') AND can_access_patient(id)
    );

CREATE POLICY rls_patients_insert ON patients
    FOR INSERT WITH CHECK (
        has_permission('patient.create')
    );

CREATE POLICY rls_patients_update ON patients
    FOR UPDATE USING (
        has_permission('patient.update') AND can_access_patient(id)
    );

-- Hard delete restricted to Super Admin (soft delete is the norm).
CREATE POLICY rls_patients_delete ON patients
    FOR DELETE USING (
        has_permission('patient.delete') AND is_super_admin()
    );

-- Child records inherit patient access ---------------------------------------
CREATE POLICY rls_patient_assignments_select ON patient_assignments
    FOR SELECT USING (can_access_patient(patient_id));
CREATE POLICY rls_patient_assignments_write ON patient_assignments
    FOR ALL USING (has_permission('patient.assign'))
    WITH CHECK (has_permission('patient.assign'));

CREATE POLICY rls_patient_contacts_all ON patient_contacts
    FOR ALL USING (can_access_patient(patient_id))
    WITH CHECK (can_access_patient(patient_id));

CREATE POLICY rls_patient_guardians_all ON patient_guardians
    FOR ALL USING (can_access_patient(patient_id))
    WITH CHECK (can_access_patient(patient_id));

CREATE POLICY rls_patient_status_history_select ON patient_status_history
    FOR SELECT USING (can_access_patient(patient_id));
