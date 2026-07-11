---
name: improvement-review
description: Run a two-reviewer adversarial improvement review — one Opus 4.8 (xhigh) subagent and one Codex (gpt-5.6-sol, xhigh) via the codex CLI — over the current branch changes, a plan, an outstanding diff, or a claimed bug finding, then reconcile and act on the findings. Call with no args to review all changes on the current branch, or with a short description of what to review. Also invoke this proactively after completing a large chunk of work to validate correctness, simplicity, and accuracy before considering it done.
---

# Improvement Review

Get two independent, adversarial reviews of some work — from a Claude (Opus 4.8, xhigh) reviewer and a Codex (gpt-5.6-sol, xhigh) reviewer running as separate processes — then reconcile their findings and either fix them or bring a clear recommendation to the user.

Use this to pressure-test a solution: find bugs, unhandled cases, over-engineering, security holes, and — importantly — architectural/refactoring problems that are better fixed *before* building further. It is equally valid for the user to invoke this manually or for you to invoke it yourself when you want confidence that a big change is correct, simple, and complete.

## 1. Determine scope

The argument (if any) tells you what to review. Handle these cases:

- **Empty / no argument** → review **all changes on the current branch**: the diff of the working tree plus committed changes versus the base branch. Gather it with:
  - `git merge-base HEAD main` (fall back to `master`/`origin/HEAD` if `main` doesn't exist) to find the fork point.
  - `git diff <merge-base>...HEAD` for committed work, plus `git diff HEAD` and `git status` for uncommitted work.
  - The list of changed files, so reviewers can open surrounding code for context.
- **"the plan" / a described approach** → review the plan/design (a plan doc, a proposal in the conversation, or an approach you just outlined) for soundness, gaps, over-complication, and better-aligned alternatives — before implementation.
- **"just the outstanding changes" / uncommitted work** → scope to `git diff HEAD` + untracked files only.
- **"validate this bug finding" / a claim** → scope to the specific claim: gather the claimed root cause and the relevant code, and have the reviewers independently confirm or refute it and check for a better fix.

If the scope is genuinely ambiguous, make the most reasonable assumption, state it, and proceed — don't stall.

## 2. Build a shared review brief

Assemble a concise brief both reviewers will receive. Include:
- **What to review** and the scope boundaries (files, diff range, or the plan/claim).
- **Context**: what the change is trying to accomplish and any constraints, so they can judge fit with the codebase.
- The **diff or relevant file paths** (reviewers have repo read access and can open more).
- The **review mandate** (section 3).

Write the brief to a scratchpad file so it can be passed to the codex CLI cleanly.

## 3. The review mandate (give this to BOTH reviewers)

> You are an adversarial senior reviewer. Your job is to find what's wrong or could be better — assume there are problems and go looking for them. Be pragmatic: do not invent nitpicks or bikeshed style. But when something genuinely matters — a correctness bug, a security hole, or a refactoring that would meaningfully improve the architecture — be adamant and unambiguous about it.
>
> Evaluate for:
> - **Correctness** — bugs, logic errors, off-by-one, wrong assumptions, unhandled edge cases and error paths, race conditions, broken invariants.
> - **Things not thought of** — missing cases, inputs, states, or failure modes the author overlooked.
> - **Over-complication** — needless abstraction, indirection, or complexity that should be simplified.
> - **Simplifications** — concrete ways to make the code smaller, clearer, or more direct without losing behavior.
> - **Architecture & refactoring-before-implementation** — where the current shape fights the rest of the codebase, and a refactor done *now* (before building further on it) would yield a materially better, more consistent design. Call these out strongly when they matter.
> - **Security** — injection, authz/authn gaps, unsafe input handling, secret exposure, unsafe defaults.
> - **Consistency** — divergence from existing patterns, conventions, and idioms in this codebase.
>
> For each finding give: a short title, severity (critical / high / medium / low), the file:line or component, why it's a problem, and a concrete recommended fix. Prefer few high-signal findings over a long low-value list. If you believe the work is sound, say so plainly.

## 4. Run the two reviewers in parallel

Launch both in a **single message** so they run concurrently.

**Reviewer A — Claude (Opus 4.8, xhigh):** use the `Agent` tool with `model: "opus"` and `subagent_type: "general-purpose"`. Pass the full brief and the review mandate. Instruct it to read the relevant code itself for context and return its findings in the format above. (This session runs at high reasoning effort so the subagent reviews deeply; if you can set effort explicitly, use xhigh.)

**Reviewer B — Codex (gpt-5.6-sol, xhigh):** shell out to the codex CLI via `Bash`. Write the brief to a file first, then run (adjust the message file path to the scratchpad):

```bash
codex exec \
  -m gpt-5.6-sol \
  -c model_reasoning_effort="xhigh" \
  -s read-only \
  --skip-git-repo-check \
  -o "$SCRATCH/codex-review.md" \
  "$(cat "$SCRATCH/review-brief.md")" < /dev/null
```

Then read `$SCRATCH/codex-review.md` for Codex's findings. Notes:
- `-s read-only` keeps the reviewer from modifying the tree — it only reads and reports.
- `--skip-git-repo-check` avoids codex refusing to run when the working dir isn't a codex-trusted directory; `< /dev/null` prevents it from blocking on stdin.
- Codex runs in the current repo, so it can open files and inspect the diff directly; still give it the explicit scope in the brief.
- Prefer running the codex command in the background (or accept that it may take a few minutes) so it overlaps with Reviewer A. Collect both before synthesizing.
- If the `codex` binary is missing or errors, report that Reviewer B was unavailable and proceed with Reviewer A's findings rather than aborting.

## 5. Reconcile the findings

Merge both reviews into one deduplicated, severity-ranked list:
- **Agreement** between the two reviewers on a finding raises confidence — treat it as high-signal.
- **Disagreement** or a solo finding: judge it on the merits against the actual code before accepting it. Reviewers can be wrong or miss context; verify before acting.
- Group by category (correctness, security, over-complication, simplification, architecture/refactor, consistency) and order by severity.

## 6. Act on the results

- **Clear, safe, in-scope fixes** → apply them directly.
- **Judgment calls, trade-offs, or anything that changes scope/behavior** → bring them to the user with a concrete **recommendation** of what you think should happen and why, rather than a menu of open questions.
- **Important architectural or refactoring findings** → surface them prominently and be adamant. If a refactor should happen *before* more is built on the current shape, say so directly and explain the cost of not doing it now.
- **Do not blindly apply every finding.** Respect code that is there on purpose; if a finding would undo an intentional decision, flag it instead of changing it.

End with a short summary: what both reviewers found, what you fixed, and what needs the user's decision (with your recommendation).
