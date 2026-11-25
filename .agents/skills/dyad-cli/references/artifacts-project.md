# `dyad artifacts project`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts project <urn> <sql>`

Tabular projection over a parquet or CSV artifact

Runs `<sql>` with the artifact's content exposed as the table `src`, and prints
the result as JSON. The projection is cached; `--force` re-executes it.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |
| `--force` | no | Re-execute even if a cached projection exists |

**Examples**

Select two columns:

```
dyad artifacts project urn:dyad:artifact:sha256-… "SELECT time, x FROM src"
```
