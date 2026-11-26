# `dyad artifacts lineage`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts lineage <urn>`

Walk the full upstream lineage of an entity

Prints every upstream node and edge of an artifact, run, query or other entity,
as JSON. Fails if the store has no such entity; one with no ancestors prints
`[]`.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |

**Examples**

Show the provenance of a run:

```
dyad artifacts lineage urn:dyad:run:…
```
