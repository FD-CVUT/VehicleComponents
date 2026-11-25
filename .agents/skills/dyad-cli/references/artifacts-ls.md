# `dyad artifacts ls`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts ls`

List artifacts

Prints artifacts, newest first, as a JSON array. `--limit` (default 50) caps the
count; `--format` filters by format.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |
| `--format #0` | no | Only artifacts of this format |
| `--limit #0` | no | Maximum number of results |

**Examples**

List the latest artifacts:

```
dyad artifacts ls
```

List up to 10 CSV artifacts:

```
dyad artifacts ls --format csv --limit 10
```
