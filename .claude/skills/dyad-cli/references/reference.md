# `dyad reference`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad reference`

describe every command this CLI provides

Print a reference for the CLI itself, covering every command, its options and
its examples.

The Markdown form is meant to be committed as documentation; the JSON form is
the same data Clipanion exposes through `--clipanion=definitions`, which is the
machine-readable description of the whole CLI.

Because both are generated from the registered commands rather than maintained
separately, neither can describe a command that does not exist or omit one that
does.

| Option | Required | Description |
| --- | --- | --- |
| `--format #0` | no | Output format, one of: markdown, json |

**Examples**

Print the command reference as Markdown:

```
dyad reference
```

Emit the machine-readable description:

```
dyad reference --format json
```

Regenerate the committed reference:

```
dyad reference > COMMANDS.md
```
