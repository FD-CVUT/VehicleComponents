# Examples and platforms

An example's top level shows the vehicle's subsystems one level deep: driver, body, wheels,
brakes, powertrain, controllers and bus as separate blocks. Shared wiring lives in partial platform
bases in `Examples.Platforms`. An example extends a base, adds components and connections, changes
parameters, and swaps an inherited subsystem by redeclaration. A base holds only what every child
needs, since an inherited subsystem cannot be removed.

Examples and platforms are strict, and so are the bases and slot fillers they draw: see
`docs/agents/layout.md`. Every test model under `Examples` runs in the example tier:
see `docs/agents/tests.md`.

## Slots and redeclaration

A base declares each replaceable subsystem, a slot, with its interface as the constraint
(`driver::VehicleComponents.Driver.Interface = VehicleComponents.Driver.CoastDown()`), and the
compiler rejects a replacement missing one of its members (`incompatible-redeclaration`).

Redeclare only in the `extends` clause, together with the parameter changes:

```
extends VehicleComponents.Examples.Platforms.Longitudinal(driver = VehicleComponents.Driver.HardStop(), body(m = 1500.0))
```

A redeclaration at a declaration site (`sub = Child(inner = Other())`) compiles but is not applied.
`Examples.HardStop` is the reference.
