# `dyad artifacts retention sweep`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts retention sweep`

Evaluate retention rules and evict expired representation blobs

Evicts the blobs of artifacts whose matching rule has expired, and prints what
was evicted as JSON.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |

**Examples**

Run a sweep:

```
dyad artifacts retention sweep
```
