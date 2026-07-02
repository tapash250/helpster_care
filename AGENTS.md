# AGENTS.md

> Helpster Care Engineering Constitution & AI Development Contract
>
> Project: Helpster Care
> Version: 1.0.0
> Status: Authoritative
> Applies To:
> - ChatGPT
> - Claude Code
> - Gemini CLI
> - Cursor AI
> - Cline
> - Roo Code
> - GitHub Copilot
> - Codex
> - Windsurf
> - Any future AI coding assistant

---

# Quick Start for AI Agents

Before writing any code:

1. Read AGENTS.md.
2. Understand the affected feature.
3. Identify impacted modules.
4. Review existing implementations.
5. Respect Clean Architecture.
6. Respect RBAC + ReBAC + RLS.
7. Preserve offline-first behavior.
8. Generate tests.
9. Update documentation.
10. Never violate the Non-Negotiable Rules.

---

# Engineering Principles

Every contributor (human or AI) shall prioritize:

1. Patient Safety
2. Security by Default
3. Privacy by Design
4. Offline First
5. Simplicity over Cleverness
6. Maintainability over Speed
7. Consistency over Personal Preference
8. Documentation as Code
9. Test Before Merge
10. Continuous Improvement

---

# 1. Project Constitution

## Purpose

Helpster Care is an enterprise-grade patient case management platform designed for humanitarian and charitable healthcare organizations.

This repository is governed by a strict engineering contract to ensure consistency, maintainability, security, scalability, and patient safety.

Every AI agent working inside this repository must follow this document before reading, modifying, or generating any source code.

This file is the highest-level technical authority within the repository.

Unless explicitly overridden by the project owner, every instruction in this document is mandatory.

---

# 2. Project Vision

Helpster Care exists to provide a secure, transparent, and scalable platform that enables charities to manage patient cases from registration to recovery.

The system should allow volunteers, case managers, doctors, and administrators to collaborate efficiently while protecting sensitive medical information.

The application must continue functioning even in areas with unreliable internet connectivity through an offline-first architecture.

---

# 3. Core Objectives

The primary objectives are:

- Register patients quickly
- Manage approvals transparently
- Track conservative and surgical treatments
- Coordinate hospitals
- Maintain complete audit trails
- Protect patient privacy
- Operate offline
- Synchronize automatically
- Scale to millions of records
- Reduce administrative overhead

---

# 4. Engineering Philosophy

Engineering decisions shall always follow the priority below.

1. Patient Safety
2. Data Integrity
3. Security
4. Privacy
5. Reliability
6. Maintainability
7. Scalability
8. Accessibility
9. Performance
10. Developer Convenience

No feature may violate a higher priority in order to optimize a lower priority.

Example:

Never compromise security simply to reduce development time.

---

# 5. Guiding Principles

## Non-Negotiable Rules

The following rules shall never be violated.

• Never bypass RLS.
• Never expose PHI.
• Never hardcode secrets.
• Never trust client validation.
• Never call Supabase directly from Widgets.
• Never commit failing tests.
• Never merge with analyzer warnings.
• Never disable audit logging.
• Never skip code review.
• Never ignore synchronization conflicts.

## Patient First

Every technical decision should improve patient care or operational efficiency.

## Offline First

Internet connectivity must never be assumed.

Critical workflows shall continue functioning without internet.

## Security by Default

Every request is considered untrusted until validated.

## Single Source of Truth

Supabase PostgreSQL is the authoritative database.

PowerSync maintains synchronized local replicas.

Flutter never becomes the source of truth.

## Explicit over Implicit

Business rules shall never be hidden.

Permissions must be explicit.

Workflow transitions must be explicit.

Ownership must be explicit.

## Simplicity

Readable code is preferred over clever code.

Maintainability always wins.

---

# 6. AI Development Contract

Every AI assistant must behave as a senior software engineer.

AI shall:

- Understand repository structure before coding.
- Preserve architectural consistency.
- Reuse existing components.
- Avoid duplicate implementations.
- Respect project conventions.
- Produce production-ready code.
- Write maintainable code.
- Generate documentation.
- Generate tests where appropriate.
- Explain architectural decisions when necessary.

AI shall NOT:

- Invent business requirements.
- Ignore existing architecture.
- Introduce breaking changes without explanation.
- Circumvent security.
- Hardcode permissions.
- Bypass repositories.
- Access Supabase directly from widgets.
- Remove audit logging.
- Remove offline support.
- Remove RLS.
- Expose sensitive information.

Whenever uncertain, AI should request clarification rather than make assumptions.

---

# 7. Development Lifecycle

Every task follows the same lifecycle.

Understand

↓

Analyse

↓

Plan

↓

Validate Architecture

↓

Implement

↓

Test

↓

Review

↓

Document

↓

Complete

Skipping any step is prohibited.

---

# 8. Technology Stack

Frontend

- Flutter 3.35+
- Dart 3.9+
- Material 3
- Riverpod 3
- Flutter Hooks
- Go Router
- Freezed
- Json Serializable
- Drift
- PowerSync
- Flutter Secure Storage
- Cached Network Image
- Syncfusion Charts
- Camera
- Image Picker
- File Picker
- Flutter SVG

Backend

- Supabase
- PostgreSQL
- Storage
- Realtime
- Edge Functions
- Cron Jobs
- Database Triggers
- PowerSync Server

Infrastructure

- GitHub
- GitHub Actions
- Docker
- TypeScript
- SQL

---

# 9. Repository Standards

The repository represents a long-term enterprise system.

Every commit should improve the project.

Temporary code is forbidden.

Dead code is forbidden.

Unused dependencies are forbidden.

Duplicate logic is forbidden.

Magic numbers are forbidden.

Hardcoded strings are discouraged.

Business logic inside UI is forbidden.

Direct SQL inside widgets is forbidden.

Direct Supabase calls inside presentation code are forbidden.

---

# 10. Repository Structure

The repository shall always remain feature-first.

Example:

lib/

app/

core/

shared/

features/

authentication/

dashboard/

patients/

patient_details/

patient_registration/

treatments/

hospitals/

approvals/

reports/

notifications/

settings/

Each feature owns its:

- models
- controllers
- providers
- repositories
- datasource
- widgets
- screens
- routes
- validators

Cross-feature coupling should be minimized.

---

# 11. Protected Files

The following files are considered critical.

Changing them requires explicit architectural justification.

pubspec.yaml

analysis_options.yaml

AGENTS.md

README.md

supabase/config.toml

PowerSync configuration

database migrations

RLS policies

theme configuration

router configuration

Do not modify protected files unless required.

---

# 12. AI Task Execution Rules

Before generating code, every AI assistant shall perform the following mental checklist:

□ Read existing implementation.

□ Search for reusable components.

□ Identify feature ownership.

□ Validate repository structure.

□ Identify affected modules.

□ Check security implications.

□ Check offline implications.

□ Check synchronization implications.

□ Check RBAC implications.

□ Check RLS implications.

□ Check testing requirements.

□ Check documentation impact.

Only after completing this checklist should implementation begin.

---

# 13. Definition of Quality

Code is considered production quality only if it is:

Correct

Readable

Testable

Secure

Offline-compatible

Well documented

Reusable

Consistent

Scalable

Observable

Auditable

Maintainable

Performance optimized

Anything less is considered incomplete.

---

# 14. Enterprise Architecture Contract

Helpster Care SHALL implement **Clean Architecture** with a **Feature-First** organization and an **Offline-First** execution model.

Every feature must be independently maintainable.

Every layer has a single responsibility.

No layer may violate dependency rules.

---

# 15. Architecture Overview

```
                Presentation
                     │
                     ▼
               Controller Layer
                     │
                     ▼
              Repository Layer
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
 PowerSync Datasource     Supabase Datasource
         │                       │
         └───────────┬───────────┘
                     ▼
             PostgreSQL (Source of Truth)
```

Dependency direction must always point downward.

Reverse dependencies are prohibited.

---

# 16. Clean Architecture Rules

Presentation Layer

Responsibilities

- Render UI
- Receive user interaction
- Display state
- Navigate

Forbidden

- SQL
- HTTP
- Supabase queries
- Business rules
- Permission evaluation
- File uploads
- Database transactions

---

Controller Layer

Responsibilities

- Coordinate business operations
- Transform UI events
- Execute use cases
- Manage state transitions

