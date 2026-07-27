# Tool Routing

- Prefer semantic/indexed tools before raw text search when they fit.
- Use `fff_find_files` for finding files by name/path. Use `glob` only for exact glob patterns or when fff is unavailable.
- Use `fff_grep` / `fff_multi_grep` for identifier, symbol, filename-filtered, or repo-wide content search. Use `grep` only for regex-heavy searches or fallback.
- Use `lsp` for go-to-definition, references, hover/type info, document symbols, workspace symbols, implementations, and call hierarchy when a symbol location is known.
- For structural searches that FFF and LSP cannot answer reliably, use the repository's existing structural-search tooling when available; otherwise use the smallest targeted fallback.
- Use `read` after search results identify the specific files/line ranges.
- Do not use `bash` with grep/find/cat for code discovery unless the dedicated tools are insufficient.
