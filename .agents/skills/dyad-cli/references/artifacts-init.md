# `dyad artifacts init`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts init`

Initialize a store

Creates `dyad-store.json`, the DuckDB metadata database and the artifact
directory in `--dir` (default: the working directory). Fails if that directory
already holds a store.

| Option | Required | Description |
| --- | --- | --- |
| `--dir #0` | no | Root directory of the new store |

**Examples**

Initialize a store in the working directory:

```
dyad artifacts init
```

Initialize a store in ./my-store:

```
dyad artifacts init --dir my-store
```
