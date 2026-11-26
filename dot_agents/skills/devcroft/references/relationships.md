# Repository relationships

Repository relationships are portable descriptive knowledge. They do not inspect
source, verify that code still matches a description, or invoke an assistant.
Queries work without a desktop or linked checkout. Use stable repository keys.

Direction is **provider → consumer**. `api → backend` means backend depends on
api. A backend query reports api in `dependencies`, and consumers such as ui/cli
in `dependents`. Reverse queries retain the original descriptions; never create
reverse copies just to query dependents. An intentional reverse connection is
valid (cycles are allowed). Self-connections and duplicate ordered pairs fail.

```sh
devcroft repository relationships --json
devcroft repository relationships backend --json
devcroft repository relationships backend --depth 2 --json
devcroft repository relationships --space Work --json
```

Whole-graph results include isolated and unlinked repositories, descriptions,
spaces, metadata `revision` tokens, checkout availability, and unresolved
placeholders. Incoming/outgoing lists remain direct neighbors at every depth;
expanded `nodes` carry shortest undirected neighborhood `distance` and `path`.
`directions` classifies returned edges relative to the queried repository.
Depth is bounded to 1–8, node results to 1000, and the store to 5000 edges.
Always check `diagnostics`, `truncated`, and `excludedRelationships`. Space
filters affect reads only; default queries include all spaces, independently of
the desktop filter. Names match case-insensitively; `All` is a special filter
choice. A repository with no stored space counts as the default space
(`Personal` on a seeded catalog).

Read first and use the top-level graph `revision` for each mutation:

```sh
devcroft repository relationship create --from api --to backend --description-file relationship.txt --revision REV --json
devcroft repository relationship update EDGE_ID --to ui --description 'ui consumes backend services' --revision REV --json
devcroft repository relationship delete EDGE_ID --revision REV --json
```

`--description-file` accepts a UTF-8 file or `-` for stdin. Descriptions must be
nonblank and at most 16384 bytes. Updates preserve the ID and omitted fields.
On duplicate creation, edit the existing ID named in the error. On a stale
revision, reread and recompute the intended change; do not blindly retry using a
new token. Malformed/unsupported documents are never replaced with empty data.

Node purposes and spaces use the existing repository record. `repository get`
returns its metadata revision, also available on graph nodes:

```sh
devcroft repository get backend --json
devcroft repository update backend --description 'Implements the shared services' --space Work --revision METADATA_REV --json
```

Unspecified metadata flags preserve stored fields; an explicit empty string
clears a field. Repository removal requires deleting or rewiring its connections
first. Unlinking a checkout preserves all relationships. Externally removed
endpoints stay visible as unresolved connections and permit explicit cleanup.

Definitions live in `portable/repository-relationships.json`; node metadata lives
in `portable/repositories/<key>/repository.json`. Both participate in portable
Git sync. Canvas positions, zoom, pan, and per-space preferences stay in the
device-local `repository-graph-layout.json` outside portable data. Use the CLI
for records rather than editing these files directly.
