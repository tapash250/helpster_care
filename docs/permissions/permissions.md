# Permission Catalogue

> Reference: `AGENTS.md` §67, §86, Appendix H.

Permissions follow the format **`module.action`** and are stored in the database
(`permissions` table). **Never hardcode permissions.** They are loaded from the
database at runtime — never embedded in the JWT (§74).

The full catalogue is expected to grow to **200–300 documented permissions**.
The core set:

## Dashboard
| Permission | Description |
| --- | --- |
| `dashboard.view` | View dashboard metrics (scoped). |

## Patient
| Permission | Description |
| --- | --- |
| `patient.create` | Register a new patient. |
| `patient.read` | View patient records (with `can_access_patient`). |
| `patient.update` | Edit patient records. |
| `patient.archive` | Soft-archive a patient. |
| `patient.delete` | Hard delete (Super Admin only). |
| `patient.approve` | Approve a case. |
| `patient.reject` | Reject a case. |
| `patient.assign` | Assign staff to a patient. |
| `patient.transfer` | Transfer between hospitals. |
| `patient.export` | Export patient data (PDF/Excel/CSV). |

## Hospital
| Permission | Description |
| --- | --- |
| `hospital.create` / `hospital.read` / `hospital.update` / `hospital.delete` | Manage hospitals. |
| `hospital.assign` | Assign a patient to a hospital. |
| `hospital.view` | View a hospital (with `can_access_hospital`). |

## Doctor
| Permission | Description |
| --- | --- |
| `doctor.assign` / `doctor.remove` | Manage doctor assignments. |

## Document
| Permission | Description |
| --- | --- |
| `document.upload` | Upload medical documents. |
| `document.delete` | Delete documents (Super Admin only). |

## Reports / Notifications / Admin
| Permission | Description |
| --- | --- |
| `report.export` | Export reports. |
| `notification.send` | Send notifications. |
| `user.manage` | Manage users, roles, assignments. |
| `settings.manage` | Manage system settings. |
| `audit.view` | View audit logs. |
| `analytics.view` | View analytics. |

## Rules

- Role alone is **never** sufficient (`AGENTS.md` §65). Access = RBAC + ReBAC +
  RLS + business rules.
- Every permission is documented before use.
- Enforcement is layered: Controller → Repository → Edge Function → RLS →
  Constraints.
