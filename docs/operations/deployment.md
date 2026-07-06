# Deployment

> Reference: `AGENTS.md` §179, §202, Appendix M, Appendix N.

## Environments

```
local → staging → production
```

Never commit directly to `main`. Never modify production tables manually
(§42). Never deploy with failing CI (§179).

## CI/CD Pipeline (Appendix M)

Every commit triggers:

```
Static Analysis → Formatting → Unit Tests → Widget Tests → Integration Tests →
Migration Validation → RLS Validation → Edge Function Build → Flutter Build →
Artifact Generation → Staging Deployment → Production Approval →
Rollback Verification → Release Notes
```

Failed pipelines block merging.

## Backend Deployment (Supabase)

```bash
# 1. Apply migrations (chronological; tested on staging first)
supabase db push

# 2. Deploy Edge Functions
supabase functions deploy create-patient
supabase functions deploy approve-patient
# ... one per function in supabase/functions/

# 3. Set secrets (never in source)
supabase secrets set POWERSYNC_URL=... SERVICE_KEY=...
```

## Frontend Deployment (Flutter)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release      # Android
flutter build ipa --release      # iOS
```

## Pre-Deploy Gate (§62 Backend Validation Checklist)

- [ ] Migration tested · RLS enabled · Policies validated
- [ ] Edge Functions tested · Storage secured · Audit logging enabled
- [ ] Background jobs configured · PowerSync verified
- [ ] Conflict resolution tested · Realtime subscriptions optimized

Deployment is blocked until every item passes.

## Post-Deploy

- Verify PowerSync sync health and Edge Function logs.
- Monitor error rate, performance budget (§178), and queue health (§61).
- See [`../testing/release_checklist.md`](../testing/release_checklist.md).

## Rollback

Have a verified rollback path before every release. For data, use point-in-time
recovery (RPO ≤ 15 min, RTO ≤ 2 h — §199). See runbooks in
[`./runbooks/`](./runbooks).
