---
name: cleanup-comments
description: Remove extraneous comments from code, keeping only genuine "code deodorant" — comments that explain something genuinely hard to read or a non-obvious constraint. Use when the user asks to clean up comments, remove comment noise/slop, de-comment code, or strip narration comments. Also apply proactively to comments you or a prior agent just wrote when asked to tidy up.
---

# Cleanup Comments

Remove comments that don't earn their place. The bar for a comment to survive is high: it must be **code deodorant** in Martin Fowler's sense (from *Refactoring*) — a comment used only because the code cannot be made clear enough on its own.

## Core principle

Comments are a signal of a failure to express something in code. Fowler's guidance: when you feel the urge to write a comment, first try to refactor so the comment becomes unnecessary — extract a well-named function, rename a variable, restructure the logic. Only when that fails does a comment earn its place.

The user strongly prefers putting rationale in **commit messages** over comments. A comment should not carry information that belongs in the git history ("changed this because…", "previously we did X").

## Remove these

- **Narration** — comments that restate what the next line already says. `// increment counter` above `counter++`. `// loop over users`. If the comment only confirms what well-named code already communicates, delete it.
- **Redundant JSDoc/docstrings** — boilerplate `@param`/`@returns` that just restate the types and parameter names with no new information; a one-line summary that repeats the function name in prose.
- **Changelog / history comments** — "added X", "removed Y", "used to be Z", dates, ticket numbers inline. This belongs in the commit message.
- **Cross-reference / "used by" comments** — comments that describe where a function, value, or type is consumed elsewhere ("Used when a thread is archived…", "Called by the sync worker", "Referenced in the settings page"). These couple a definition to distant call sites the reader can't see, so they go stale the moment a caller changes and actively mislead both humans and agents. Callers are discoverable with a reference search; don't narrate them here. Keep only the local *why* the code takes the shape it does, not who calls it.
- **Commented-out code** — dead code that version control already preserves.
- **Section-divider decoration** and other visual noise that renaming or splitting a function would obviate.
- **Obvious explanations** of standard idioms any competent reader knows.

## Keep these

Preserve a comment when the code is genuinely difficult to understand and refactoring or renaming cannot fix it:

- **Non-obvious constraints or gotchas** — a workaround for an upstream bug, an ordering dependency, a magic value required by an external system, a subtle race condition. Things that would surprise a careful reader.
- **Complex, unintuitive logic** — a tricky algorithm, a dense bitwise/math operation, or a sort/comparison whose correctness isn't obvious from reading it. Explain the *why* and the intent, not the mechanics.
- **"Why," not "what"** — the reason a piece of code exists or takes an unusual shape, when the signature and names can't convey it.
- **Agent-steering comments** — comments that deliberately guide a future editor or AI agent (e.g. "keep in sync with X", "do not reorder — depends on Y", "intentionally not memoized because Z"). These are placed on purpose; do not remove them.

## Rules

1. **Do not remove a comment that appears to be there on purpose** to steer behavior, warn about a pitfall, or preserve intent. When a comment is load-bearing, leave it. If genuinely unsure whether a comment is deodorant or noise, keep it and flag it rather than deleting.
2. **Prefer refactoring over deleting-and-losing-meaning.** If a comment exists because a name is bad, consider whether renaming would let the comment go away cleanly. Do this only when the rename is safe and in scope; otherwise just leave the comment.
3. **Never change code behavior.** This is a comment-only cleanup unless a rename is trivially safe and clearly improves clarity.
4. **Don't touch comments that are part of the code's contract** — license headers, lint/type directives (`// eslint-disable`, `# type: ignore`, `# noqa`, `@ts-expect-error`), pragmas, codegen markers, shebangs.
5. When done, briefly summarize what was removed and why, and call out anything you kept-but-were-unsure-about.

## Workflow

1. Identify the scope — the file(s), the current diff, or the region the user pointed at. If unspecified, ask or default to the current working diff.
2. Read each comment and classify: deodorant (keep) vs. noise (remove) vs. load-bearing/steering (keep).
3. Remove the noise; leave everything else. Rename or restructure only when it's safe and clearly lets a comment disappear.
4. Report the result.
