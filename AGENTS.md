# VehicleComponents

A Dyad library of vehicle components. The plan behind these rules is the spec,
FD-CVUT/VehicleComponents#1.

## Toolchain

- Load the `dyad-language` skill before reading or writing any `.dyad` file.
- Load the `forensic-debugging` skill when a compile, a test or a simulation fails and the error
  does not name the cause.
- Dyad sources live in `dyad/`, one folder per module. `generated/` is compiler output: change it
  only with `mise run compile`, and commit it in the same commit as the Dyad change that produced
  it.
- Run Julia as `scripts/dyad-julia --project=.`; only the Dyad build loads Dyad packages.
- `mise tasks` lists the commands. `mise run check` is the PR gate CI runs. Tasks and scripts need
  a POSIX shell (Linux, macOS, WSL).
- `DYAD_STUDIO_VERSION` in `mise.toml` pins the toolchain; changing it is a Dyad upgrade.
- Before upgrading Dyad, adding a dependency, or editing `.github/`, `scripts/` or `mise.toml`,
  read `docs/agents/toolchain.md`.

## Task docs

- Before bringing a component or domain over from the course repo, read `docs/agents/porting.md`.
- Before placing, moving or rewiring a part in any diagram, read `docs/agents/layout.md`.
- Before writing or changing a test model or a snapshot, read `docs/agents/tests.md`.
- Before writing an example or a platform, read `docs/agents/examples.md`.

## Module tree

```
Body.Longitudinal, Body.Planar
Chassis.Wheel, Chassis.Brakes
Powertrain.Engine, Powertrain.Transmission, Powertrain.Hybrid
Electrical.Machines, Electrical.PowerElectronics, Electrical.Battery
  Helpers          signal blocks one domain's components share; any domain may have one
Control            ABS, ESP, TCS, Cruise, brake allocation, regen blend
CanBus, Driver, Road, Sensors, Blocks
Gas                air hoses: the port, its conventions and its boundary sources, which the
                   brakes' vacuum and the engine's air path share
Examples
  Powertrain       ICE, BEV, Hybrid.Series, Hybrid.Parallel.P1/P2/P3/P4
  Chassis          ABS, ESP, TCS, Brakes
  Network.CanBus
  Energy.Charging
  Platforms        partial platform bases the examples extend
  HardStop         reference example of the platform pattern, until a domain example takes its role
```

The course's coupled hybrid is P0/P1 (P0 as a variant inside P1); its output hybrid is P3/P4.

The realtime drive, the human driver and the hardware extensions go in the second package,
`VehicleComponentsRealtime` under `lib/`, so `using VehicleComponents` stays light.

## Component rules

**Promotion.** A lecture component enters the library only if it has ports, models a real vehicle
part, controller, sensor or driver (not a teaching device), has no twin already in the library,
and arrives with its own test.

**Simplification.** If a general component only adds to a simple one, it extends it. If it
replaces part of the simple one's equations, keep only the general one, with a structural parameter
selecting the simple form. A reduction that only works numerically (a zero time constant) does not
count; then both stay.

**Naming.** A name leaves out what its module path already says (`Chassis.Brakes.MasterCylinder`).
Every public name is US English. Every rename of a course component gets its row in
`MIGRATION.md`, the old-to-new name table.

**Connections.** Every connection shows on the diagram: no `connect` inside an `if`, and no
conditional port or part. Every input is always wired, including one a case does not need: the
user feeds it its neutral value (0 for a flat road's `grade`). An output, and a mechanical end that
is free in the real part (zero force), may stay open. An equation that binds a part's input is a
hidden connection: time comes from a wired `BlockComponents.Sources.ContinuousClock`, not
`u = time`. To choose between signal paths by a structural parameter, route them through a gate
block whose ports always exist. When a model that places parts needs a calculation to feed a
part's input, that calculation is a block of its own, wired in; a component's constitutive
equations on its own variables and ports stay equations. Build it from stdlib blocks where they
cover it: a clamp is `BlockComponents.Nonlinear.Limiter` (parameter bounds) or `VariableLimiter`
(input bounds), and `Math.Min` / `Math.Max` compare two signals. A block written only to carry a
calculation the stdlib cannot express goes in `docs/agents/stdlib-upgrades.md`: a BlockComponents
release with an equation block replaces it.

**Helpers.** A signal block that only one domain's components use goes in that domain's `Helpers`
submodule (`Electrical.Battery.Helpers.CCCVVoltageCurrent`). One that several domains use goes in
`Blocks`.

**Docstrings.** Each component's docstring states what is modeled, its ports and its assumptions.

**Initial conditions.** A state's default initial value lives on the smallest component that owns
the state: on the variable (`variable a_pitch::Acceleration = initial 0.0`), or on the part that
holds it (`mass = Mass(m = m, s = initial 0.0, v = initial 0.0)` in `Body.Longitudinal.Vehicle`).
A stdlib part, whose source we do not change, gets its default the same way: on its declaration in
the smallest library component that places it, never through a wrapper component. A parent does
not repeat it. A parent or test that needs another start overrides it at the declaration, without a
new parameter: `climbing = Vehicle(mass(v = initial 10.0))`.

**Data.** Library data is referenced as `dyad://VehicleComponents/...` and ships in `assets/`.

**Icons.** Every public component with ports gets an icon, `Blocks` and `Helpers` included: the
generic block icon says nothing about what a block does. Use a stdlib icon only when it shows
exactly this component, ports included (`dyad://BlockComponents/To_kmh.svg` for `ToKmPerHour`);
the stdlib `Switch.svg`, for one, draws a Boolean control input. Otherwise draw one in the stdlib
style, in `assets/` under a path that mirrors its module path, with its lines meeting each port
where the component places it. Partials, tests and examples need none.

## Done

A PR that adds, moves or renames a component is done when every line holds for every component it
touches:

- [ ] `mise run check` passes, with `generated/` committed alongside the Dyad change.
- [ ] Every component rule applies: place in the module tree, name, docstring, data, icon; and its
  diagram meets `docs/agents/layout.md`.
- [ ] Each lecture component meets all four promotion conditions.
- [ ] Each renamed course component has its `MIGRATION.md` row.
- [ ] Every new or changed `.ref` file is committed and traces to a model change in this PR.
- [ ] A change that reaches an example passes `mise run test examples`.
