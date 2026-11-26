# Stdlib upgrades: library parts waiting on a standard-library release

Each row is a library component that stands in for something a later Dyad standard-library release
provides. When an upgrade brings that release, replace the component, rewire its users, and delete
the row.

## Calculation blocks → BlockComponents equation block

A model that places parts feeds a computed value to a part's input through a block of its own
(`AGENTS.md`, Connections). BlockComponents 5.0.0 has no block that takes an equation, so a
calculation the stdlib blocks cannot express becomes a small library block that exists only to
carry it. A BlockComponents release with an equation block replaces each one listed here. A named
component with its own docstring, icon and test (the `Helpers` blocks) is a component, not a
stand-in, and is not listed.

| Component | Computes |
|---|---|

## Flow restrictions → HydraulicComponents `TubeBase`

HydraulicComponents 3.0.0 registers the derivative of `friction_factor` with respect to `m_flow`
as 0 (`src/utils.jl`), so a `Pipes.TubeBase` without fluid inertia has a singular Jacobian at zero
flow and cannot start a circuit at rest; with fluid inertia it rings for seconds against a stiff
caliper. A HydraulicComponents release whose `TubeBase` starts from zero flow replaces each
component listed here.

| Component | Computes |
|---|---|
| `Chassis.Brakes.Line` | Laminar Hagen-Poiseuille pressure drop of a brake line |
