-- Migration: seed_data
-- Purpose:   Seed data for lookup tables and default roles/permissions (AGENTS.md Appendix H, Appendix B)
-- Reversible: yes

-- === UP =====================================================================

-- Hospital types
INSERT INTO hospital_type (code, label) VALUES
    ('GENERAL', 'General Hospital'),
    ('SPECIALIZED', 'Specialized Hospital'),
    ('CLINIC', 'Clinic'),
    ('MISSION', 'Mission Hospital'),
    ('FIELD', 'Field Hospital / Camp'),
    ('CHARITY', 'Charity Clinic')
ON CONFLICT (code) DO NOTHING;

-- Patient status
INSERT INTO patient_status (code, label, sort_order) VALUES
    ('DRAFT', 'Draft', 1),
    ('PENDING_DOCUMENTS', 'Pending Documents', 2),
    ('SUBMITTED', 'Submitted', 3),
    ('MEDICAL_REVIEW', 'Under Medical Review', 4),
    ('APPROVED', 'Approved', 5),
    ('ADMITTED', 'Admitted', 6),
    ('IN_TREATMENT', 'In Treatment', 7),
    ('DISCHARGED', 'Discharged', 8),
    ('FOLLOWUP', 'Follow-up', 9),
    ('CLOSED', 'Closed', 10),
    ('REJECTED', 'Rejected', 11)
ON CONFLICT (code) DO NOTHING;

-- Treatment type
INSERT INTO treatment_type (code, label) VALUES
    ('CONSERVATIVE', 'Conservative Treatment'),
    ('SURGICAL', 'Surgical Treatment')
ON CONFLICT (code) DO NOTHING;

-- Document categories
INSERT INTO document_categories (code, label, sort_order) VALUES
    ('PRESCRIPTION', 'Prescription', 1),
    ('LAB_REPORT', 'Lab Report', 2),
    ('RADIOLOGY', 'Radiology / Imaging', 3),
    ('SURGERY_NOTE', 'Surgery Note', 4),
    ('CONSENT', 'Consent Form', 5),
    ('DISCHARGE', 'Discharge Summary', 6),
    ('IDENTITY', 'Identity Document', 7),
    ('MEDICAL_CERT', 'Medical Certificate', 8),
    ('BILL', 'Bill / Receipt', 9),
    ('OTHER', 'Other', 10)
ON CONFLICT (code) DO NOTHING;

-- Workflow states
INSERT INTO workflow_states (code, label, sort_order) VALUES
    ('DRAFT', 'Draft', 1),
    ('PENDING_DOCUMENTS', 'Pending Documents', 2),
    ('SUBMITTED', 'Submitted', 3),
    ('MEDICAL_REVIEW', 'Under Medical Review', 4),
    ('APPROVED', 'Approved', 5),
    ('REJECTED', 'Rejected', 6),
    ('CLOSED', 'Closed', 7)
ON CONFLICT (code) DO NOTHING;

-- Roles
INSERT INTO roles (code, label, description, sort_order) VALUES
    ('SUPER_ADMIN', 'Super Admin', 'Full system access — all hospitals, all patients, all operations', 1),
    ('ADMIN', 'Admin', 'Hospital-level administrator — manages within assigned hospitals', 2),
    ('CASE_MANAGER', 'Case Manager', 'Manages patient cases, coordinates care across departments', 3),
    ('FIELD_OFFICER', 'Field Officer', 'Field-level patient registration and assessment', 4),
    ('DOCTOR', 'Doctor', 'Medical professional — diagnoses, treats, prescribes', 5),
    ('VOLUNTEER', 'Volunteer', 'Support role — assists with basic patient intake and logistics', 6),
    ('AUDITOR', 'Auditor', 'Read-only access for compliance and auditing', 7)
ON CONFLICT (code) DO NOTHING;

-- Permissions (core set)
INSERT INTO permissions (code, label, module) VALUES
    -- Dashboard
    ('dashboard.view', 'View Dashboard', 'dashboard'),
    -- Patient
    ('patient.create', 'Create Patient', 'patient'),
    ('patient.read', 'Read Patient', 'patient'),
    ('patient.update', 'Update Patient', 'patient'),
    ('patient.archive', 'Archive Patient', 'patient'),
    ('patient.delete', 'Delete Patient', 'patient'),
    ('patient.approve', 'Approve Patient Case', 'patient'),
    ('patient.reject', 'Reject Patient Case', 'patient'),
    ('patient.assign', 'Assign Staff to Patient', 'patient'),
    ('patient.transfer', 'Transfer Patient', 'patient'),
    ('patient.export', 'Export Patient Data', 'patient'),
    -- Hospital
    ('hospital.create', 'Create Hospital', 'hospital'),
    ('hospital.read', 'Read Hospital', 'hospital'),
    ('hospital.update', 'Update Hospital', 'hospital'),
    ('hospital.delete', 'Delete Hospital', 'hospital'),
    ('hospital.view', 'View Hospital', 'hospital'),
    ('hospital.assign', 'Assign to Hospital', 'hospital'),
    -- Doctor
    ('doctor.assign', 'Assign Doctor', 'doctor'),
    ('doctor.remove', 'Remove Doctor', 'doctor'),
    -- Document
    ('document.upload', 'Upload Document', 'document'),
    ('document.delete', 'Delete Document', 'document'),
    -- Report
    ('report.export', 'Export Reports', 'report'),
    -- Notification
    ('notification.send', 'Send Notification', 'notification'),
    -- User management
    ('user.manage', 'Manage Users', 'admin'),
    ('settings.manage', 'Manage Settings', 'admin'),
    -- Audit
    ('audit.view', 'View Audit Logs', 'audit'),
    -- Analytics
    ('analytics.view', 'View Analytics', 'analytics')
