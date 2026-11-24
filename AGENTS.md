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

## Module tree

```
Body.Longitudinal, Body.Planar
Chassis.Wheel, Chassis.Brakes
Powertrain.Engine, Powertrain.Transmission, Powertrain.Hybrid
Electrical.Machines, Electrical.PowerElectronics, Electrical.Battery
  Helpers          signal blocks one domain's components share; any domain may have one
Control            ABS, ESP, TCS, Cruise, brake allocation, regen blend
CanBus, Driver, Road, Sensors, Blocks
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
conditional port or part. A port that a case does not need stays and is always wired, and the
user feeds it its neutral value (0 for a flat road's `grade`). To choose between signal paths by a
structural parameter, route them through a gate block whose ports always exist. When the value a
port needs takes a calculation, that calculation is a block of its own, wired in.

**Helpers.** A signal block that only one domain's components use goes in that domain's `Helpers`
submodule (`Electrical.Battery.Helpers.CCCVVoltageCurrent`). One that several domains use goes in
`Blocks`.

**Docstrings.** Each component's docstring states what is modeled, its ports and its assumptions.

**Initial conditions.** A state's default initial value lives on the smallest component that owns
the state: on the variable (`variable a_pitch::Acceleration = initial 0.0`), or on the part that
holds it (`mass = Mass(m = m, s = initial 0.0, v = initial 0.0)` in `Body.Longitudinal.Vehicle`).
A parent does not repeat it. A parent or test that needs another start overrides it at the
declaration, without a new parameter: `climbing = Vehicle(mass(v = initial 10.0))`.

**Data.** Library data is referenced as `dyad://VehicleComponents/...` and ships in `assets/`.

**Icons.** Every public component with ports gets an icon, `Blocks` and `Helpers` included: the
generic block icon says nothing about what a block does. Use a stdlib icon only when it shows
exactly this component, ports included (`dyad://BlockComponents/To_kmh.svg` for `ToKmPerHour`);
the stdlib `Switch.svg`, for one, draws a Boolean control input. Otherwise draw one in the stdlib
style, in `assets/` under a path that mirrors its module path, with its lines meeting each port
where the component places it. Partials, tests and examples need none.

**Layout.** Important components get a strict diagram layout. Important means every example and
platform, every component they place directly at their top level, and any component whose
docstring marks it as an exception. Strict layout is: explicit non-overlapping positions, signal
flow left to right, physical chains in physical order, every connection routed orthogonally
without crossing a block, and ports on the icon on the side they appear in the diagram. Every other
component needs correct connector placement on its icon (fixed to a specific spot where that
matters). Its diagram, and every test model's, comes from autolayout: run
`node "$DYAD_CLI" layout VehicleComponents.<Module>.<Component> --dir .` after adding or rewiring
a part, and never leave a model with parts unplaced. Write a signal that feeds several inputs as
one two-port `connect` per input: on a `connect` with three or more ends, `dyad layout` attaches
waypoints to the wrong branch and the Studio draws diagonals. A part's placement in a diagram keeps
its icon's aspect ratio: square for the default icon and for any 1000 x 1000 icon, otherwise the
icon's own width to height. A placement stretched to another shape draws the icon at its own
shape inside a larger box, with the ports outside it. The layout grid gives a default-size block 2
cells per edge, so a block with more than three ports on one edge fails to route
(`connection(s) could not be routed legally`); scale its placement up in both directions (250 x 250
for five ports, as `Electrical.Battery.Helpers.Tests.BalancerRequest` does), or give the component
a wider or taller icon of its own. When the one-step command still fails, pin the components with
`dyad layout extract`, `solve` and `apply` (see the `dyad-cli` skill).

**Examples and platforms.** An example's top level shows the vehicle's subsystems one level deep:
driver, body, wheels, brakes, powertrain, controllers and bus as separate blocks. Shared wiring
lives in partial platform bases in `Examples.Platforms`. An example extends a base, adds components
and connections, changes parameters, and swaps an inherited subsystem by redeclaration. A base
holds only what every child needs, since an inherited subsystem cannot be removed.

A base declares each replaceable subsystem with its interface as the constraint
(`driver::VehicleComponents.Driver.Interface = VehicleComponents.Driver.CoastDown()`), and the
compiler rejects a replacement missing one of its members (`incompatible-redeclaration`). Redeclare
only in the `extends` clause, together with the parameter changes:
`extends VehicleComponents.Examples.Platforms.Longitudinal(driver = VehicleComponents.Driver.HardStop(), body(m = 1500.0))`.
A redeclaration at a declaration site (`sub = Child(inner = Other())`) compiles but is not applied.
`Examples.HardStop` is the reference.

## Tests

A rig is one test model with all its cases. Assert only on external behavior: the signals and
values a model exposes. Prefer a physically meaningful number (master-cylinder pressure at a given
pedal force, stopping distance, final SoC).

- **Main seam: Dyad test models.** Each case pins `solver`, `abstol` and `reltol`, and checks start
  and end values in its `tests` metadata; a named-signal snapshot only for what those cannot show.
  To check one component at several inputs, wire one instance to constant sources and give each
  case its own `params` (`{"voltage.k": 400.0}`), rather than placing several instances that share
  sources. A case can also override a start with `initial` (`{"body.mass.v": 10.0}`).
- **Second seam: plain Julia test sets** against the public Julia API, only for what a test model
  cannot express (OpenCRG reading, CAN frame encoding and decoding, the realtime drive headless).

Two tiers, chosen by where the test model lives:

| Tier | Test models | Runs | Budget |
|---|---|---|---|
| fast | in a `Tests` submodule of its domain or subdomain (`Chassis.Brakes.Tests`) | every PR and push to `main`, one process | 30 s per rig, under 10 min in all |
| example | under `Examples` | nightly, one process per model | under 60 min |

Place every test model in one of the two; the fast tier fails on a test model anywhere else, and
on any rig over budget. A rig that needs longer is an example, or a sign the component's test is
too big. CI runs the example tier only nightly, so run `mise run test examples` yourself when a
change reaches an example.

The library starts with zero pinned failures, and a new failure gets fixed.

## Snapshots

Snapshots are committed under `test/snapshots/`, mirroring the module path. A snapshot changes in
the same PR as the model change that moves it: rerun the affected tier with `DYAD_UPDATE_REFS=1`
and commit the new `.ref` files, so the reviewer sees every output change. A test model run
without a committed snapshot seeds one and fails its tier; commit the seeded file with the model.

## Done

A PR that adds, moves or renames a component is done when every line holds for every component it
touches:

- [ ] `mise run check` passes, with `generated/` committed alongside the Dyad change.
- [ ] Every component rule applies: place in the module tree, name, docstring, data, icon, layout.
- [ ] Each lecture component meets all four promotion conditions.
- [ ] Each renamed course component has its `MIGRATION.md` row.
- [ ] Every new or changed `.ref` file is committed and traces to a model change in this PR.
- [ ] A change that reaches an example passes `mise run test examples`.