Forbidden

- SQL
- Widget rendering
- Direct HTTP

Controllers should be thin.

---

Repository Layer

Responsibilities

- Abstract data sources
- Merge local and remote data
- Handle synchronization
- Handle caching
- Return domain models

Repositories are the only public interface to data.

---

Datasource Layer

Two datasource types exist.

Local

- Drift
- PowerSync

Remote

- Supabase
- Edge Functions
- Storage

Datasources never contain business rules.

---

Database Layer

Responsibilities

- Persistence
- RLS
- Triggers
- Constraints
- Relationships

Flutter must never bypass repositories to reach the database.

---

# 17. Feature-First Architecture

Every feature owns itself.

Example

lib/

features/

patients/

authentication/

dashboard/

approvals/

documents/

notifications/

reports/

settings/

No feature should depend directly on another feature.

Instead use

Repository

Service

Shared component

Event

or Interface.

---

# 18. Standard Feature Structure

Every feature SHALL follow this structure.

patients/

controllers/

datasources/

local/

remote/

models/

providers/

repositories/

routes/

screens/

services/

states/

validators/

widgets/

README.md

Every folder has a purpose.

Do not omit folders simply because they are temporarily unused.

---

# 19. Dependency Rules

Allowed

Presentation

↓

Controller

↓

Repository

↓

Datasource

↓

Supabase

Forbidden

Presentation

↓

Supabase

Presentation

↓

Database

Widget

↓

SQL

Widget

↓

Storage

Widget

↓

HTTP

---

# 20. Flutter Standards

Flutter is responsible only for presentation.

Flutter does NOT own business logic.

Flutter does NOT own permissions.

Flutter does NOT own synchronization.

Flutter does NOT own security.

Flutter renders state.

Nothing more.

---

# 21. Widget Design Rules

Widgets must be

Reusable

Composable

Small

Stateless whenever possible

Every widget should have one responsibility.

Avoid widgets exceeding 300 lines.

Prefer composition over inheritance.

Avoid deeply nested widget trees.

Extract reusable UI components early.

---

# 22. Screen Standards

Each screen should include

Loading State

Empty State

Offline State

Permission Denied State

Error State

Success State

Never show a blank screen.

Every async operation must provide user feedback.

---

# 23. Riverpod Contract

Riverpod 3 is the ONLY state management solution.

Forbidden

Provider package

Bloc

Cubit

MobX

Redux

GetX

Stateful global singletons

---

# 24. Riverpod Folder Structure

Each feature

providers/

controllers/

states/

Repositories must NOT expose Riverpod.

Repositories remain framework independent.

---

# 25. Recommended Riverpod Pattern

UI

↓

Notifier

↓

Repository

↓

Datasource

↓

PowerSync

↓

Supabase

Controllers coordinate.

Repositories retrieve.

Datasources communicate.

Widgets display.

---

# 26. State Design

Every feature should expose immutable state.

Example

PatientState

contains

patients

loading

saving

syncing

error

selectedPatient

filter

lastUpdated

State objects should never contain UI widgets.

---

# 27. Async State Rules

Every async request should expose

Loading

Success

Error

Refreshing

Offline

Conflict

PermissionDenied

SynchronizationPending

Do not hide background synchronization.

Users should understand application status.

---

# 28. Go Router Contract

Navigation uses Go Router exclusively.

Forbidden

Navigator.push()

Navigator.popUntil()

Anonymous routes

Magic route strings

---

# 29. Route Naming

Every route has a constant.

Example

DashboardRoute

PatientsRoute

PatientDetailsRoute

HospitalRoute

ReportsRoute

SettingsRoute

Avoid hardcoded paths.

---

# 30. Navigation Rules

Navigation should never contain business logic.

Navigation decisions belong inside controllers.

Authentication redirects belong inside router guards.

Permission redirects belong inside router guards.

---

# 31. Shared Components

Reusable widgets belong inside

shared/widgets

Examples

LoadingIndicator

PermissionGate

OfflineBanner

AppCard

SearchBar

PrimaryButton

Avatar

PatientTile

HospitalTile

TimelineCard

Avoid duplicate widgets.

---

# 32. Theme Contract

One theme.

One design language.

Material 3 only.

Support

Light Mode

Dark Mode

Dynamic Color (future)

High Contrast (future)

Hardcoded colors are prohibited.

All colors come from ThemeExtension.

---

# 33. Design Tokens

Never hardcode

Padding

Radius

Typography

Animation duration

Elevation

Spacing

Instead use centralized design tokens.

Example

AppSpacing.md

AppRadius.lg

AppAnimation.medium

---

# 34. Responsive Design

Support

Phone

Tablet

Desktop (future)

Avoid fixed widths.

Prefer flexible layouts.

No screen should assume a single device size.

---

# 35. Accessibility

Every screen shall support

Screen readers

Large text

Minimum 48dp touch targets

Contrast compliance

Keyboard navigation (Web/Desktop)

Accessibility is mandatory.

---

# 36. Architecture Validation Checklist

Before merging a feature, verify:

□ Widgets contain no business logic.

□ Controllers are thin.

□ Repositories abstract all data access.

□ No direct Supabase calls from UI.

□ Feature structure is respected.

□ Riverpod patterns are followed.

□ Navigation uses Go Router only.

□ Shared widgets are reused.

□ Theme tokens are respected.

□ Architecture layers remain independent.

Failure of any checklist item blocks the merge.

---

# 37. Backend Engineering Contract

The backend is the security and business logic backbone of Helpster Care.

Flutter is **not** trusted to enforce business rules.

Every critical operation shall be validated by PostgreSQL, Supabase Row-Level Security (RLS), and Edge Functions.

Supabase PostgreSQL is the **single source of truth**.

---

# 38. Backend Architecture

```
                    Flutter
                       │
              Riverpod Controller
                       │
                 Repository Layer
                       │
      ┌────────────────┴────────────────┐
      ▼                                 ▼
 PowerSync Local DB              Supabase Edge Function
      │                                 │
      └────────────────┬────────────────┘
                       ▼
               PostgreSQL Database
                       │
             Row Level Security (RLS)
                       │
               Storage / Realtime
```

No Flutter widget may communicate directly with PostgreSQL.

---

# 39. Supabase Contract

Supabase is responsible for:

- Authentication
- Authorization
- PostgreSQL
- Storage
- Edge Functions
- Realtime
- Database Triggers
- Scheduled Jobs

Never use Supabase as merely a database.

Its complete platform capabilities should be utilized.

---

# 40. PostgreSQL Standards

Every table must follow these conventions.

Mandatory columns

```sql
id UUID PRIMARY KEY

created_at TIMESTAMPTZ

updated_at TIMESTAMPTZ

created_by UUID

updated_by UUID
```

Soft delete tables additionally include

```sql
deleted_at TIMESTAMPTZ

deleted_by UUID

is_deleted BOOLEAN
```

Never permanently delete patient data unless explicitly approved.

---

# 41. Naming Standards

Tables

snake_case plural

Examples

patients

patient_documents

patient_notes

audit_logs

Hospitals

hospital_departments

hospital_beds

Columns

snake_case

Functions

snake_case()

Views

vw_

Materialized Views

mv_

Indexes

idx_

Constraints

fk_

pk_

uq_

Triggers

trg_

Policies

rls_

Maintain consistent naming across the entire database.

---

# 42. Migration Policy

Every database change must be implemented through migrations.

Never modify production tables manually.

Migration rules

One logical change per migration

Always reversible when possible

Never edit an applied migration

Always include comments

Always test against staging

Migration filenames should be chronological.

---

# 43. Database Constraints

Use constraints instead of application logic whenever possible.

Examples

NOT NULL

CHECK

UNIQUE

FOREIGN KEY

ENUM

Generated Columns

Database integrity always takes precedence over client validation.

---

# 44. Lookup Tables

Avoid hardcoded values.

Instead create lookup tables.

Examples

roles

permissions

patient_status

approval_status

treatment_type

document_type

hospital_type

notification_type

Using lookup tables improves maintainability.

---

# 45. Transaction Rules

Business operations affecting multiple tables must execute inside transactions.

Examples

Patient registration

Hospital assignment

Approval workflow

Treatment creation

Discharge

Never leave partial writes.

Either everything succeeds or nothing changes.

---

# 46. Edge Function Contract

Edge Functions handle privileged operations.

