# `dyad artifacts cache sweep`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts cache sweep`

Evict cached blobs beyond the size budget or TTL

Sweeps the read-through blob cache used for federation, evicting
least-recently-used blobs beyond the size budget and any past their TTL, and
prints what was evicted as JSON. Only cached copies are ever evicted.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |

**Examples**

Sweep the cache:

```
dyad artifacts cache sweep
```
