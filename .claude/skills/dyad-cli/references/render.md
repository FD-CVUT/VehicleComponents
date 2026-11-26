# `dyad render`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad render <component>`

render the diagram of a component as SVG

Render the diagram of a component definition, writing the SVG to stdout.

Only component definitions have a diagram; naming anything else is reported as
an error.

| Option | Required | Description |
| --- | --- | --- |
| `-d,--dir #0` | no | Directory of the Dyad library |

**Examples**

Render a component to a file:

```
dyad render DyadTutorial.Hello --dir DyadTutorial > Hello.svg
```
