# `dyad artifacts signed-url`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts signed-url <urn>`

Mint a presigned content URL path

Prints a presigned path for the artifact's content, valid for `--ttl` seconds
(default 3600), as JSON. Requires `signingSecret` in `dyad-store.json`, and
fails if the store has no such artifact.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |
| `--ttl #0` | no | Validity window in seconds |

**Examples**

Mint a one-hour URL:

```
dyad artifacts signed-url urn:dyad:artifact:sha256-… --ttl 3600
```
