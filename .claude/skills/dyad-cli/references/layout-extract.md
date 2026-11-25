# `dyad layout extract`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad layout extract <component>`

write a component's layout problem to a file

Write the layout problem for the component's diagram as JSON, for `dyad layout
solve`. `<component>` is `<Library>.<Module>.<Component>`, or just the
component's name for one at the top of the library in `--dir`.

Components are seeded with where the diagram draws them, and boundary ports are
pinned where they are; nothing else is constrained.

A problem file (`dyad-layout/problem@1`) has a `structure` section -- the
components, their connectors and the connections, as the model defines them --
which must not be edited: it is fingerprinted, and a problem or solution whose
structure has changed is refused. The `settings` (canvas size, solver options),
`hints` (importance, preferred edges, starting positions) and `constraints`
(pin, orientation, align, order, straighten, portEdge, bump, each with a
strength) are the parts to edit. The file's JSON Schema ships with the solver as
`@juliacomputing/dyad-layout/schema/problem.schema.json`.

| Option | Required | Description |
| --- | --- | --- |
| `-d,--dir #0` | no | Directory of the Dyad library |
| `-o,--output #0` | no | Where to write the problem (default: standard output) |

**Examples**

Extract a problem to work on:

```
dyad layout extract SimpleRLC --dir . -o /tmp/prob.json
```
