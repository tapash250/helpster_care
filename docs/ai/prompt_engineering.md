# AI Prompt Engineering Guide

> Reference: `AGENTS.md` §6, §12, §207, Appendix Q.

Standard operating procedure for all AI-assisted development in this repository.
Every AI assistant must read [`AGENTS.md`](../../AGENTS.md) before any task.

## Required Context Before Code Generation

Provide the AI with:

1. The relevant `AGENTS.md` sections.
2. The target feature and its existing files.
3. The affected layers (presentation / controller / repository / datasource /
   database).
4. Security scope (RBAC/ReBAC/RLS) and offline implications.
5. Testing and documentation expectations.

## AI Task Checklist (§12)

Before implementation begins, the AI performs the §12 mental checklist:
read existing implementation · search reusable components · identify feature
ownership · validate structure · identify affected modules · check security /
offline / sync / RBAC / RLS / testing / documentation implications.

## Prompt Quality Checklist

- [ ] States the feature and layer(s) explicitly.
- [ ] References the relevant AGENTS.md rules.
- [ ] Lists inputs, outputs, and error cases.
- [ ] Specifies offline + security expectations.
- [ ] Requests tests and doc updates.

## Prompt Anti-Patterns

- Vague requests ("make it work") — no architectural context.
- Asking for UI first (always begin with the domain model — §204).
- Requesting direct Supabase calls from widgets (forbidden — §16, §19).
- Embedding permissions in code or JWT (forbidden — §67, §74).

## Hallucination Prevention

- Prefer reusing existing components over inventing new ones.
- Never invent business requirements — request clarification (§6, §210).
- Cite the AGENTS.md section that justifies a decision.
- If a request violates AGENTS.md, the AI refuses and explains (§181, §207).

## Related

- [`commands.md`](./commands.md)
- [`coding_examples.md`](./coding_examples.md)
- [`review_checklist.md`](./review_checklist.md)
