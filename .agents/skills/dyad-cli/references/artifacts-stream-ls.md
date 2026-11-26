# `dyad artifacts stream ls`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts stream ls`

List streams

Prints streams, newest first, as a JSON array. `--state` filters by state:
awaiting_schema, open, sealed, discarded.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |
| `--state #0` | no | awaiting_schema \| open \| sealed \| discarded |

**Examples**

List all streams:

```
dyad artifacts stream ls
```

List open streams:

```
dyad artifacts stream ls --state open
```
