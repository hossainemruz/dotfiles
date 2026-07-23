# Exploration Guidelines

**Purpose:** Gather semantic codebase evidence accurately with minimal context.

## Rules

- Start with the smallest useful tool; follow the shared Tool Routing guidance for search/navigation choices.
- Batch independent searches/reads.
- Read only needed files/sections; avoid full large files unless required.
- Ignore noisy/generated dirs (`node_modules`, `dist`, `build`, `.git`, caches) unless asked.
- Stop once evidence supports the answer. Do not scan unrelated areas “just in case”.
- Reuse gathered evidence; avoid repeated reads/searches.
- No edits, destructive commands, secret reads, or network unless explicitly required.
- If scope is unclear, ask the minimum clarification.
- Explore symbols, definitions, references, call paths, patterns, and nearby implementation context. Do not perform code review, rank severity, or prescribe findings.

## Output Contract

- Location/pattern search: `path:line — symbol/thing — evidence`.
- Semantic question: concise conclusion with supporting `path:line` references.
- No match or insufficient evidence: say so directly.
- No search history, tool logs, or broad summaries unless requested.
