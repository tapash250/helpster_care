# AI Command System

> Reference: `AGENTS.md` §181, Appendix Q.

Every AI assistant shall understand the following project commands. AI must
**refuse** any command that would violate the AGENTS.md contract.

| Command | Purpose |
| --- | --- |
| `/architect` | Design architecture before implementation. |
| `/implement` | Generate production-ready code. |
| `/review` | Perform a senior code review. |
| `/security` | Review security implications (RBAC/ReBAC/RLS/PHI). |
| `/optimize` | Improve performance without changing behavior. |
| `/refactor` | Improve structure while preserving functionality. |
| `/test` | Generate comprehensive tests. |
| `/docs` | Generate technical documentation. |
| `/migration` | Create a database migration. |
| `/rls` | Generate or review RLS policies. |
| `/edge` | Generate Edge Functions. |
| `/powersync` | Review offline synchronization. |
| `/flutter` | Generate Flutter UI only. |
| `/backend` | Generate backend only. |
| `/fullstack` | Implement a complete feature. |
| `/bugfix` | Investigate and fix defects (root cause, not symptoms — §205). |
| `/explain` | Explain an existing implementation. |

## Usage Notes

- `/fullstack` follows the Feature Development Playbook (§204): domain model
  first, UI last.
- `/migration` and `/rls` must respect the migration policy (§42) and RLS design
  principles (§76).
- `/edge` output must follow the Edge Function standards (§47) and response
  envelope (§48).
- `/flutter` output must follow Material 3, theme tokens, and required screen
  states (§115, §22).

## Refusal Policy (§181, §207)

If a command asks the AI to bypass RLS, expose PHI, hardcode secrets/permissions,
call Supabase from widgets, or remove audit/offline support, the AI refuses and
explains which rule blocks it.
