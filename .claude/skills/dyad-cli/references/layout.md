# `dyad layout`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad layout <component>`

lay out a component's diagram and write it back

Extract the component's layout problem, solve it, and write the solution into
the component's diagram metadata: `dyad layout extract`, `solve` and `apply` in
one step. `<component>` is `<Library>.<Module>.<Component>`, or just the
component's name for one at the top of the library in `--dir`.

Unlike `dyad render`, which only draws the diagram as it stands, this modifies
the source in place. On success the command prints `wrote <file>` on stdout,
naming the source file that defines the component.

Nothing is written when the solution leaves a required constraint unsatisfied or
a connection without a legal route; the exit status is then 1. Pass `--dry-run`
to solve and report without writing, and `--render` for a schematic SVG of the
result.

To tune a layout before writing it -- pinning components, aligning or ordering
them, changing the canvas -- use the three steps separately.

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
| `--render #0` | no | Write a schematic SVG of the solution to this file |
| `--dry-run` | no | Solve and report, but do not write the diagram |

**Examples**

Lay out a component's diagram:

```
dyad layout SimpleRLC --dir .
```

See the layout without writing it:

```
dyad layout SimpleRLC --dir . --dry-run --render layout.svg
```
