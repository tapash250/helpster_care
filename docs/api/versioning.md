# API Versioning

> Reference: `AGENTS.md` §203 (Semantic Versioning), §170 (Commits), §48.

## Principles

- The platform follows **Semantic Versioning** — `MAJOR.MINOR.PATCH`.
- The API response envelope (`success`, `data`, `message`, `error`) is stable
  and treated as a public contract.

## When to Bump

| Change | Bump |
| --- | --- |
| Backwards-incompatible request/response change, removed field, changed error semantics | **MAJOR** |
| New Edge Function, new optional field, additive behavior | **MINOR** |
| Bug fix, doc/typo, non-behavioral change | **PATCH** |

## Compatibility Rules

- **Additive changes** (new optional fields, new functions) do not break clients.
- **Never** repurpose an existing field's meaning — add a new field instead.
- **Never** remove a field within the same MAJOR version; deprecate first.
- Error `code` values are stable identifiers; new codes may be added (MINOR),
  existing codes are not repurposed.

## Deprecation Policy

1. Mark the field/function deprecated in docs and (where possible) in responses.
2. Announce in [`CHANGELOG.md`](../../CHANGELOG.md).
3. Provide a migration path and a removal target (next MAJOR).
4. Remove only at the next MAJOR release.

## Function Naming & Routes

Edge Function routes are stable, kebab-case identifiers (e.g., `create-patient`).
A new incompatible behavior ships as a new function or a MAJOR release — never a
silent change to an existing route.

## Release Coordination

API changes ship through the standard Release Workflow (§202) and are recorded
in the CHANGELOG using Conventional Commit types (`feat`, `fix`, `security`, …).
