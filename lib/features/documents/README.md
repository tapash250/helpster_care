# Documents Feature

Part of the **Helpster Care** platform. Implemented with Clean Architecture
(feature-first) and offline-first execution per `AGENTS.md`.

## Structure

| Folder | Responsibility |
| --- | --- |
| `controllers/` | Riverpod Notifiers / AsyncNotifiers coordinating use cases (thin). |
| `datasources/local/` | Drift / PowerSync local data access. |
| `datasources/remote/` | Supabase, Edge Functions, Storage access. |
| `models/` | Immutable domain models (Freezed). |
| `providers/` | Riverpod provider declarations & dependency injection. |
| `repositories/` | Sole public interface to data; merges local + remote. |
| `routes/` | Go Router route constants & builders for this feature. |
| `screens/` | Presentation screens (render state only). |
| `services/` | Feature-scoped domain services. |
| `states/` | Immutable state objects for controllers. |
| `validators/` | Client-side input validation. |
| `widgets/` | Reusable, composable widgets (< 300 lines each). |

## Rules

- No business logic in widgets.
- No direct Supabase calls from presentation.
- All data access goes through `repositories/`.
- Every async operation exposes Loading / Success / Error / Offline states.
- RBAC + ReBAC + RLS are enforced on the backend, never trusted from the client.
