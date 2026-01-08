---
description: Generate a handoff prompt to continue work in a new thread
---

The user wants to hand off the current work to a new thread with the following goal:

**Goal:** $ARGUMENTS

Your task is to analyze this entire conversation and generate a comprehensive handoff prompt that can be used to start a new Claude Code thread. The new thread should have all the context needed to continue working toward the specified goal.

## Instructions

1. **Analyze the conversation** to identify:
   - What work has been completed
   - Key decisions that were made and why
   - Important context about the codebase, architecture, or constraints
   - Any gotchas, edge cases, or issues discovered
   - Relevant file paths and their purposes

2. **Generate a handoff prompt** with this structure:

```
## Context

[Summarize the relevant background, what was worked on, and current state]

## Key Files

[List the most relevant files for the new goal with brief descriptions]
- `path/to/file.ts` - description of what it does/contains

## Important Details

[Include any critical information: decisions made, constraints discovered, patterns to follow, things to avoid]

## Goal

[Restate and clarify the goal for the new thread]

## Suggested Next Steps

[Provide 2-4 concrete next steps to accomplish the goal]
```

3. **Copy to clipboard** using `pbcopy` on macOS (or `xclip`/`xsel` on Linux) so the user can immediately paste it into a new thread.

4. **Also display the prompt** so the user can review it before pasting.

## Guidelines

- Be concise but comprehensive - include everything needed, nothing extra
- Focus on information relevant to the specified goal
- Include specific file paths, function names, and code patterns when relevant
- Preserve any important constraints or requirements discovered during the conversation
- Make the prompt self-contained so the new thread needs no additional context

## Clipboard

After generating the prompt, copy it to the clipboard using a bash command like:
```bash
echo "YOUR_GENERATED_PROMPT" | pbcopy
```

Then confirm to the user that it has been copied and is ready to paste into a new thread.
