# `dyad flatten`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad flatten <component>`

output a flattened definition

Output a definition with everything it extends merged into it; its subcomponents
and connections are left as written. The result is written to stdout.

Pass `--strip` to drop metadata from the flattened definition, which makes the
structural content easier to read.

| Option | Required | Description |
| --- | --- | --- |
| `-d,--dir #0` | no | Directory of the Dyad library |
| `-s,--strip` | no | Strip metadata from the flattened definition |

**Examples**

Flatten a component:

```
dyad flatten DyadTutorial.Hello --dir DyadTutorial
```

Flatten it without metadata:

```
dyad flatten DyadTutorial.Hello --dir DyadTutorial --strip
```
