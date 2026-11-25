# `dyad artifacts query`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts query <sql>`

Create and execute a content-addressed SQL query resource

Creates a query resource for `<sql>`, runs it over the store's metadata tables,
and prints the query URN, execution time and rows as JSON. `--materialize` also
stores the result as a derived artifact.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |
| `--materialize` | no | Store the result as a derived artifact |

**Examples**

Count runs by analysis type:

```
dyad artifacts query "SELECT analysis_type, count(*) FROM runs GROUP BY ALL"
```

Materialize a result:

```
dyad artifacts query "FROM artifacts SELECT title" --materialize
```
