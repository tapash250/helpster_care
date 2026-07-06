# AI Review Checklist

> Reference: `AGENTS.md` §182. Before returning any generated code, every AI
> assistant must verify each item. If any item fails, revise before presenting.

## Architecture

- [ ] No duplicated logic.
- [ ] Clean Architecture preserved (layers not violated).
- [ ] Riverpod pattern respected.
- [ ] Repository abstraction maintained.
- [ ] Direct Supabase calls avoided in UI.

## Security

- [ ] RBAC considered.
- [ ] ReBAC considered.
- [ ] RLS implications reviewed.
- [ ] No PHI exposed; no secrets hardcoded.
- [ ] Audit logging preserved.

## Offline & Sync

- [ ] Offline synchronization maintained.
- [ ] Conflict handling considered.
- [ ] Offline queue behavior preserved.

## Quality

- [ ] Error handling implemented (no swallowed exceptions).
- [ ] Documentation updated.
- [ ] Code formatted (`dart format`).
- [ ] Analyzer clean (zero warnings).
- [ ] Production ready.

## Presentation (if UI changed)

- [ ] Material 3 + theme tokens; no hardcoded colors/sizes.
- [ ] Loading / Empty / Offline / Error / Permission-Denied / Success states.
- [ ] Responsive + accessible.
- [ ] Widget tests written; reusable components extracted.

## Backend (if backend changed)

- [ ] Migration reversible & tested; RLS enabled and validated.
- [ ] Edge Function: authenticate → authorize → validate → execute → audit →
      typed response.
- [ ] Transactions used for multi-table writes.

## Definition of Done Gate (§173)

- [ ] Tests passing · RLS verified · Offline verified · Docs updated ·
      No analyzer warnings · No TODOs · Reviewed · Approved.

> The AI must **refuse** and explain if a request would violate any
> Non-Negotiable Rule (§5) or Security Commandment (§86).
