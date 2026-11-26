# `dyad layout solve`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad layout solve`

solve a layout problem file

Solve a problem written by `dyad layout extract`, as edited since, and write the
solution as JSON for `dyad layout apply`. Nothing in the model is touched, so
this can be run as often as it takes.

A summary goes to standard error: crossings, wire length and turns, and every
constraint that was dropped, unsatisfiable or had no effect. The exit status is
1 when a required constraint cannot be satisfied or a connection has no legal
route; the solution is written either way, so it can be inspected.

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
| `-i,--input #0` | yes | The problem file ('-' for standard input) |
| `-o,--output #0` | no | Where to write the solution (default: standard output) |
| `--render #0` | no | Write a schematic SVG of the solution to this file |

**Examples**

Solve, and look at the result:

```
dyad layout solve -i /tmp/prob.json -o /tmp/sol.json --render sol.svg
```