Examples

createPatient()

approvePatient()

rejectPatient()

assignHospital()

assignDoctor()

assignVolunteer()

createOTSchedule()

uploadMedicalDocument()

exportPatientPDF()

generateDashboard()

sendPushNotification()

compressImages()

dailyAnalytics()

Never perform privileged business logic directly from Flutter.

---

# 47. Edge Function Standards

Every Edge Function must

Authenticate user

Validate JWT

Verify permissions

Validate inputs

Execute business logic

Write audit log

Return typed response

Never trust client input.

Always revalidate.

---

# 48. API Response Standard

Every Edge Function returns

```json
{
  "success": true,
  "data": {},
  "message": "",
  "error": null
}
```

On failure

```json
{
  "success": false,
  "data": null,
  "message": "Validation failed",
  "error": {
    "code": "PATIENT_NOT_FOUND"
  }
}
```

Never expose internal SQL errors.

---

# 49. Supabase Storage Contract

Storage buckets

patients

avatars

hospital_documents

reports

exports

system

Bucket privacy

Patient documents

Private

Reports

Private

Exports

Temporary Signed URLs

Avatars

Authenticated

Never use public buckets for medical records.

---

# 50. Storage Folder Structure

```
patients/

PAT000001/

prescriptions/

lab/

ct/

mri/

xray/

bills/

consent/

discharge/
```

Keep filenames immutable where possible.

Prefer UUID filenames over user-generated names.

---

# 51. File Upload Standards

Before upload

Validate MIME type

Validate file size

Compress images

Generate thumbnails

Calculate checksum

Virus scan (future)

Never trust file extensions.

---

# 52. Realtime Contract

Realtime should be used only where immediate collaboration adds value.

Examples

Dashboard counters

Patient assignment

Treatment updates

Notifications

Approval workflow

Chat (future)

Avoid excessive subscriptions.

Subscribe only to required channels.

---

# 53. Background Jobs

Scheduled jobs

Daily analytics

Dashboard cache refresh

Notification cleanup

Expired signed URL cleanup

Audit archival

Document indexing

Nightly consistency checks

Heavy processing belongs in scheduled jobs.

---

# 54. PowerSync Contract

PowerSync is mandatory.

Every critical workflow must support offline operation.

PowerSync maintains local replicas.

Supabase remains the source of truth.

Flutter communicates primarily with the local database.

Synchronization occurs automatically.

---

# 55. Synchronization Rules

Synchronize

Patients

Treatments

Hospitals

Assignments

Notifications

Timeline

Document metadata

Audit references

Do not automatically synchronize large binary files.

Download them on demand.

---

# 56. Conflict Resolution

When synchronization conflicts occur

Newest timestamp is NOT always correct.

Preferred strategy

Business-specific merge

Otherwise

Server wins

Never silently discard user data.

Record every conflict.

Notify users when manual resolution is required.

---

# 57. Offline Queue

Operations performed offline shall be queued.

Examples

Create patient

Update treatment

Upload notes

Upload documents

Assignments

Approvals (if permitted)

Queue must survive app restarts.

Automatic retry required.

---

# 58. Dashboard Cache

Dashboard statistics should not execute expensive SQL repeatedly.

Maintain materialized views or cache tables.

Examples

Today's admissions

Active treatments

Pending approvals

Hospital occupancy

Monthly registrations

Refresh periodically using scheduled jobs.

---

# 59. Audit Logging Contract

Every write operation creates an immutable audit entry.

Audit fields

User

Timestamp

Action

Entity

Entity ID

Old Values

New Values

IP Address

Device ID

Edge Function

Audit logs are append-only.

Never edit audit history.

---

# 60. Activity Timeline

Patient timeline records

Registration

Document upload

Approval

Hospital assignment

Admission

Treatment update

Surgery

Discharge

Follow-up

Closure

Timeline events are separate from audit logs.

Audit logs are for compliance.

Timelines are for operational visibility.

---

# 61. Observability

Every backend service should generate

Structured logs

Metrics

Error reports

Performance timings

Synchronization metrics

Storage usage

Failed uploads

Queue health

System observability is mandatory.

---

# 62. Backend Validation Checklist

Before deployment verify

□ Migration tested

□ RLS enabled

□ Policies validated

□ Edge Functions tested

□ Storage secured

□ Audit logging enabled

□ Background jobs configured

□ PowerSync synchronization verified

□ Conflict resolution tested

□ Realtime subscriptions optimized

Deployment must be blocked until every item passes.

---

# 63. Enterprise Security Contract

Security is the foundation of Helpster Care.

Every layer of the application shall assume that the client is untrusted.

Authorization must be enforced at multiple layers:

```
Flutter UI
      ↓
Controller Validation
      ↓
Repository Validation
      ↓
Edge Function Validation
      ↓
Supabase Row-Level Security
      ↓
PostgreSQL Constraints
```

If one layer fails, the remaining layers must continue protecting the system.

No single security layer shall be considered sufficient.

---

# 64. Security Principles

The application follows a **Defense in Depth** strategy.

Principles

- Least Privilege
- Zero Trust
- Secure by Default
- Explicit Authorization
- Immutable Audit Trails
- Privacy by Design
- Fail Secure
- Separation of Duties

Every design decision must strengthen—not weaken—these principles.

---

# 65. Authorization Model

Helpster Care uses a hybrid authorization model.

```
RBAC
(Role-Based Access Control)

        +

ReBAC
(Resource-Based Access Control)

        +

Supabase RLS

        +

JWT Claims

        +

Business Rules
```

Role alone is **never** enough to grant access.

---

# 66. Role Hierarchy

```
Super Admin

↓

Admin

↓

Field Officer / Case Manager

↓

Volunteer

↓

Doctor

↓

Read-only Auditor
```

Hierarchy represents responsibility.

It does **not** automatically grant permissions.

Permissions are assigned explicitly.

---

# 67. Permission Model

Permissions follow the format

```
module.action
```

Examples

```
dashboard.view

patient.create

patient.read

patient.update

patient.archive

patient.approve

patient.reject

hospital.assign

hospital.view

document.upload

document.delete

report.export

notification.send

user.manage

settings.manage
```

Never hardcode permissions.

Permissions belong in the database.

---

# 68. RBAC Database Design

Required tables

```
users

roles

permissions

role_permissions

user_roles
```

Relationships

```
User

↓

Role

↓

Permissions
```

A user may have multiple roles.

Roles may share permissions.

---

# 69. ReBAC (Resource-Based Access Control)

Roles determine **what** a user can do.

ReBAC determines **which records** they may access.

Resources include

Hospitals

Patients

Documents

Treatments

Approvals

Notifications

Reports

---

# 70. Hospital Assignment Model

Required table

```
user_hospital_assignments
```

Example

```
User A

↓

Hospital A

Hospital B
```

Rules

Doctors access assigned hospitals only.

Case Managers access assigned hospitals only.

Volunteers access assigned hospitals only.

Admins access assigned hospitals.

Super Admin accesses all hospitals.

---

# 71. Patient Assignment Model

Required table

```
patient_assignments
```

Assignment types

Doctor

Volunteer

Case Manager

Coordinator

Multiple users may be assigned.

Assignments are auditable.

Assignments may change over time.

Historical assignments must be preserved.

---

# 72. Patient Visibility Rules

Example

Doctor

↓

Assigned Patients

Volunteer

↓

Assigned Patients

Case Manager

↓

Assigned Patients

Admin

↓

Patients within assigned hospitals

Super Admin

↓

All Patients

Auditor

↓

Read-only according to assigned scope

---

# 73. Permission Resolution

Authorization must evaluate

```
User

↓

Active Roles

↓

Permissions

↓

Hospital Assignment

↓

Patient Assignment

↓

Business Rule

↓

RLS Policy

↓

Allow / Deny
```

Every step must succeed.

---

# 74. JWT Contract

JWT contains only lightweight identity information.

Recommended claims

```
sub

email

role_version

session_id
```

Do NOT place permissions inside JWT.

Permissions should always be loaded from the database.

This prevents stale authorization.

---

# 75. Row-Level Security (RLS)

RLS is mandatory.

Every business table shall have

SELECT

INSERT

UPDATE

DELETE

Policies.

Never disable RLS.

Even for administrators.

---

# 76. RLS Design Principles

Policies should be

Small

Composable

Readable

