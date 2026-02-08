---
description: Generate a handoff prompt to continue work in a new thread
---

The user wants to hand off the current work to a new thread.

**User's goal for the new thread:** $ARGUMENTS

If $ARGUMENTS is empty, vague (e.g., "continue", "fix"), or less than a few words, ask the user to provide a more specific goal before proceeding. A good goal describes what they want to accomplish next.

Use the Task tool to spawn a sub-agent with `subagent_type: "general-purpose"` and `model: "haiku"`. The sub-agent has access to the current conversation context.

Give the sub-agent this prompt:

---

Extract relevant context from the conversation above for continuing this work in a new thread.

## What to Extract

### Relevant Files

Identify files from the conversation that are:
- Directly related to accomplishing the goal below
- Contain reference code or patterns to follow
- Will need to be read, edited, or created
- Provide important context or constraints

**Only include files that were actually mentioned, read, or edited in this conversation.** Do not guess or infer file paths that weren't explicitly referenced.

### Relevant Information

Consider what would be useful to know based on the user's goal below. Questions that might be relevant:
- What was just done or implemented?
- What instructions did the user give that are still relevant (e.g., follow certain patterns, use specific libraries)?
- Was there a plan or spec that should be carried forward?
- What important constraints or preferences were stated (libraries, patterns, conventions)?
- What technical details were discovered (APIs, methods, architecture)?
- What caveats, limitations, or open questions came up?
- What commands need to be run (build, test, lint)?

## Output Format

Output ONLY the following, nothing else:

```
## Key Files

- `path/to/file.ts` - brief description of relevance
- ...

## Context

[Extracted relevant information as concise bullet points. Include decisions made, constraints discovered, patterns to follow, things to avoid. Do not write new instructions — only extract what was discussed.]

## Goal

$ARGUMENTS
```

## Guidelines

- Extract, don't generate. Pull information from the conversation rather than writing new instructions.
- Be concise — include everything needed, nothing extra.
- Prioritize files by importance to the goal.
- Preserve specific details: function names, API endpoints, config values, error messages.
- The user's goal statement IS the instruction. Don't rephrase or expand it.

---

Once the sub-agent returns the handoff prompt, copy it to the clipboard using `pbcopy` on macOS (or `xclip`/`xsel` on Linux), then show the user the generated prompt and confirm it has been copied. Remind them they can edit it after pasting into the new thread.
