# `dyad artifacts search`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts search <text>`

Full-text search over descriptive fields

Prints up to 20 matches, best first, as JSON.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |

**Examples**

Search for "nominal":

```
dyad artifacts search nominal
```
