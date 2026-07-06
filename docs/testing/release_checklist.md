# Release Checklist

> Reference: `AGENTS.md` §202, §203, §210, Appendix N.

## Release Workflow (§202)

```
Planning → Implementation → Unit Tests → Integration Tests →
Security Review → Performance Review → Documentation →
Staging → User Acceptance Testing → Production
```

Skipping stages is prohibited.

## Pre-Release

- [ ] Version bumped per Semantic Versioning (`pubspec.yaml`, tags).
- [ ] `CHANGELOG.md` updated (Unreleased → new version).
- [ ] All CI checks green (analysis, format, tests, security scan, build).
- [ ] Zero analyzer warnings; no `TODO`s in shipped code.
- [ ] Migrations tested on staging; reversible where possible.
- [ ] RLS policies validated (positive + negative cases).
- [ ] Edge Functions deployed & smoke-tested.
- [ ] Secrets present in environment (never in source).

## Definition of Production Ready (§210)

- [ ] Functional requirements complete
- [ ] Security review passed
- [ ] RLS tested
- [ ] Offline synchronization tested
- [ ] Audit logs verified
- [ ] Accessibility validated
- [ ] Performance budget met (§178)
- [ ] Documentation updated
- [ ] Monitoring enabled
- [ ] Rollback strategy documented
- [ ] QA approved
- [ ] Product Owner approved

## Deployment

- [ ] Deploy to staging; run smoke + UAT.
- [ ] Verify PowerSync sync health post-deploy.
- [ ] Deploy to production (approved).
- [ ] Post-release monitoring (errors, sync, performance) for the first hours.

## Rollback

- [ ] Rollback procedure verified before release.
- [ ] Database rollback / point-in-time recovery understood (RPO ≤ 15 min,
      RTO ≤ 2 h — §199).
- [ ] Incident owner assigned.

## Post-Release

- [ ] Tag release in Git; publish release notes.
- [ ] Close milestone; capture lessons learned.
