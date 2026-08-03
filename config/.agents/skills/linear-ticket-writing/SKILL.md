---
name: linear-ticket-writing
description: Write, rewrite, review, and audit Linear tickets using Gunnar's product-first format. Use when drafting Linear issues, converting product or technical notes into tickets, improving acceptance criteria, reviewing ticket quality, identifying ticket overlap, or moving implementation guidance into a final Technical details section.
---

# Linear Ticket Writing

Write tickets so a reader first understands the product outcome, then the independently verifiable behavior, and only then the implementation guidance.

## Required structure

1. Write a title that names the concrete deliverable or user outcome.
2. Open with one to three sentences describing:
   - what is being built or changed;
   - who benefits or uses it;
   - why the work matters.
3. Add `### End State` that states in plain English what will exist in the codebase or product when the ticket is finished.
4. Add `## Acceptance Criteria`.
5. End the ticket with `### Technical details`.

Do not put code references, schema details, or implementation choices in the opening product description.

## Write the end state

Use `### End State` to make the ticket and expected PR boundary immediately clear before the acceptance criteria.

- State the concrete codebase or product capabilities that will exist when the ticket is complete.
- Name the major layers included when the scope spans them, such as schema, repositories, services, API, or UI.
- Call out important exclusions when they prevent overlap with adjacent tickets.
- Keep it short and in plain English, usually one paragraph.
- Describe the finished state, not an implementation plan or a second acceptance-criteria list.

## Write acceptance criteria

- Aim for four or five high-level criteria for most tickets. Treat this as a default, not a quota; if substantially more are needed, group related behavior or reconsider the ticket scope.
- Describe observable outcomes, not implementation steps.
- Make every criterion independently verifiable at the level of a meaningful product or system state.
- Write product-layer criteria so a QA tester can verify them without reading the code.
- Write foundation-layer criteria so an engineer can verify them through an API, database, job, log, or automated test.
- Collectively cover the happy path plus material error, authorization, empty, and boundary behavior that matters to the ticket.
- Combine closely related cases within one criterion when they express the same functional requirement. Do not create a long checklist of tiny validations, individual fields, or implementation facts.
- Preserve decided constraints and accepted limitations.
- Avoid vague criteria such as "works correctly," "is performant," or "handles errors."

Use checkboxes when they improve scanning:

```markdown
## Acceptance Criteria

- [ ] A permitted user can ...
- [ ] A user without access receives ...
- [ ] Invalid input results in ... without ...
- [ ] When no matching data exists, the system ...
```

## Write technical details

Make `### Technical details` the final section. Include only details that help an engineer implement the ticket:

- relevant files, services, repositories, methods, and existing patterns;
- schema, index, migration, transaction, authorization, logging, and feature-flag constraints;
- areas of the codebase to inspect or reuse;
- known sequencing or rollout considerations.

Prefer stable file paths, symbols, and patterns over brittle line numbers. Keep technology-provider names out of durable schema names when the underlying concept is provider-neutral.

## Set ticket scope

- Keep one coherent product experience in a vertical ticket when its layers must ship together to produce value.
- Split independently shippable infrastructure, migration, cleanup, or reusable foundation work into separate tickets.
- Represent blockers, sequencing, duplicates, and superseded work with Linear relations when available instead of relying only on prose.
- Retain valid detail when rewriting an existing ticket.
- Flag unresolved product or architecture decisions explicitly instead of inventing an answer.

## Review tickets

Check each ticket for:

1. alignment with the governing product and architecture decisions;
2. a product-first opening;
3. an end state that makes the finished codebase or product scope clear;
4. acceptance criteria that another person can verify;
5. technical guidance placed at the bottom;
6. missing authorization, failure, boundary, rollout, or migration behavior;
7. overlap, duplication, or conflicting ownership with other tickets;
8. scope that is either independently shippable or a coherent vertical outcome.