Reusable

Avoid enormous SQL expressions.

Instead use helper functions.

Example

```
has_permission()

can_access_hospital()

can_access_patient()
```

---

# 77. Patient RLS Example

Read

```
has_permission(patient.read)

AND

can_access_patient()
```

Update

```
has_permission(patient.update)

AND

can_access_patient()
```

Delete

```
patient.delete

AND

Super Admin only
```

---

# 78. Hospital RLS Example

View hospital

```
Hospital Assignment

AND

hospital.view
```

Edit hospital

```
hospital.update

AND

Admin
```

Delete hospital

```
Super Admin
```

---

# 79. Storage Security

Medical documents are private.

Storage access must require

Authentication

Permission

Patient Assignment

Hospital Assignment

Signed URL

Never expose permanent URLs.

Never use public buckets for PHI.

---

# 80. Protected Health Information (PHI)

PHI includes

Patient Name

Address

Phone Number

National ID

Passport

Medical History

Diagnosis

Treatment

Lab Reports

Radiology

Bills

Insurance

Photos

Consent Forms

PHI must never appear

Application logs

Crash reports

Analytics

Console output

Public URLs

---

# 81. Encryption Policy

Sensitive data shall be protected

In Transit

TLS

At Rest

Supabase Encryption

Secrets

Environment Variables

Flutter Secure Storage

Never commit secrets to Git.

Never hardcode API keys.

---

# 82. Authentication Rules

Authentication

Supabase Auth

Optional

Biometric Re-authentication

Session timeout required.

Inactive sessions should expire automatically.

Support

Forgot Password

Password Reset

Email Verification

Future

MFA

---

# 83. Audit Security

Audit logs are immutable.

Record

Who

What

When

Where

Previous Value

New Value

Device

IP

Edge Function

Never delete audit history.

---

# 84. Approval Workflow Security

Only authorized users may transition workflow states.

Example

```
Draft

↓

Documents Uploaded

↓

Pending Review

↓

Medical Review

↓

Approved

↓

Hospital Assigned

↓

Admission

↓

Treatment

↓

Discharged

↓

Closed
```

Workflow transitions must be validated by Edge Functions.

Flutter must never decide workflow validity.

---

# 85. Security Review Checklist

Before merge

□ RLS enabled

□ Permissions validated

□ Edge Function authorization tested

□ Storage secured

□ Signed URLs verified

□ PHI protected

□ Audit logging enabled

□ Secrets removed

□ Hospital assignment enforced

□ Patient assignment enforced

□ JWT validated

□ Offline permissions respected

□ Security documentation updated

Failure of any item blocks deployment.

---

# 86. Security Commandments

Every contributor—human or AI—shall obey these rules.

1. Never bypass Supabase RLS.
2. Never hardcode permissions.
3. Never trust the client.
4. Never expose PHI.
5. Never store secrets in source code.
6. Never weaken auditability.
7. Never disable authorization checks.
8. Never use public storage for patient documents.
9. Never perform privileged operations without Edge Functions.
10. Never trade security for convenience.

These commandments are non-negotiable.

---

# 87. Healthcare Domain Architecture

The Healthcare Domain defines the core business model of Helpster Care.

Every feature, API, database table, Edge Function, and workflow shall conform to this domain model.

The domain model is the canonical representation of business entities.

No duplicate domain models shall exist.

---

# 88. Core Domain Modules

The application consists of the following core modules.

```
Authentication

Dashboard

Patients

Patient Timeline

Treatments

Hospitals

Doctors

Approvals

Documents

Notifications

Reports

Audit

Settings

Analytics
```

Future modules shall integrate with—not replace—the existing domain.

---

# 89. Patient Lifecycle

Every patient progresses through a defined lifecycle.

```
Registration

↓

Document Collection

↓

Case Review

↓

Medical Review

↓

Approval

↓

Hospital Assignment

↓

Admission

↓

Treatment

↓

Follow-up

↓

Discharge

↓

Case Closure
```

No workflow may skip mandatory stages.

Workflow transitions are controlled exclusively by Edge Functions.

---

# 90. Patient Entity

The Patient is the central entity of the platform.

A patient record represents a single beneficiary.

Patient records are immutable in identity.

Example fields

```
Patient ID

National ID

Full Name

Date of Birth

Gender

Blood Group

Religion

Address

Guardian

Emergency Contact

Photo

Current Status

Assigned Hospital

Assigned Doctor

Assigned Case Manager

Assigned Volunteer

Registration Date
```

Patient IDs shall never be reused.

---

# 91. Patient Identifier Standard

Patient IDs shall be human-readable.

Recommended format

```
PAT-2026-000001
```

Rules

Sequential

Immutable

Globally unique

Never recycled

Generated only by backend.

Flutter must never generate Patient IDs.

---

# 92. Patient Timeline

Every patient maintains a chronological timeline.

Timeline events

```
Registered

Document Uploaded

Medical Review

Approval

Hospital Assigned

Admission

Treatment Started

Surgery Scheduled

Surgery Completed

Discharge

Follow-up

Case Closed
```

Timeline entries are append-only.

Timeline is operational history.

Audit log is compliance history.

Never combine them.

---

# 93. Case Management

Each patient belongs to exactly one active case.

A case represents the complete medical assistance process.

Case fields

```
Case Number

Patient

Current Status

Priority

Assigned Case Manager

Assigned Volunteer

Assigned Hospital

Approval Status

Funding Status

Treatment Status
```

A patient may have multiple historical cases if organizational policy permits.

---

# 94. Hospital Domain

Hospitals are partner organizations.

Hospitals contain

```
Departments

Doctors

Wards

Beds

Operating Theatres

Statistics

Coordinators
```

Hospitals are organizational resources.

Patient access is filtered by hospital assignment.

---

# 95. Department Domain

Departments organize medical specialties.

Examples

```
General Medicine

General Surgery

Orthopedics

Cardiology

Neurology

Nephrology

Oncology

Ophthalmology

ENT

Pediatrics
```

Departments belong to hospitals.

---

# 96. Bed Management

Beds represent admission capacity.

Each bed contains

```
Ward

Bed Number

Availability

Patient

Department

Status

Last Updated
```

Status

```
Available

Occupied

Reserved

Cleaning

Maintenance
```

---

# 97. Treatment Architecture

Treatment is an abstract parent.

Concrete implementations

```
Conservative Treatment

Surgical Treatment
```

Shared information

```
Diagnosis

Consultant

Hospital

Admission Date

Progress Notes

Expected Outcome

Status
```

Each subtype extends the base model.

---

# 98. Conservative Treatment

Contains

```
Admission

Ward

Bed

Consultant

Diagnosis

Medication

Investigations

Daily Progress

Expected Discharge

Discharge Summary
```

Progress updates are chronological.

---

# 99. Surgical Treatment

Contains

```
Diagnosis

Procedure

OT Schedule

Surgeon

Assistant Surgeon

Anaesthetist

Implants

Operation Notes

ICU Transfer

Post-operative Notes

Discharge Summary
```

Every surgery belongs to one patient.

---

# 100. OT Schedule

Operating Theatre scheduling includes

```
Hospital

OT Room

Date

Time

Procedure

Primary Surgeon

Assistant Surgeon

Anaesthetist

Patient

Status
```

Status

```
Scheduled

Confirmed

In Progress

Completed

Cancelled
```

Double booking must never occur.

---

# 101. Medical Documents

Document categories

```
Prescription

Referral

Lab Report

CT Scan

MRI

Ultrasound

X-Ray

Bill

Consent Form

Discharge Summary

Clinical Photograph
```

Each document includes metadata.

Large files remain in Storage.

Only metadata synchronizes through PowerSync.

---

# 102. OCR Pipeline

Future AI processing

```
Upload

↓

Compression

↓

OCR

↓

Medical Entity Extraction

↓

Manual Verification

↓

Patient Record Update
```

AI suggestions never modify records automatically.

Human verification is mandatory.

---

# 103. Follow-up Module

Follow-ups include

```
Date

Hospital

Doctor

Instructions

Medication

Review Notes

Outcome

Next Visit
```

Overdue follow-ups should generate notifications.

---

# 104. Approval Workflow

Approval stages

```
Draft

↓

Pending Documents

↓

Submitted

↓

Medical Review

↓

Approved

↓

Rejected
```

Only authorized personnel may transition approval states.

