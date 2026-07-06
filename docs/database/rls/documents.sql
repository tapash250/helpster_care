-- =============================================================================
-- RLS — Documents  |  AGENTS.md §79, §101, ADR-0005
-- Medical documents are PHI. Access requires permission + patient access.
-- Binaries live in Supabase Storage behind signed URLs (never public).
-- =============================================================================

ALTER TABLE documents          ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_versions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE attachments        ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_categories ENABLE ROW LEVEL SECURITY;

-- documents (metadata only; file bytes are in Storage) -----------------------
CREATE POLICY rls_documents_select ON documents
    FOR SELECT USING (
        has_permission('patient.read') AND can_access_patient(patient_id)
    );

CREATE POLICY rls_documents_insert ON documents
    FOR INSERT WITH CHECK (
        has_permission('document.upload') AND can_access_patient(patient_id)
    );

CREATE POLICY rls_documents_update ON documents
    FOR UPDATE USING (
        has_permission('document.upload') AND can_access_patient(patient_id)
    );

CREATE POLICY rls_documents_delete ON documents
    FOR DELETE USING (
        has_permission('document.delete') AND is_super_admin()
    );

-- document_versions / attachments inherit access via the parent document -----
CREATE POLICY rls_document_versions_select ON document_versions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM documents d
            WHERE d.id = document_versions.document_id
              AND can_access_patient(d.patient_id)
        )
    );

CREATE POLICY rls_attachments_select ON attachments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM documents d
            WHERE d.id = attachments.document_id
              AND can_access_patient(d.patient_id)
        )
    );

-- Category lookup: readable by authenticated users ---------------------------
CREATE POLICY rls_document_categories_select ON document_categories
    FOR SELECT USING (auth.role() = 'authenticated');

-- ---------------------------------------------------------------------------
-- Storage bucket RLS (illustrative) — objects in the private `patients` bucket
-- are only accessible when the caller can access the referenced patient. The
-- patient id is encoded in the object path: patients/PAT000001/...
-- Access is granted through short-lived signed URLs issued by the
-- uploadMedicalDocument / exportPatientPDF Edge Functions. Never expose
-- permanent public URLs for PHI.
-- ---------------------------------------------------------------------------
