---
name: update-ticket
description: Reviews and improves a Linear issue by analyzing the requested ticket, related Linear context, and the codebase before updating the ticket. Use when asked to investigate, validate, clean up, or update a Linear ticket such as "update EM1-1872" or "take a look at this ticket and fix the description."
---

# Update Ticket

Use this workflow to turn a rough Linear ticket into a validated, implementation-ready issue. Treat the Linear issue identifier as the input; never assume a hard-coded ticket.

## Required Input

Identify the Linear issue from the user's request, such as `EM1-1872`, `ENG-42`, or a Linear issue URL. If no ticket is provided, ask for exactly one issue identifier or URL before continuing.

## Workflow

1. **Read the target ticket**
   - Fetch the issue with relations, customer needs, releases, attachments, and branch metadata when available.
   - Read comments because they often contain decisions that have not been copied into the description.
   - Extract the ticket's goal, proposed approach, acceptance criteria, code references, dependencies, and open questions.

2. **Gather related Linear context**
   - Inspect explicitly linked issues: blockers, blocked issues, related issues, duplicates, parent, and children when available.
   - If the issue belongs to a project, inspect the project, milestones, project documents, recent project status updates, and a small focused set of sibling issues in that project.
   - Determine whether the ticket is intended to be a standalone task or one part of a larger body of work.

3. **Validate against the codebase**
   - Explore the local repository enough to verify the ticket's assumptions, proposed files, APIs, names, and implementation approach.
   - Use exact searches for referenced symbols, paths, config keys, and error messages. Use behavior-level codebase search when the relevant area is conceptual rather than named.
   - Compare the ticket's proposed approach with nearby patterns and existing architecture. Do not make code changes unless the user separately asks for implementation.

4. **Decide whether to update or stop**
   - If the approach appears incorrect, materially incomplete, risky, or misaligned with the surrounding work, stop before editing the ticket. Tell the user the recommended approach, the evidence from Linear/code, and what should change.
   - If the approach is sound or only needs minor tweaks, update the Linear ticket directly.

5. **Update the ticket when appropriate**
   - Clean up incorrect or stale code references.
   - Clarify the problem statement, scope boundaries, acceptance criteria, dependencies, and how the ticket fits into the project or related tickets.
   - Preserve useful original context; do not discard relevant detail just to make the ticket shorter.
   - Mark uncertainty explicitly instead of inventing facts.
   - Avoid unrelated metadata changes such as assignee, priority, status, labels, or project unless the user requested them or they are necessary to reflect the ticket's true scope.
   - Add a short comment only when useful to explain the investigation or summarize non-obvious edits.

## Output

When finished, report one of these outcomes:

- **Updated**: Summarize what was changed in the ticket and the key validation evidence.
- **Stopped for approach change**: Explain the recommended approach and why the ticket should not be updated as written.
- **Blocked**: State the specific missing access, unclear input, or repository limitation that prevented a reliable update.

Keep the final response concise and include the ticket identifier.