Every transition generates

Timeline Event

Notification

Audit Entry

---

# 105. Notification Domain

Notification categories

```
Approval

Reminder

Critical Alert

Hospital Assignment

Follow-up

Discharge

Document Missing

System
```

Notifications support

Realtime

Push

Email

Future SMS

Users receive only notifications they are authorized to view.

---

# 106. Reporting Domain

Standard reports

```
Patient Summary

Hospital Summary

Treatment Summary

Approval Statistics

Monthly Registration

Discharge Report

Disease Statistics

Expense Report

Donor Report
```

Reports shall respect RBAC and RLS.

Export formats

```
PDF

Excel

CSV
```

---

# 107. Dashboard Domain

Dashboard widgets include

```
Total Patients

Today's Registrations

Pending Approvals

Current Admissions

Conservative Treatments

Surgical Treatments

Hospital Occupancy

Critical Patients

Upcoming OT

Follow-ups Due

Notifications
```

Widgets should load independently.

Failure of one widget must not affect others.

---

# 108. Search Architecture

Global search supports

```
Patient ID

National ID

Patient Name

Guardian

Phone Number

Hospital

Doctor

Case Number
```

Search results shall respect authorization.

Users must never discover inaccessible records.

---

# 109. Analytics

Analytics include

```
Registration Trends

Disease Trends

Hospital Utilization

Treatment Outcomes

Approval Time

Average Length of Stay

Surgical Success Rate

Follow-up Compliance
```

Analytics must use aggregated data.

Avoid expensive live queries where possible.

---

# 110. AI Roadmap

Future AI modules

```
Patient Summary

Medical OCR

Clinical Timeline Summary

Diagnosis Assistance

Follow-up Prediction

Treatment Recommendation Support

Duplicate Patient Detection

Fraud Detection

Donor Recommendation

Operational Forecasting
```

AI serves as decision support only.

Clinical responsibility remains with qualified healthcare professionals.

---

# 111. Domain Design Principles

Every business entity shall satisfy

Single Responsibility

Clear Ownership

Immutable Identity

Auditable Changes

Offline Compatibility

Role-based Visibility

Hospital Isolation

Patient Assignment Enforcement

Entities should be reusable across future modules.

---

# 112. Healthcare Domain Checklist

Before implementing any healthcare feature verify

□ Patient identity immutable

□ Timeline updated

□ Audit generated

□ Notifications generated

□ Offline supported

□ RLS validated

□ Hospital assignment respected

□ Patient assignment respected

□ Edge Function implemented

□ Documentation updated

No healthcare feature is complete until every item passes.

---

# 113. Flutter Enterprise Development Standards

Flutter is the presentation framework for Helpster Care.

Its responsibility is to provide a fast, responsive, accessible, and maintainable user interface.

Flutter shall never become the location for business rules, authorization logic, or direct database communication.

---

# 114. UI Design Philosophy

Every interface shall follow these principles.

```
Simple

Consistent

Accessible

Responsive

Minimal

Readable

Fast

Offline Friendly
```

The interface must reduce cognitive load for healthcare workers.

Every screen should support quick decision making.

---

# 115. Material 3 Design Contract

Helpster Care shall use Material 3 exclusively.

Allowed

Material 3 Components

Theme Extensions

Dynamic Color (Future)

Adaptive Layouts

Material Icons

Forbidden

Mixing Material 2

Random third-party UI libraries

Inconsistent component styling

Hardcoded colors

---

# 116. Helpster Care Design Language

Visual identity should communicate

Trust

Professionalism

Healthcare

Clarity

Calmness

Primary characteristics

Rounded corners

Large cards

Comfortable spacing

Soft shadows

Minimal glass effects

High readability

Avoid decorative effects that reduce usability.

---

# 117. Theme Architecture

Centralized theme structure

```
theme/

app_theme.dart

light_theme.dart

dark_theme.dart

color_scheme.dart

typography.dart

spacing.dart

radius.dart

animations.dart

theme_extensions.dart
```

Widgets must consume theme values only.

Never hardcode visual properties.

---

# 118. Color Standards

Use semantic colors.

Examples

```
Primary

Secondary

Surface

Background

Success

Warning

Error

Critical

Info
```

Never reference colors by their visual appearance.

Use

Good

```
Theme.of(context).colorScheme.error
```

Avoid

```
Colors.red
```

---

# 119. Typography Standards

Typography hierarchy

```
Display

Headline

Title

Body

Label
```

Rules

No hardcoded font sizes.

Use Material typography scale.

Maintain consistent line height.

Prefer readability over density.

---

# 120. Spacing System

Spacing tokens

```
xs

sm

md

lg

xl

2xl
```

Never use magic numbers.

Good

```
AppSpacing.md
```

Bad

```
padding: EdgeInsets.all(13)
```

---

# 121. Widget Design Rules

Widgets should be

Small

Reusable

Composable

Testable

Focused

Preferred widget size

< 300 lines

Extract repeated UI immediately.

Avoid monolithic screens.

---

# 122. Screen Composition

Every screen consists of

```
App Bar

Body

Floating Action

Bottom Navigation (if required)

Loading Overlay

Offline Banner

Error Handler
```

Every screen shall support scrolling.

Avoid fixed layouts.

---

# 123. Dashboard Standards

Dashboard cards should be independent.

Example widgets

```
Total Patients

Today's Admissions

Pending Approvals

Current Treatments

Upcoming OT

Critical Patients

Notifications

Recent Activity

Quick Actions
```

Each widget loads separately.

Failure of one widget must never affect others.

---

# 124. Card Design

Cards should contain

```
Title

Primary Metric

Secondary Information

Status Indicator

Action (Optional)
```

Cards should not exceed necessary complexity.

Avoid placing unrelated information together.

---

# 125. Form Standards

Large forms shall be divided into logical sections.

Patient Registration

```
Personal Information

Medical Information

Guardian

Financial

Hospital

Treatment

Emergency Contact

Documents
```

Never present excessively long scrolling forms.

Support autosave where appropriate.

---

# 126. Validation Rules

Validation occurs

Client

↓

Controller

↓

Backend

↓

Database

Flutter validation improves UX.

Backend validation guarantees correctness.

Both are required.

---

# 127. Input Components

Preferred components

TextField

Dropdown

Searchable Dropdown

Date Picker

Time Picker

Autocomplete

Radio Group

Checkbox

File Picker

Camera Capture

Never overload a single input with multiple responsibilities.

---

# 128. Data Tables

Large datasets should use

Pagination

Sorting

Filtering

Search

Sticky Headers

Selectable Rows

Avoid rendering thousands of rows simultaneously.

---

# 129. Search Experience

Every search should support

Incremental search

Clear button

Empty state

No results state

Loading state

Offline state

Search should debounce user input.

---

# 130. Timeline Components

Timeline entries contain

```
Timestamp

Event

Description

Responsible User

Hospital

Status

Attachments
```

Timeline is chronological.

Newest entries appear first.

---

# 131. Status Indicators

Statuses should be consistent.

Examples

```
Draft

Pending

Approved

Rejected

Admitted

Under Treatment

Discharged

Closed
```

Status appearance must be centralized.

Avoid custom colors for individual screens.

---

# 132. Empty States

Every feature requires meaningful empty states.

Example

```
No Patients Found

Register your first patient.

[ Register Patient ]
```

Do not display blank pages.

---

# 133. Loading States

Loading should use

Skeletons

Shimmer

Progress Indicators

Avoid indefinite spinners.

Users should understand loading progress.

---

# 134. Error States

Errors must include

Clear explanation

Suggested action

Retry button

Support contact (if appropriate)

Avoid exposing technical exceptions.

---

# 135. Offline States

Offline indicators should remain visible.

Examples

```
Offline

Sync Pending

Synchronizing

Conflict Detected
```

Users should always know synchronization status.

---

# 136. Notification UX

Notification priorities

```
Critical

Warning

Information

Success
```

Critical alerts require immediate visibility.

Avoid excessive notification frequency.

---

# 137. Accessibility

Support

Screen Readers

Large Text

High Contrast

48dp Touch Targets

Keyboard Navigation

Focus Indicators

Accessibility is mandatory.

Not optional.

---

# 138. Responsive Layout

Supported

Phone

Tablet

Desktop (Future)

Avoid

Fixed widths

Absolute positioning

