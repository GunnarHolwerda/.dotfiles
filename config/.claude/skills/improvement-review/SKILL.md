---
name: improvement-review
description: Run a two-reviewer adversarial improvement review — one Claude (latest Opus, xhigh) reviewer and one Codex (gpt-5.6-sol, xhigh) reviewer — over the current branch changes, a plan, an outstanding diff, or a claimed bug finding, then reconcile and act on the findings. Works from either Claude Code or Codex; each runs one reviewer locally and delegates the other across. Call with no args to review all changes on the current branch, or with a short description of what to review. Also invoke this proactively after completing a large chunk of work to validate correctness, simplicity, and accuracy before considering it done.
---

# Improvement Review

Get two independent, adversarial reviews of some work — one from Claude (latest Opus, xhigh) and one from Codex (gpt-5.6-sol, xhigh), running as separate processes — then reconcile their findings and either fix them or bring a clear recommendation to the user.

This skill runs from **either** agent. The two reviewers are always the same; only the mechanism for launching each one changes, because one of them is whichever agent you already are. Section 4 tells you which half you run locally and which half you delegate.

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

Write the brief to a scratchpad file. Both reviewers read the same file, and a delegated CLI run needs it on disk anyway.

Pick a writable scratch directory first and set `$SCRATCH` to it — the commands below assume it exists. Use your own scratchpad dir if you have one, otherwise a temp dir. You need somewhere writable for both the brief and each reviewer's output file; if nothing is writable, say so and stop rather than running reviews you cannot capture.

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

Both reviewers get the same brief and the same mandate. Start them concurrently — never wait for one to finish before starting the other — and collect both before synthesizing.

First work out which agent you are, then follow that row. Do not run the other row.

| You are | Reviewer A (Claude) | Reviewer B (Codex) |
| --- | --- | --- |
| **Claude Code** | run locally, via the `Agent` tool | delegate across, via the `codex` skill |
| **Codex** | delegate across, via the `claude-code` skill | run locally, via a nested `codex exec` |

**Launching them concurrently.** In Claude Code, put both tool calls in a single message. In Codex, start the delegated CLI run in the background and work the local reviewer while it runs.

### Reviewer A — Claude (latest Opus, xhigh)

- **From Claude Code (local):** use the `Agent` tool with `model: "opus"` and `subagent_type: "general-purpose"`. `model: "opus"` always resolves to the latest Opus — do not pin a version. Pass the full brief and mandate, and tell it to read the relevant code itself. If you can set reasoning effort explicitly, use xhigh.
- **From Codex (delegated):** load your `claude-code` skill and follow it. Use its read-only recipe — the reviewer must not modify the tree — and select the latest Opus at xhigh effort. Take the flag spellings from that skill, not from here. Pass the brief contents as the prompt.

### Reviewer B — Codex (gpt-5.6-sol, xhigh)

- **From Codex (local):** run a nested `codex exec` as a sub agent. There is deliberately no `codex` skill installed for Codex — an agent does not carry a skill for invoking itself — so the flags for this one route are given here and this file is their source of truth:

  ```bash
  codex exec -m gpt-5.6-sol -c model_reasoning_effort="xhigh" -s read-only \
    --skip-git-repo-check -o "$SCRATCH/codex-review.md" \
    "$(cat "$SCRATCH/review-brief.md")" < /dev/null > "$SCRATCH/codex-review.log" 2>&1 &
  ```

  The trailing `&` backgrounds it so Reviewer A runs at the same time. Wait for it before synthesizing, and read the findings from `-o`, not from the log.

  Give it the mandate verbatim so it reviews independently rather than agreeing with you — a nested run of the same model is only worth having if it reasons from the brief, not from your conclusions.
- **From Claude Code (delegated):** load your `codex` skill and follow it. Use `-m gpt-5.6-sol`, `-c model_reasoning_effort="xhigh"`, `-s read-only`, and capture the answer with `-o`.

### Rules that apply to both, whichever agent you are

- **This file chooses the model and effort; the launcher skill chooses the mechanics.** Model (latest Opus, gpt-5.6-sol), effort (xhigh), and read-only scope are review decisions and are set here. Everything else — flag names, output capture, stdin handling — comes from the `codex` or `claude-code` skill for a delegated run, because those are kept current against the installed CLIs. The one exception is Codex's own nested run above, which has no skill to read, so this file is authoritative for it.
- **Pass the brief as the prompt argument's contents, not as a path.** Neither CLI reads a file path given as the prompt. Use command substitution: `"$(cat "$SCRATCH/review-brief.md")"`.
- **Read-only.** Neither reviewer may modify the tree. It reads and reports.
- **Run it unpiped and in the background.** At xhigh a review takes minutes. Never pipe a delegated run through `tail`, `head`, or `tee` — you lose the completion signal and cannot tell a finished run from a running one. Redirect to a file and read the file.
- **Both reviewers can open files themselves,** so give scope and paths rather than pasting the whole codebase. Still state the scope explicitly in the brief.
- **If either reviewer is unavailable** — binary missing, not authenticated, command errors, empty output — say so plainly and proceed with whichever review you did get, rather than aborting. This applies to the local nested run as much as the delegated one. Report that the review was one-sided; never present it as a two-reviewer result.

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
