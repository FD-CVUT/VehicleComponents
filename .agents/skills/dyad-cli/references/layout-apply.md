# `dyad layout apply`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad layout apply <component>`

write a layout solution into a component's diagram

Write a solution from `dyad layout solve` into the component's diagram metadata.
`<component>` is `<Library>.<Module>.<Component>`, or just the component's name
for one at the top of the library in `--dir`. On success the command prints
`wrote <file>` on stdout, naming the source file that defines the component.

The solution is refused unless it was solved for this component, and the problem
is extracted from the model again: the solution is refused unless it was solved
for exactly the same components, connectors and connections, so a solution is
never written into a different diagram, or into one that has changed since.

| Option | Required | Description |
| --- | --- | --- |
| `-d,--dir #0` | no | Directory of the Dyad library |
| `-i,--input #0` | yes | The solution file ('-' for standard input) |

**Examples**

Write the chosen solution back:

```
dyad layout apply SimpleRLC --dir . -i /tmp/sol.json
```