Hardcoded dimensions

Prefer adaptive layouts.

---

# 139. Animation Standards

Animations should communicate state.

Recommended

Fade

Scale

Slide

Hero

Avoid

Long animations

Decorative motion

Animation duration

150–300 ms

Respect reduced-motion accessibility settings.

---

# 140. Performance Standards

Optimize

Const widgets

Lazy loading

Pagination

Image caching

Memoization

Efficient rebuilds

Avoid rebuilding entire screens for small state changes.

---

# 141. Image Standards

Patient photos

Compressed before upload

Cached locally

Lazy loaded

Documents

Thumbnail generated

Downloaded on demand

Never synchronize large binary files automatically.

---

# 142. Internationalization

Architecture must support

English

Bangla

Future languages

Never concatenate localized strings.

Use localization resources.

---

# 143. UI Testing

Every reusable widget should include

Widget tests

Golden tests (where appropriate)

Accessibility verification

Responsive verification

Visual regressions should be detected automatically.

---

# 144. Flutter Development Checklist

Before merging any Flutter feature verify

□ Material 3 compliant

□ Theme tokens used

□ No hardcoded colors

□ Responsive

□ Accessible

□ Loading state implemented

□ Error state implemented

□ Empty state implemented

□ Offline state implemented

□ Widget tests written

□ Performance reviewed

□ Reusable components extracted

□ Documentation updated

Deployment should be blocked until every item passes.

---

# 145. Enterprise Coding Standards

Every line of code written for Helpster Care shall prioritize readability, maintainability, security, and correctness.

Code is expected to remain maintainable for at least ten years.

Optimize for future developers—not current convenience.

---

# 146. General Coding Principles

Follow these principles.

```
Readability

Consistency

Maintainability

Testability

Reusability

Simplicity

Predictability

Explicitness
```

If two solutions produce the same result, prefer the simpler one.

---

# 147. SOLID Principles

Every feature should follow SOLID.

Single Responsibility

Open / Closed

Liskov Substitution

Interface Segregation

Dependency Inversion

Violation of SOLID requires architectural justification.

---

# 148. DRY Principle

Avoid duplicated logic.

If identical logic appears more than twice, extract it.

Possible extraction targets

Shared Widget

Utility

Extension

Repository

Service

Helper

Mixin (rare)

Do not over-engineer abstractions.

---

# 149. KISS Principle

Keep It Simple.

Avoid

Deep inheritance

Reflection

Unnecessary generics

Complex state trees

Hidden behavior

Readable code is preferred over clever code.

---

# 150. YAGNI Principle

You Aren't Gonna Need It.

Do not implement speculative features.

Future extensibility is good.

Unused complexity is not.

---

# 151. Dart Standards

Always enable

```
analysis_options.yaml
```

Treat warnings as errors.

Use

```
final
const
late
required
```

appropriately.

Prefer immutable objects.

Avoid mutable global state.

---

# 152. File Naming

Use

snake_case.dart

Examples

```
patient_repository.dart

patient_controller.dart

hospital_screen.dart

dashboard_provider.dart
```

Never use spaces.

Never use PascalCase filenames.

---

# 153. Class Naming

Classes

PascalCase

Examples

```
Patient

PatientRepository

PatientController

DashboardScreen

ApprovalState
```

---

# 154. Variable Naming

Variables

camelCase

Examples

```
patient

patientId

selectedHospital

assignedDoctor

dashboardStatistics
```

Avoid abbreviations.

Bad

```
pt

usr

obj
```

---

# 155. Constant Naming

Compile-time constants

camelCase

Example

```
defaultAnimationDuration

maxUploadSize

defaultPageSize
```

Avoid ALL_CAPS.

---

# 156. Method Standards

Method names should begin with verbs.

Examples

```
loadPatients()

approvePatient()

registerPatient()

assignHospital()

calculateStatistics()

syncOfflineQueue()
```

Methods should describe exactly one action.

---

# 157. Method Size

Recommended

20–40 lines

Maximum

80 lines

Long methods indicate hidden responsibilities.

Refactor early.

---

# 158. Class Size

Recommended

300 lines

Maximum

500 lines

If a class exceeds the limit,

consider extraction.

---

# 159. Widget Size

Preferred

<300 lines

Extract

Dialogs

Cards

Forms

Sections

Tables

Timeline Widgets

Do not build entire screens inside one widget.

---

# 160. Comment Standards

Comment

WHY

not

WHAT.

Bad

```dart
// Increment i
i++;
```

Good

```dart
// Retry after temporary synchronization failure.
```

Self-documenting code is preferred.

---

# 161. Documentation Standards

Public classes require

Purpose

Responsibilities

Usage

Examples (where appropriate)

Public methods require

Parameters

Returns

Throws

Side Effects

---

# 162. Error Handling

Never ignore exceptions.

Bad

```dart
catch (_) {}
```

Good

Handle

Log

Recover

Notify

Every failure should be intentional.

---

# 163. Logging Standards

Use structured logging.

Include

Timestamp

Feature

Operation

Duration

Result

Correlation ID

Never log

Passwords

Tokens

PHI

Personal Identifiers

Medical Records

---

# 164. Exception Types

Create domain-specific exceptions.

Examples

```
PatientNotFoundException

HospitalNotAssignedException

PermissionDeniedException

SynchronizationException

ValidationException

DocumentUploadException
```

Avoid generic Exception.

---

# 165. Validation Strategy

Validation occurs

Client

↓

Controller

↓

Repository

↓

Edge Function

↓

Database

Each layer validates its own responsibility.

---

# 166. Configuration

Configuration belongs in

```
config/

environment/

constants/
```

Never scatter configuration throughout the project.

---

# 167. Environment Variables

Secrets belong only in

```
.env

Supabase Secrets

GitHub Secrets
```

Never commit

API Keys

JWT Secrets

Database Passwords

Service Accounts

---

# 168. Feature Flags

Future functionality should use feature flags.

Examples

```
OCR

AI Summary

Telemedicine

Donor Portal

Medicine Inventory
```

Feature flags should be server-controlled.

---

# 169. Git Branch Strategy

```
main

develop

feature/*

bugfix/*

hotfix/*

release/*
```

Never commit directly to

main.

---

# 170. Commit Standards

Commit messages

```
feat:

fix:

refactor:

docs:

test:

perf:

security:

build:

ci:

chore:
```

Example

```
feat(patient):
Implement patient assignment workflow
```

---

# 171. Pull Request Requirements

Every PR shall include

Purpose

Screenshots (if UI)

Testing Notes

Migration Notes

Security Impact

Breaking Changes

Checklist

No undocumented PRs.

---

# 172. Code Review Standards

Review focuses on

Architecture

Correctness

Security

Performance

Accessibility

Maintainability

Offline Support

Synchronization

Naming

Documentation

Reviews are collaborative—not personal.

---

# 173. Definition of Done

A task is complete only when

□ Code implemented

□ Architecture respected

□ Tests passing

□ RLS verified

□ Offline verified

□ Documentation updated

□ No analyzer warnings

□ No TODOs

□ Code reviewed

□ Approved

Anything less is incomplete.

---

# 174. Testing Strategy

Testing Pyramid

```
Unit Tests

↓

Widget Tests

↓

Integration Tests

↓

End-to-End Tests
```

Favor many unit tests.

Use integration tests for workflows.

---

# 175. Unit Testing Rules

Repositories

Controllers

Validators

Utilities

Business Rules

must have unit tests.

Coverage target

Minimum 80%.

Critical modules

95%+.

---

# 176. Integration Testing

Required workflows

Authentication

Patient Registration

Hospital Assignment

Approval Workflow

Treatment Updates

Document Upload

Offline Sync

Discharge

End-to-end business processes must be validated.

---

# 177. Repository Success Metrics

Quality Targets

Unit Test Coverage
85%

Critical Module Coverage
95%

Analyzer Warnings
0

Build Success
100%

Crash-Free Sessions
99.9%

Offline Sync Success
99%

API Success Rate
99.9%

---

# 178. Performance Budget

Cold Start

<3 seconds

Navigation

<300ms

Dashboard

<2 seconds

Search

<500ms

Offline Response

Instant

Performance regressions block releases.

---

# 179. Continuous Integration

Every commit triggers

Static Analysis

Formatting

Tests

Security Scan

Dependency Audit

Build Verification

