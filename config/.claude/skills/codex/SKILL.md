---
name: codex
description: How to invoke the Codex CLI (gpt-5.6-sol) non-interactively by shelling out via Bash — to get a second opinion, review code, or delegate a self-contained task to another model. Use whenever the user asks to "ask codex", "run codex", "get codex's take", or when you want an independent model to review or cross-check work. Covers the exact flags, model/effort config, sandbox modes, and how to capture the output cleanly.
---

# Invoking Codex

Codex is OpenAI's CLI agent, installed locally as `codex` (`/opt/homebrew/bin/codex`). Shell out to it via `Bash` to get an independent second model on a task — code review, cross-checking a finding, or a self-contained delegated job. Default model is `gpt-5.6-sol`.

## The core command

Run non-interactively with `codex exec`. Write any long prompt to a file first, then:

```bash
codex exec \
  -m gpt-5.6-sol \
  -c model_reasoning_effort="xhigh" \
  -s read-only \
  --skip-git-repo-check \
  -o "$SCRATCH/codex-out.md" \
  "$(cat "$SCRATCH/codex-prompt.md")" < /dev/null
```

Then read `$SCRATCH/codex-out.md` for Codex's final answer. (`$SCRATCH` = your scratchpad dir.)

## Flags that matter

- `-m gpt-5.6-sol` — the model. This is the current default; omit to use the config default, or pass another id if asked.
- `-c model_reasoning_effort="xhigh"` — reasoning effort. Values: `low`, `medium`, `high`, `xhigh`. Use `xhigh` for hard review/reasoning tasks, lower for cheap/quick ones.
- `-s <mode>` — sandbox / write scope. Choose deliberately:
  - `read-only` — Codex can read files and run read-only commands but **cannot modify the tree**. Use for reviews, audits, and second opinions.
  - `workspace-write` — Codex may edit files within the working directory. Use only when you actually want it to make changes.
  - `danger-full-access` — no sandbox. Avoid unless explicitly required.
- `--skip-git-repo-check` — required, or Codex refuses to run non-interactively when the working dir isn't a Codex-trusted directory (`Not inside a trusted directory`). Safe to always include.
- `-o <file>` — write Codex's **final message** to this file. Much cleaner than scraping stdout, which is full of intermediate reasoning/tool events.
- `-C <dir>` — set Codex's working root (defaults to the current dir). Use to point it at a specific repo.
- `< /dev/null` — redirect stdin from nothing. Without it, `codex exec` blocks on `Reading additional input from stdin...`.
- `--json` — emit events as JSONL instead of prose, if you need to parse the run programmatically. Usually not needed when you use `-o`.

## Prompt construction

- Codex has repo read access and can open files itself — give it explicit scope (paths, diff range, the specific question) and let it read for context.
- Be explicit about the deliverable and format you want back, since the `-o` file is the raw final message with no further shaping.
- For a code review, hand it the same kind of adversarial mandate the `[[improvement-review]]` skill uses (correctness, security, over-complication, simplification, architecture, consistency).

## Running it well

- **Background long runs.** At `xhigh` a run can take minutes. Launch it with `Bash` `run_in_background: true` and collect the `-o` file when it completes, so other work (or a parallel Claude subagent) overlaps with it.
- **Handle absence/errors.** If the `codex` binary is missing or the command errors, report that and fall back rather than silently hanging. Check exit code; a nonzero exit with an empty `-o` file means the run failed (common causes: untrusted dir → add `--skip-git-repo-check`; blocked on stdin → add `< /dev/null`).
- **Don't let it write unless you mean it.** Default to `-s read-only`. Only use `workspace-write` when the task is explicitly to make edits, and review the diff afterward.

## Quick one-liner (short prompt, read-only opinion)

```bash
codex exec -m gpt-5.6-sol -c model_reasoning_effort="high" -s read-only \
  --skip-git-repo-check -o "$SCRATCH/codex-out.md" \
  "Review src/auth/session.ts for security issues and summarize the top 3." < /dev/null
```
