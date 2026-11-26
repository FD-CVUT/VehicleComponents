# `dyad artifacts add`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts add <file>`

Add a file as an artifact

Stores `<file>` as a content-addressed artifact and prints its URN, identity
kind, data class and whether it deduplicated against an existing artifact, as
JSON.

`--media-type` is required: it is the RFC 6838 media type of the content (for
example `image/png`, `application/vnd.apache.parquet` or
`application/vnd.dyad.time-series`), and it is never guessed, because tools that
display an artifact choose how by its media type and only you know what the
bytes are. Adding the same bytes again under a different media type fails.

The format, which decides how the content is parsed and hashed, is inferred from
the extension; `--format` overrides it, and unknown extensions are `binary`.
Markdown front matter, JSON/TOML/YAML `metadata` tables and CSV structure are
extracted and merged beneath the `--meta` values.

`--meta`, `--derived-from` are repeatable: give the flag once per value.
`--produced-by` marks the artifact as regenerable from that run. The run and
every parent must already exist in the store; otherwise nothing is added and the
command fails.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |
| `--media-type #0` | yes | RFC 6838 media type of the content, e.g. image/png (required; never inferred) |
| `--format #0` | no | Override the inferred format |
| `--title #0` | no | Title (default: the file name) |
| `--description #0` | no | Description |
| `--creator #0` | no | Creator |
| `--meta #0` | no | Metadata entry `key=value` (repeatable) |
| `--produced-by #0` | no | URN of the run that produced this artifact |
| `--derived-from #0` | no | URN of a parent artifact, query or stream (repeatable) |

**Examples**

Add a result file:

```
dyad artifacts add results.parquet --media-type application/vnd.apache.parquet
```

Add with a title and metadata:

```
dyad artifacts add results.parquet --media-type application/vnd.apache.parquet --title "sweep results" --meta experiment=rlc-sweep --meta owner=me
```

Add a file derived from two parents:

```
dyad artifacts add summary.csv --media-type text/csv --derived-from urn:dyad:artifact:… --derived-from urn:dyad:query:…
```