Failed pipelines block merging.

---

# 180. Dependency Management

Before adding any package

Evaluate

Maintenance

Popularity

License

Security

Performance

Last Release

Avoid unnecessary dependencies.

---

# 181. AI Command System

Every AI assistant shall understand the following project commands.

```
/architect
Design architecture before implementation.

/implement
Generate production-ready code.

/review
Perform senior code review.

/security
Review security implications.

/optimize
Improve performance without changing behavior.

/refactor
Improve structure while preserving functionality.

/test
Generate comprehensive tests.

/docs
Generate technical documentation.

/migration
Create database migration.

/rls
Generate or review RLS policies.

/edge
Generate Edge Functions.

/powersync
Review offline synchronization.

/flutter
Generate Flutter UI only.

/backend
Generate backend only.

/fullstack
Implement complete feature.

/bugfix
Investigate and fix defects.

/explain
Explain existing implementation.
```

AI should refuse commands that violate this AGENTS.md contract.

---

# 182. AI Review Checklist

Before returning any generated code, every AI assistant shall verify:

□ No duplicated logic.

□ Clean Architecture preserved.

□ Riverpod pattern respected.

□ Repository abstraction maintained.

□ Direct Supabase calls avoided in UI.

□ RBAC considered.

□ ReBAC considered.

□ RLS implications reviewed.

□ Offline synchronization maintained.

□ Audit logging preserved.

□ Error handling implemented.

□ Documentation updated.

□ Code formatted.

□ Analyzer clean.

□ Production ready.

If any item fails, the AI should revise the solution before presenting it.

---

# 183. Enterprise Database Standards

The database is the most valuable asset of Helpster Care.

Every schema change shall prioritize

- Integrity
- Consistency
- Scalability
- Security
- Performance
- Maintainability

Application code may change frequently.

The database must remain stable.

---

# 184. Canonical Database Schema

The production database shall contain the following core entities.

## Identity

```
users
roles
permissions
role_permissions
user_roles
sessions
```

---

## Organization

```
hospitals
departments
wards
beds
operating_theatres
hospital_assignments
```

---

## Patient Management

```
patients
patient_assignments
patient_contacts
patient_addresses
patient_guardians
patient_history
patient_notes
patient_status_history
```

---

## Clinical

```
treatments
conservative_treatments
surgical_treatments
surgeries
ot_schedules
followups
diagnoses
prescriptions
```

---

## Documents

```
documents
document_categories
document_versions
attachments
```

---

## Workflow

```
approvals
approval_history
workflow_states
workflow_transitions
```

---

## Communication

```
notifications
notification_templates
emails
push_notifications
```

---

## Audit

```
audit_logs
activity_timeline
system_events
```

---

## Analytics

```
dashboard_cache
analytics_daily
analytics_monthly
statistics
```

---

# 185. Database Design Rules

Every table shall

✓ Have a UUID primary key

✓ Have timestamps

✓ Have foreign key constraints

✓ Have indexes

✓ Support auditing

✓ Support RLS

✓ Use snake_case

✓ Be documented

---

# 186. Primary Key Standards

Every table

```sql
id UUID PRIMARY KEY
```

Never use

AUTO_INCREMENT

INTEGER IDs

Random string IDs

UUIDs provide safer distributed generation.

---

# 187. Foreign Key Standards

Every relationship shall use explicit foreign keys.

Example

```
patient_id

hospital_id

doctor_id

case_manager_id

created_by

updated_by
```

Never store orphan references.

---

# 188. Index Strategy

Every table requires indexes.

Mandatory

Primary Key

Foreign Keys

Frequently searched columns

Composite indexes for common filters

Examples

```
patient_id

hospital_id

status

created_at

updated_at
```

Review indexes quarterly.

---

# 189. Views

Use Views for

Reporting

Complex joins

Aggregated queries

Permission abstraction

Naming

```
vw_patient_summary

vw_dashboard_statistics

vw_hospital_statistics
```

Avoid embedding reporting SQL inside Flutter.

---

# 190. Materialized Views

Materialized Views should power

Dashboard

Analytics

Statistics

Large reports

Refresh

Scheduled

On demand

After major events

Never execute expensive aggregations repeatedly.

---

# 191. Trigger Standards

Triggers should be limited to

Audit creation

Timestamp updates

Statistics refresh

Workflow propagation

Avoid implementing large business logic in triggers.

Complex logic belongs in Edge Functions.

---

# 192. SQL Style Guide

Keywords

UPPERCASE

Identifiers

snake_case

Indentation

4 spaces

Always alias complex joins.

Comment every migration.

Prefer readability over brevity.

---

# 193. Query Standards

Prefer explicit queries.

Good

```sql
SELECT
    patient_id,
    patient_name
FROM patients
WHERE status = 'ACTIVE';
```

Avoid

```sql
SELECT * FROM patients;
```

Only retrieve required columns.

---

# 194. Pagination

Large datasets require pagination.

Never fetch

10,000 rows

in one request.

Recommended

Cursor pagination

or

Limit / Offset

depending on use case.

---

# 195. Search Optimization

Search should support

Patient ID

National ID

Name

Phone

Hospital

Doctor

Case Number

Future

Full-text search

Trigram search

Fuzzy matching

Search performance should remain under 500ms.

---

# 196. Performance Standards

Avoid

Nested loops

Repeated joins

N+1 queries

Repeated COUNT(*)

Repeated aggregates

Prefer

Indexes

Materialized Views

Caching

Efficient joins

---

# 197. Storage Optimization

Large binary objects

shall NOT be stored in PostgreSQL.

Store only

Metadata

Checksum

Storage Path

Size

Type

URL Reference

Actual files belong in Supabase Storage.

---

# 198. Backup Policy

Production backups

Daily

Weekly

Monthly

Backup verification

Mandatory.

Recovery testing

Quarterly.

Backups without restore verification are considered invalid.

---

# 199. Disaster Recovery

Recovery objectives

RPO

≤15 minutes

RTO

≤2 hours

Recovery procedures shall be documented and tested.

---

# 200. Monitoring

Monitor

Database Size

Storage Usage

Slow Queries

Failed Jobs

Realtime Connections

Replication Health

Edge Functions

PowerSync Status

Notification Queue

Unexpected growth should trigger alerts.

---

# 201. Dependency Updates

Dependencies shall be reviewed monthly.

Evaluate

Security

Compatibility

Breaking Changes

Maintenance

Deprecated packages should be replaced promptly.

---

# 202. Release Workflow

Every release follows

```
Planning

↓

Implementation

↓

Unit Tests

↓

Integration Tests

↓

Security Review

↓

Performance Review

↓

Documentation

↓

Staging

↓

User Acceptance Testing

↓

Production
```

Skipping stages is prohibited.

---

# 203. Semantic Versioning

Use

```
MAJOR.MINOR.PATCH
```

Examples

```
1.0.0

1.2.0

1.2.5

2.0.0
```

Follow Semantic Versioning strictly.

---

# 204. Feature Development Playbook

Every new feature follows this sequence.

1. Requirements

2. Architecture

3. Database Design

4. RLS Design

5. Repository

6. PowerSync

7. Controllers

8. UI

9. Testing

10. Documentation

11. Review

12. Deployment

Never start with UI.

Always begin with the domain model.

---

# 205. Bug Fix Playbook

Before fixing any bug

1. Reproduce

2. Identify Root Cause

3. Write Regression Test

4. Fix

5. Verify

6. Review

7. Deploy

Never patch symptoms.

Always fix the root cause.

---

# 206. Security Incident Playbook

If a security issue is discovered

1. Contain

2. Assess Impact

3. Notify Stakeholders

4. Patch

5. Verify

6. Audit

7. Document

8. Prevent Recurrence

Security incidents receive highest priority.

---

# 207. AI Collaboration Rules

AI assistants working on this repository shall:

✓ Read AGENTS.md before every task.

✓ Respect repository conventions.

✓ Preserve architecture.

✓ Generate production-quality code.

✓ Explain architectural decisions.

✓ Refuse unsafe implementations.

✓ Recommend improvements when appropriate.

AI must never optimize for speed at the expense of quality.

---

# 208. Repository Governance

This repository is governed by the following order of authority.

1. Project Owner

2. AGENTS.md

3. Approved Architecture Decision Records (ADR)

4. Source Code

5. AI Suggestions

