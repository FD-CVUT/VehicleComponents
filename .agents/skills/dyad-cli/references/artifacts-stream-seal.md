# `dyad artifacts stream seal`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts stream seal <urn>`

Seal a stream into a content-addressed artifact

Seals the stream and prints the result, including the new artifact's URN, as
JSON. Fails if the store has no such stream.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |

**Examples**

Seal a stream:

```
dyad artifacts stream seal urn:dyad:stream:…
```
