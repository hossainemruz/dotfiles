# Exploration Guidelines

**Purpose:** Find enough evidence to answer accurately with minimal context.

## Rules

- Start with the smallest useful tool; follow the shared Tool Routing guidance for search/navigation choices.
- Batch independent searches/reads.
- Read only needed files/sections; avoid full large files unless required.
- Ignore noisy/generated dirs (`node_modules`, `dist`, `build`, `.git`, caches) unless asked.
- Stop once evidence supports the answer. Do not scan unrelated areas “just in case”.
- Reuse gathered evidence; avoid repeated reads/searches.
- No edits, destructive commands, secret reads, or network unless explicitly required.
- If scope is unclear, ask the minimum clarification.

## Focused Analysis

When invoked with a diff/checklist, treat it as complete scope. Read touched files plus minimal context only. Return findings only: severity, title, `path:line`, impact, evidence, fix.

## Output Contract

- Location/pattern search: `path:line — symbol/thing — evidence`.
- Analysis: concise conclusion plus supporting file refs only.
- Findings: severity, title, `path:line`, impact, evidence, fix.
- No match/finding: say so directly.
- No search history, tool logs, or broad summaries unless requested.
