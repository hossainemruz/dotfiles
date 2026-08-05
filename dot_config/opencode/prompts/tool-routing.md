# Tool Routing

- Prefer indexed or semantic discovery before raw text search. Use FFF for file/content lookup and `lsp` for symbol definitions, references, types, implementations, and call relationships.
- Use `glob` for exact patterns and `grep` for regex-heavy or fallback searches. Use repository structural-search tooling only when indexed tools and LSP cannot answer reliably.
- Read only the files or ranges identified by discovery.
- Do not use Bash `grep`, `find`, or `cat` for code discovery unless dedicated tools are insufficient.
