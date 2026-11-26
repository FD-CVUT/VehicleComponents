# `dyad artifacts get`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts get <urn>`

Fetch artifact metadata, or its content with --out

Prints the artifact's metadata as JSON. With `--out`, writes its content to that
file instead; `--media-type` requests another representation, transcoding within
the JSON value-model family (JSON, TOML, YAML). Fails if the store has no such
artifact.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |
| `--out #0` | no | Write the content to this file |
| `--media-type #0` | no | Requested representation (transcodes within the value-model family) |

**Examples**

Print metadata:

```
dyad artifacts get urn:dyad:artifact:sha256-…
```

Fetch a TOML artifact as JSON:

```
dyad artifacts get urn:dyad:artifact:sha256-… --out params.json --media-type application/json
```
