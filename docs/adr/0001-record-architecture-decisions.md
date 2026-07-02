# ADR 0001: Record Architecture Decisions

- **Status:** Accepted
- **Date:** 2026-07-02
- **Decision Makers:** Project Owner (Dr. Tapash Paul), Engineering

## Context

Helpster Care is a long-term enterprise healthcare platform. Significant
architectural decisions must be traceable and form part of the permanent
engineering history (AGENTS.md Appendix A).

## Problem Statement

Without a durable record, the rationale behind architectural choices is lost,
leading to repeated debate and inconsistent implementations.

## Decision

We will record every significant architectural decision as an Architecture
Decision Record (ADR) in `docs/adr`, using the template defined in
`AGENTS.md` Appendix A.

## Alternatives Considered

- **No formal records** — rejected; violates the governance model (§208).
- **Wiki-only documentation** — rejected; drifts from the codebase.

## Consequences

- Every notable decision is version-controlled alongside the code.
- New contributors (human or AI) can understand *why* the system is shaped as
  it is before making changes.

## References

- `AGENTS.md` §208 Repository Governance, Appendix A.
