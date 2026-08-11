---
name: claude-code
description: How to invoke Claude Code (claude) non-interactively by shelling out via Bash — to get a second opinion, review code, or delegate a self-contained task to another model. Use whenever the user asks to "ask claude", "run claude code", "get claude's take", or when you want an independent model to review or cross-check work. Covers the exact flags, model/effort selection, how to keep the run read-only, and how to capture the output cleanly.
---

# Invoking Claude Code

Claude Code is Anthropic's CLI agent, installed locally as `claude`. Shell out to it via `Bash` to get an independent second model on a task — code review, cross-checking a finding, or a self-contained delegated job. It reads the repo itself, so give it scope and let it explore.

## The core command

Run non-interactively with `-p`. Write any long prompt to a file first, then:

```bash
claude -p "$(cat "$SCRATCH/claude-prompt.md")" \
  --model opus \
  --effort xhigh \
  --tools "Read,Grep,Glob" \
  --permission-mode bypassPermissions \
  --output-format text \
  < /dev/null > "$SCRATCH/claude-out.md" 2>&1
```

Then read `$SCRATCH/claude-out.md` for the final answer. (`$SCRATCH` = your scratchpad dir.)

Unlike `codex exec`, `-p` prints **only** the final message — there is no intermediate reasoning or tool chatter on stdout, so a plain redirect is enough and there is no `-o` flag to reach for.

## Flags that matter

- `--model <name>` — `opus`, `sonnet`, `fable`, or a full id like `claude-opus-5`. Use `opus` for hard review and reasoning, `sonnet` for cheap mechanical work.
- `--effort <level>` — reasoning effort: `low`, `medium`, `high`, `xhigh`, `max`. Match it to the task, the same way you pick `model_reasoning_effort` for Codex.
- `--tools <list>` — restrict the built-in toolset. **This is how you make a run read-only.** `"Read,Grep,Glob"` lets it explore the repo but gives it no way to edit and no shell. `""` disables all tools for a pure reasoning question.
- `--permission-mode <mode>` — `manual` (default), `acceptEdits`, `bypassPermissions`, `dontAsk`, `plan`. In `-p` mode nobody can answer a prompt, so a run that needs approval stalls or fails. Pair a narrow `--tools` with `bypassPermissions` so the allowed tools run unattended.
- `--add-dir <dirs...>` — grant access to directories outside the working dir.
- `--output-format <fmt>` — `text` (default), `json` (one result object), or `stream-json`. Use `json` when you want `total_cost_usd`, `num_turns`, `is_error`, or `session_id` alongside `result`.
- `--json-schema <schema>` — validate structured output against a JSON Schema. Use when you need to parse the answer rather than read it.
- `--max-budget-usd <amount>` — hard cap on what a run may spend. Worth setting when you hand over an open-ended task.
- `--append-system-prompt <text>` — bolt an extra mandate onto the default system prompt, for example an adversarial review stance.
- `< /dev/null` — redirect stdin from nothing. Without it the run waits ~3s for stdin, then prints `Warning: no stdin data received in 3s, proceeding without it`. It costs you that delay on every call.
- `-r` / `--resume <id>` — resume a specific run by session id. `-c` / `--continue` is a different flag: it continues the most recent conversation in the current directory. With `--output-format json` you get the `session_id` back, so a follow-up question can reuse the context instead of paying for it again.

**Do not use `--dangerously-skip-permissions`.** `--permission-mode bypassPermissions` with a narrow `--tools` list gives you an unattended run without handing over the whole machine.

## Choosing the write scope

Claude Code has no single sandbox flag. The tool list is the control:

- **Read-only** (reviews, audits, second opinions): `--tools "Read,Grep,Glob"`. No `Bash`, no `Edit`, no `Write`.
- **Read-only plus shell**: add `Bash` only when the task truly needs to run commands. `Bash` can write files, so this is no longer read-only.
- **Allowed to edit**: `--tools "Read,Grep,Glob,Edit,Write,Bash"` with `--permission-mode acceptEdits`. Use only when the task is to make changes, and review the diff afterward.

## Prompt construction

- Claude Code reads files itself — give it explicit scope (paths, a diff range, the specific question) rather than pasting large context.
- Be explicit about the deliverable and the format you want back. Nothing shapes the output after the fact.
- For a code review, hand it an adversarial mandate: correctness, security, over-complication, simplification, architecture, consistency.

## Running it well

- **Never pipe the run through `tail`, `head`, or `tee`.** Redirect to a file and read the file. A filter in the pipeline buffers the stream, so you lose the completion signal and cannot tell a finished run from a running one.
- **Background long runs.** At `--effort xhigh` a run takes minutes. Launch it in the background and collect the output file when it finishes, so other work overlaps with it.
- **Check for failure.** With `--output-format json`, `is_error` and `permission_denials` tell you whether the run actually did the job. An empty output file with a nonzero exit means the run failed; the usual cause is a tool the run needed but `--tools` did not grant.
- **Do not let it write unless you mean it.** Default to the read-only tool list.

## Quick one-liner (short prompt, read-only opinion)

```bash
claude -p "Review src/auth/session.ts for security issues and summarize the top 3." \
  --model opus --effort high --tools "Read,Grep,Glob" \
  --permission-mode bypassPermissions > "$SCRATCH/claude-out.md" 2>&1
```