If a conflict exists, the higher authority prevails.

---

# 209. Definition of Excellence

Helpster Care is not intended to be a prototype.

It is intended to be a long-term enterprise healthcare platform.

Every contribution shall improve

Security

Reliability

Maintainability

Accessibility

Performance

Scalability

Transparency

Patient Safety

Code that merely "works" is insufficient.

Code must also be understandable, secure, testable, and sustainable.

---

# 210. Definition of Production Ready

A feature is production-ready only if:

Functional requirements complete
Security review passed
RLS tested
Offline synchronization tested
Audit logs verified
Accessibility validated
Performance budget met
Documentation updated
Monitoring enabled
Rollback strategy documented
QA approved
Product Owner approved

---

# 211. Final Engineering Oath

Every contributor—human or AI—accepts the following obligations:

- Protect patient privacy.
- Protect patient safety.
- Preserve data integrity.
- Follow Clean Architecture.
- Enforce RBAC, ReBAC, and RLS.
- Build offline-first.
- Keep code simple and maintainable.
- Write documentation.
- Write tests.
- Leave the codebase better than it was found.

These principles apply to every commit, every migration, every Edge Function, every Flutter widget, every SQL statement, and every deployment.

---

# 212. ENTERPRISE APPENDICES & IMPLEMENTATION PLAYBOOKS

This section provides implementation references, reusable templates, operational playbooks, and governance artifacts that complement the engineering contract.

---

# Appendix A — Architecture Decision Records (ADR)

## Purpose

Every significant architectural decision shall be recorded as an ADR.

An ADR becomes part of the permanent engineering history.

Examples:

- Flutter architecture
- Riverpod patterns
- PowerSync adoption
- Supabase Storage strategy
- PostgreSQL schema changes
- Security model
- Hospital assignment strategy

---

## ADR Template

ADR Number

Title

Status

Date

Decision Makers

Context

Problem Statement

Decision

Alternatives Considered

Consequences

Migration Plan

Implementation Notes

References

---

# Appendix B — PostgreSQL Schema Specifications

Each table shall include:

Purpose

Columns

Constraints

Indexes

Relationships

Triggers

RLS Policies

Migration Notes

Example

patients

Purpose

Stores the canonical patient record.

Columns

id

patient_id

full_name

date_of_birth

gender

phone

hospital_id

status

created_at

updated_at

created_by

updated_by

Indexes

patient_id

hospital_id

status

created_at

Relationships

Hospital

Treatment

Documents

Timeline

Assignments

Audit

---

# Appendix C — Standard RLS Policy Templates

Every business table documents

SELECT

INSERT

UPDATE

DELETE

Policies

Template

Table

Required Permission

Hospital Assignment

Patient Assignment

Allowed Roles

Restricted Fields

Example SQL

Example

patients

SELECT

has_permission('patient.read')

AND

can_access_patient(patient_id)

UPDATE

has_permission('patient.update')

AND

can_access_patient(patient_id)

DELETE

Super Admin only

---

# Appendix D — Edge Function Specifications

Every Edge Function shall include:

Purpose

Authentication

Authorization

Request Schema

Validation

Business Rules

Database Operations

Audit Events

Notifications

Response Schema

Error Codes

Example

createPatient()

Request

Patient DTO

Validation

Duplicate check

Hospital validation

Assignment validation

Processing

Insert patient

Insert timeline

Insert audit

Generate Patient ID

Queue synchronization

Return

Patient Summary

---

# Appendix E — Flutter Coding Conventions

Widget Example

Screen Example

Controller Example

Repository Example

Form Example

Dialog Example

Dashboard Example

Naming Example

Anti-pattern Example

Refactoring Example

Every convention includes

Good Example

Bad Example

Explanation

---

# Appendix F — Riverpod 3 Templates

Templates

AsyncNotifier

Notifier

Repository Provider

Family Provider

AutoDispose Provider

State Model

Freezed Model

Controller Pattern

Dependency Injection

Testing Pattern

Feature Skeleton

AI assistants shall use these templates unless explicitly instructed otherwise.

---

# Appendix G — PowerSync Contract

Synchronization Lifecycle

Initial Sync

Delta Sync

Conflict Resolution

Background Sync

Retry Queue

Offline Queue

Manual Refresh

Data Ownership

Example synchronization diagrams.

Synchronization requirements for every entity.

---

# Appendix H — Enterprise Permission Catalogue

Every permission is documented.

Examples

patient.create

patient.read

patient.update

patient.delete

patient.approve

patient.reject

patient.assign

patient.transfer

patient.export

hospital.create

hospital.read

hospital.update

hospital.delete

doctor.assign

doctor.remove

document.upload

document.delete

report.export

dashboard.view

notification.send

settings.manage

audit.view

analytics.view

Expected catalogue

200–300 documented permissions.

---

# Appendix I — Assignment SQL Examples

Examples include

Hospital Assignment

Patient Assignment

Doctor Assignment

Volunteer Assignment

Case Manager Assignment

Example helper functions

can_access_patient()

can_access_hospital()

assigned_doctor()

assigned_case_manager()

Example RLS integration.

---

# Appendix J — API Error Catalogue

Every API error receives

Code

HTTP Status

Description

User Message

Developer Notes

Retry Strategy

Examples

PATIENT_NOT_FOUND

HOSPITAL_NOT_FOUND

INVALID_ASSIGNMENT

PERMISSION_DENIED

DOCUMENT_TOO_LARGE

SYNC_CONFLICT

OT_ALREADY_BOOKED

PATIENT_ALREADY_ADMITTED

INVALID_WORKFLOW_STATE

---

# Appendix K — Testing Playbooks

Unit Testing

Repository Testing

Controller Testing

Widget Testing

Golden Testing

Integration Testing

PowerSync Testing

Edge Function Testing

Database Testing

Security Testing

Regression Testing

Every feature receives a Definition of Test Completion checklist.

---

# Appendix L — QA Checklists

Authentication

Patient Registration

Treatment

Hospital Assignment

Approval Workflow

Document Upload

Offline Synchronization

Dashboard

Reports

Notifications

Release Validation

Security Validation

Performance Validation

Accessibility Validation

---

# Appendix M — CI/CD Standards

Pipeline

Static Analysis

Formatting

Unit Tests

Widget Tests

Integration Tests

Migration Validation

RLS Validation

Edge Function Build

Flutter Build

Artifact Generation

Staging Deployment

Production Approval

Rollback Verification

Release Notes

---

# Appendix N — Release Management

Release Planning

Release Candidate

User Acceptance Testing

Production Deployment

Post-release Monitoring

Rollback

Incident Management

Hotfix Workflow

Versioning

Release Checklist

---

# Appendix O — Operations Runbooks

Database Failure

Storage Failure

Realtime Failure

PowerSync Failure

Edge Function Failure

Notification Failure

Authentication Failure

Deployment Failure

Performance Incident

Security Incident

Each runbook includes

Symptoms

Diagnosis

Recovery

Validation

Escalation

---

# Appendix P — Backup & Disaster Recovery

Backup Schedule

Retention

Verification

Recovery Testing

Point-in-Time Recovery

Disaster Scenarios

Recovery Procedures

Recovery Checklists

RPO

RTO

Business Continuity

---

# Appendix Q — AI Prompt Engineering Guide

Repository-specific prompts

/architect

/implement

/review

/security

/database

/rls

/flutter

/riverpod

/powersync

/testing

/documentation

Feature generation prompts

Migration prompts

Review prompts

Bug-fix prompts

Performance prompts

Refactoring prompts

Prompt anti-patterns

Hallucination prevention

Required context before code generation

Prompt quality checklist

This appendix defines the standard operating procedure for all AI-assisted development within the Helpster Care repository.

---

Helpster Care Repository Manifest

Architecture
Clean Architecture

Frontend
Flutter

Backend
Supabase

Database
PostgreSQL

Offline
PowerSync

State Management
Riverpod 3

Navigation
Go Router

Security
RBAC + ReBAC + RLS

Testing
Unit + Widget + Integration

CI/CD
GitHub Actions

Versioning
Semantic Versioning

License
MIT

Owner
Dr. Tapash Paul

...

# End of AGENTS.md

This document is the authoritative Engineering Constitution & AI Development Contract for the Helpster Care platform.

Every implementation, review, architectural decision, and AI-assisted code generation shall conform to this specification.

---