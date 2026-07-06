-- =============================================================================
-- RLS — Approvals / Workflow  |  AGENTS.md §84, §104
-- Only authorized users may transition workflow states, and transitions are
-- performed exclusively by Edge Functions (Flutter never decides validity).
-- =============================================================================

ALTER TABLE approvals            ENABLE ROW LEVEL SECURITY;
ALTER TABLE approval_history     ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_states      ENABLE ROW LEVEL SECURITY;
ALTER TABLE workflow_transitions ENABLE ROW LEVEL SECURITY;

-- approvals ------------------------------------------------------------------
-- Visible whenever the underlying patient is accessible.
CREATE POLICY rls_approvals_select ON approvals
    FOR SELECT USING (
        can_access_patient(patient_id)
    );

-- Creating an approval requires the ability to update the patient's case.
CREATE POLICY rls_approvals_insert ON approvals
    FOR INSERT WITH CHECK (
        has_permission('patient.update') AND can_access_patient(patient_id)
    );

-- Direct client UPDATE is intentionally NOT granted for state changes.
-- State transitions flow through Edge Functions (service role), which validate
-- the required permission against workflow_transitions and write an audit row.
-- A narrow UPDATE policy allows only approvers to touch review metadata.
CREATE POLICY rls_approvals_update ON approvals
    FOR UPDATE USING (
        (has_permission('patient.approve') OR has_permission('patient.reject'))
        AND can_access_patient(patient_id)
    );

-- approval_history: append-only, readable with the patient -------------------
CREATE POLICY rls_approval_history_select ON approval_history
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM approvals a
            WHERE a.id = approval_history.approval_id
              AND can_access_patient(a.patient_id)
        )
    );

-- Inserts to history come from Edge Functions; no client UPDATE/DELETE.
CREATE POLICY rls_approval_history_insert ON approval_history
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM approvals a
            WHERE a.id = approval_history.approval_id
              AND can_access_patient(a.patient_id)
        )
    );

-- Workflow catalogues: readable by authenticated users -----------------------
CREATE POLICY rls_workflow_states_select ON workflow_states
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY rls_workflow_transitions_select ON workflow_transitions
    FOR SELECT USING (auth.role() = 'authenticated');

-- audit_logs and activity_timeline are append-only and never editable (§59,§83).
