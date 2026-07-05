# Edge Function — `dashboard_statistics` (`generateDashboard`)

> Reference: `AGENTS.md` §46, §58, §107, §190, Appendix D.

Returns aggregated dashboard metrics for the current user, respecting RBAC/RLS
scope. Reads from cache / materialized views — never runs expensive live
aggregations on every request.

## Contract

| Field | Value |
| --- | --- |
| Route | `GET /functions/v1/generate-dashboard` |
| Auth | Supabase JWT required |
| Permission | `dashboard.view` |

## Processing Steps

1. Authenticate & validate JWT; verify `dashboard.view`.
2. Resolve the caller's authorization scope (assigned hospitals / patients).
3. Read from `dashboard_cache` / `mv_dashboard_statistics` filtered to scope.
4. Return typed metrics. Never expose records the user cannot access.

## Metrics Returned (§107)

```json
{
  "total_patients": 0,
  "todays_registrations": 0,
  "pending_approvals": 0,
  "current_admissions": 0,
  "conservative_treatments": 0,
  "surgical_treatments": 0,
  "hospital_occupancy": 0.0,
  "critical_patients": 0,
  "upcoming_ot": 0,
  "followups_due": 0
}
```

## Success Response (§48)

```json
{ "success": true, "data": { "...": "metrics above" }, "message": "OK", "error": null }
```

## Caching (§58, §190)

Dashboard widgets load independently; failure of one metric must not fail the
whole payload. Materialized views are refreshed by the `dailyAnalytics`
scheduled job and after major events.

## Error Codes

| Code | HTTP | Meaning |
| --- | --- | --- |
| `PERMISSION_DENIED` | 403 | Missing `dashboard.view` |
