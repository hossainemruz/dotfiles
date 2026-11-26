---
name: delete-comments
description: Audit and clean up code comments in a codebase or a targeted section of code by categorizing each comment as Tautology, Excuse, Stale, or Decision Record, deleting unnecessary comments, filing issues for hacky workarounds, and moving important architectural decisions into ADRs. Use when the user asks to audit, clean up, or delete code comments.
---

# Delete Comments

Take a look at every code comment in the requested scope (the codebase or the specified section of code).

## Categorisation

Categorise each comment as:

- **Tautology**: simply repeats what is already visible from the code
- **Excuse**: many comments allow the agent to get away with a hacky implementation, which then gets propagated through the code
- **Stale**: references code or implementation information that is no longer relevant
- **Decision Record**: documents an important, non-obvious decision about the code

## Actions

For each comment, take this action:

- **Tautology / Stale**: delete the comment
- **Excuse**: delete the comment and file an issue to fix the hacky implementation
- **Decision Record**: move it into an ADR

## Workflow Notes

1. **Scope**: Review every comment within the requested files, directories, or codebase (skipping vendored, generated, and third-party files unless explicitly requested).
2. **Filing issues for Excuses**: Use the repository's issue tracker (e.g., `gh issue create` for GitHub repos) to file an issue describing the hacky implementation, its location, and the desired fix. If no issue tracker is accessible, report the drafted issues clearly so the user can file them.
3. **Writing ADRs for Decision Records**: Look for an existing ADR directory (e.g., `docs/adr/`, `docs/decisions/`, or `adr/`) and follow its numbering and format; otherwise create `docs/adr/`. Record the decision in an ADR and remove the comment from the code.
4. **Summary**: Report the reviewed comments by category, files modified, issues filed, and ADRs created or updated.
