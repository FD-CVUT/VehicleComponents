# Diagram layout

Every component with parts has a diagram. Which rule it follows depends on whether it is
important.

## Which diagrams are strict

Important components get a strict layout. Important means everything under `Examples` (a
`test component` there included) and every platform, every component they place directly at their
top level, and any component whose docstring marks it as an exception.

Strictness follows what is drawn: a base whose placements appear on a strict diagram is strict,
and so is every component that fills a top-level slot, the default and each redeclared replacement
alike. `Body.Longitudinal.RoadLoad` is strict because `Vehicle` extends it, and `Driver.Scripted`
because its presets fill the platform's driver slot.

Every other diagram, every test model's outside `Examples` included, comes from autolayout.

## Strict layout

- Explicit non-overlapping positions.
- Signal flow left to right.
- Each physical chain's parts in their real order along one readable path, in any direction.
- Every connection routed orthogonally without crossing a block. A wire may run in from the edge
  to a stdlib icon's inset anchor.
- Ports on the icon on the side they appear in the diagram.
- A node shared by three or more ends is one multi-end `connect` whose `edges` and `junctions` are
  set by hand or in the Studio, as `TranslationalComponents.Sensors.Tests.RelativeSensors` does.

`dyad layout` misroutes a multi-end `connect`, so a strict model is laid out by hand only.

## Autolayout

The component needs correct connector placement on its icon (fixed to a specific spot where that
matters); its diagram comes from `dyad layout`. Write a signal that feeds several inputs as one
two-port `connect` per input: on a `connect` with three or more ends, `dyad layout` attaches
waypoints to the wrong branch and the Studio draws diagonals.

1. After adding or rewiring a part, run
   `node "$DYAD_CLI" layout VehicleComponents.<Module>.<Component> --dir .`. Done when the model
   has no part left unplaced.
2. On `connection(s) could not be routed legally`, look for a block with more than three ports on
   one edge: the layout grid gives a default-size block 2 cells per edge. Scale its placement up in
   both directions (250 x 250 for five ports, as `Electrical.Battery.Helpers.Tests.BalancerRequest`
   does), or give the component a wider or taller icon of its own, and rerun step 1.
3. When the one-step command still fails, pin the components with `dyad layout extract`, `solve`
   and `apply` (the `dyad-cli` skill has each command).

## Placements

A part's placement keeps its icon's aspect ratio: square for the default icon and for any
1000 x 1000 icon, otherwise the icon's own width to height. A placement stretched to another shape
draws the icon at its own shape inside a larger box, with the ports outside it.
