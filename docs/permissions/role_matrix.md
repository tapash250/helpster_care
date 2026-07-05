# Role → Permission Matrix

> Reference: `AGENTS.md` §66, §72, Appendix H.

The role hierarchy represents **responsibility**, not automatic access.
Permissions are assigned **explicitly** via `role_permissions`. Role alone is
never enough — record access is further gated by ReBAC + RLS.

## Role Hierarchy (§66)

```
Super Admin → Admin → Field Officer / Case Manager → Volunteer → Doctor → Read-only Auditor
```

## Matrix

Legend: ✅ granted · ⛔ not granted · 🔶 scoped (assignment-limited)

| Permission | Super Admin | Admin | Case Manager | Volunteer | Doctor | Auditor |
| --- | :--: | :--: | :--: | :--: | :--: | :--: |
| `dashboard.view` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `patient.create` | ✅ | ✅ | ✅ | 🔶 | ⛔ | ⛔ |
| `patient.read` | ✅ | 🔶 | 🔶 | 🔶 | 🔶 | 🔶 |
| `patient.update` | ✅ | 🔶 | 🔶 | 🔶 | 🔶 | ⛔ |
| `patient.approve` | ✅ | ✅ | ⛔ | ⛔ | ⛔ | ⛔ |
| `patient.reject` | ✅ | ✅ | ⛔ | ⛔ | ⛔ | ⛔ |
| `patient.assign` | ✅ | ✅ | ✅ | ⛔ | ⛔ | ⛔ |
| `patient.delete` | ✅ | ⛔ | ⛔ | ⛔ | ⛔ | ⛔ |
| `patient.export` | ✅ | ✅ | 🔶 | ⛔ | ⛔ | 🔶 |
| `hospital.view` | ✅ | 🔶 | 🔶 | 🔶 | 🔶 | 🔶 |
| `hospital.create` | ✅ | ✅ | ⛔ | ⛔ | ⛔ | ⛔ |
| `hospital.update` | ✅ | ✅ | ⛔ | ⛔ | ⛔ | ⛔ |
| `hospital.delete` | ✅ | ⛔ | ⛔ | ⛔ | ⛔ | ⛔ |
| `hospital.assign` | ✅ | ✅ | ✅ | ⛔ | ⛔ | ⛔ |
| `doctor.assign` | ✅ | ✅ | ✅ | ⛔ | ⛔ | ⛔ |
| `document.upload` | ✅ | 🔶 | 🔶 | 🔶 | 🔶 | ⛔ |
| `document.delete` | ✅ | ⛔ | ⛔ | ⛔ | ⛔ | ⛔ |
| `report.export` | ✅ | ✅ | 🔶 | ⛔ | ⛔ | 🔶 |
| `notification.send` | ✅ | ✅ | 🔶 | ⛔ | ⛔ | ⛔ |
| `user.manage` | ✅ | 🔶 | ⛔ | ⛔ | ⛔ | ⛔ |
| `settings.manage` | ✅ | 🔶 | ⛔ | ⛔ | ⛔ | ⛔ |
| `audit.view` | ✅ | ✅ | ⛔ | ⛔ | ⛔ | ✅ |
| `analytics.view` | ✅ | ✅ | 🔶 | ⛔ | ⛔ | 🔶 |

## Visibility Scope (§72)

| Role | Patient scope |
| --- | --- |
| Doctor / Volunteer / Case Manager | Assigned patients only |
| Admin | Patients within assigned hospitals |
| Super Admin | All patients |
| Auditor | Read-only within assigned scope |

> This matrix is a **seed** for `role_permissions`. It is illustrative and must
> be reviewed by the Project Owner before production. `🔶` entries are enforced
> at record level by `can_access_patient()` / `can_access_hospital()`.
