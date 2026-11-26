# Local review comments

These are comments in Devcroft's Review pane, not GitHub pull-request comments. Use the intended checkout, base branch, remote, and scope consistently when listing and changing comments.

```sh
devcroft review --checkout /path/to/checkout --base main --remote origin list --open
```

The default scope is the full branch diff. Add `--uncommitted` for comments on uncommitted changes. If the base is omitted it is inferred; use an explicit base when the user's Review pane context is known.

Listing emits a JSON array of objects with `comment` and `excerpt`; it takes no `--json` flag. Inspect the comment text, refreshed anchor, excerpt, ID, and numeric revision. Verify the current code at the anchor before editing, especially if the diff has changed.

Address the requested feedback, validate the change, then list again to inspect the latest comment state before resolving it:

```sh
devcroft review --checkout /path/to/checkout --base main --remote origin list --open
devcroft review --checkout /path/to/checkout --base main --remote origin resolve COMMENT_ID --revision REVISION
```

Replace the placeholders with the actual comment ID and revision from listing. Supply `--revision` to protect against concurrent edits. If it is stale, reread and inspect the new feedback before deciding whether resolution is still appropriate.

`reopen` and `delete` accept the same ID and revision arguments. Delete permanently removes a comment; use it only when requested. To inspect resolved comments, use `list --resolved`. Lifecycle commands signal success by exit status and do not return a JSON record. There is no review-comment creation CLI in this release.