ON CONFLICT (code) DO NOTHING;

-- Role-Permission assignments (per role matrix)
-- SUPER_ADMIN gets everything
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.code = 'SUPER_ADMIN'
AND NOT EXISTS (
    SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id
);

-- ADMIN gets patient*, hospital*, dashboard, report, notification, audit, analytics, user.manage, settings.manage
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.code = 'ADMIN'
AND p.code IN (
    'dashboard.view',
    'patient.create', 'patient.read', 'patient.update', 'patient.archive',
    'patient.approve', 'patient.reject', 'patient.assign', 'patient.transfer', 'patient.export',
    'hospital.create', 'hospital.read', 'hospital.update', 'hospital.view', 'hospital.assign',
    'doctor.assign', 'doctor.remove',
    'document.upload',
    'report.export',
    'notification.send',
    'user.manage', 'settings.manage',
    'audit.view',
    'analytics.view'
)
AND NOT EXISTS (
    SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id
);

-- CASE_MANAGER gets patient, document, dashboard
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.code = 'CASE_MANAGER'
AND p.code IN (
    'dashboard.view',
    'patient.create', 'patient.read', 'patient.update',
    'patient.assign', 'patient.export',
    'hospital.view', 'hospital.assign',
    'doctor.assign',
    'document.upload',
    'report.export',
    'notification.send',
    'analytics.view'
)
AND NOT EXISTS (
    SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id
);

-- FIELD_OFFICER gets patient create/read/update, dashboard, document upload
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.code = 'FIELD_OFFICER'
AND p.code IN (
    'dashboard.view',
    'patient.create', 'patient.read', 'patient.update',
    'hospital.view',
    'document.upload'
)
AND NOT EXISTS (
    SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id
);

-- DOCTOR gets patient read/update, dashboard, document upload, analytics view
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.code = 'DOCTOR'
AND p.code IN (
    'dashboard.view',
    'patient.read', 'patient.update',
    'hospital.view',
    'document.upload',
    'analytics.view'
)
AND NOT EXISTS (
    SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id
);

-- VOLUNTEER gets patient create/read, dashboard, hospital view
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.code = 'VOLUNTEER'
AND p.code IN (
    'dashboard.view',
    'patient.create', 'patient.read',
    'hospital.view'
)
AND NOT EXISTS (
    SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id
);

-- AUDITOR gets dashboard, patient read, hospital read, audit view, analytics view, report export
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r, permissions p
WHERE r.code = 'AUDITOR'
AND p.code IN (
    'dashboard.view',
    'patient.read', 'patient.export',
    'hospital.view',
    'report.export',
    'audit.view',
    'analytics.view'
)
AND NOT EXISTS (
    SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id
);

-- Workflow transitions
INSERT INTO workflow_transitions (from_state, to_state, required_permission)
SELECT from_s, to_s, p.code
FROM (VALUES
    ('DRAFT', 'PENDING_DOCUMENTS', 'patient.update'),
    ('PENDING_DOCUMENTS', 'SUBMITTED', 'patient.update'),
    ('SUBMITTED', 'MEDICAL_REVIEW', 'patient.approve'),
    ('MEDICAL_REVIEW', 'APPROVED', 'patient.approve'),
    ('MEDICAL_REVIEW', 'REJECTED', 'patient.reject'),
    ('REJECTED', 'DRAFT', 'patient.update'),
    ('APPROVED', 'CLOSED', 'patient.update')
) AS t(from_s, to_s, perm)
CROSS JOIN permissions p
WHERE t.perm = p.code
AND NOT EXISTS (
    SELECT 1 FROM workflow_transitions wt
    WHERE wt.from_state = t.from_s AND wt.to_state = t.to_s
);

-- === DOWN ===================================================================
-- TRUNCATE role_permissions, permissions, roles, workflow_transitions, workflow_states,
--          document_categories, treatment_type, patient_status, hospital_type CASCADE;
