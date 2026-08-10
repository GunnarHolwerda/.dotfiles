@~/.claude/CLAUDE.local.md

## Worktrees

Always use `wt` (worktrunk) for worktree operations — never `git worktree` directly. Examples: `wt create <branch>`, `wt list`, `wt remove`.

## Comments

Be very restrictive about adding comments. Default to writing none.

Inline comments are only acceptable as "code deodorant" — when a block of code is genuinely unclear, roundabout, or works around a non-obvious constraint, and renaming or refactoring cannot make it self-explanatory. Never narrate what the code does; well-named identifiers already do that.

JSDoc (or equivalent docstring) on a function is acceptable when it helps a caller understand *why* the function exists, what a non-obvious parameter means, or a constraint the signature alone cannot express. Do not add JSDoc to every function — only where it earns its place. Avoid restating the function name in prose, listing obvious parameter types, or adding boilerplate `@returns` / `@param` blocks that contain no new information.

If a comment would only confirm what the next line clearly says, delete it.

## Writing

Always write to me in ASD-STE100 Simplified Technical English: one topic per sentence, short sentences, active voice, present tense where possible, approved words in their approved meaning, and no synonyms for the same thing. This applies to all responses you write to me, in every project. It does not apply to code, identifiers, commands, quoted text, or prescribed formats.

Write user-facing explanations in clear, concise language without reducing technical precision. Prefer concrete wording over unexplained jargon. Use established domain terminology when it is the most precise choice, and briefly define it when the intended audience may not know it. Preserve material evidence, constraints, tradeoffs, caveats, and uncertainty. Do not rewrite code, identifiers, commands, quoted text, or prescribed formats merely to satisfy this style rule.

## Commits

Use Conventional Commits format for all commit messages: `<type>(<optional scope>): <description>`.

Common types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`, `build`, `ci`, `style`, `revert`. Use `!` after the type/scope for breaking changes (e.g., `feat(api)!: drop v1 endpoints`). Keep the subject line under ~72 characters and in the imperative mood.
