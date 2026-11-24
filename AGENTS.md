# AGENTS.md

Rules for adding to VehicleComponents, for agents and humans alike. The plan behind them is the
spec, FD-CVUT/VehicleComponents#1.

## Dyad language and toolchain

`dyad create` installed the Dyad agent resources (language docs, standard library reference,
skills) in `agent_resources/`, which is not committed. The pointers in `.claude/skills/` and
`.agents/skills/` lead there. Read `agent_resources/skills/dyad-language/SKILL.md` before writing
Dyad. If `agent_resources/` is missing, restore it with `dyad install skills --project .`.

- Dyad sources live in `dyad/`, one folder per module. `generated/` is compiler output: never edit
  it, always commit it in the same commit as the Dyad change that produced it (`mise run compile`).
- Run Julia from the Dyad build: `julia +dyad-<kernel> --project=.`, where `<kernel>` is
  `[dyad] kernel` in `Project.toml`. The default `julia` channel cannot load Dyad packages.

## Version pin

`DYAD_STUDIO_VERSION` in `mise.toml` is the one line that pins the toolchain. It names the Dyad
Studio release (the VSIX on Open VSX) whose compiler generates `generated/`. CI derives the rest:

1. downloads that VSIX and runs its `extension/out/dyad-cli.js` with Node,
2. reads the kernel version the compiler reports (`dyad-cli.js --version`, e.g. `3.5.0`),
3. requires `[dyad] kernel` in `Project.toml` to equal it, and
4. installs juliaup channel `dyad-<kernel>` from `https://juliahub.com/juliabin`.

The Studio version and the kernel version differ (Studio 3.5.1 carries kernel 3.5.0), which is why
the pin names the Studio release and the channel comes from the compiler, not from the pin.

Upgrade Dyad only through the extension, in a PR of its own: let the extension migrate the
project, bump `DYAD_STUDIO_VERSION` to the installed Studio version, regenerate `generated/`, and
commit all three together. `mise run check` fails when the pin, `Project.toml` and `generated/`
disagree.

## Module tree

```
Body.Longitudinal, Body.Planar
Chassis.Wheel, Chassis.Brakes
Powertrain.Engine, Powertrain.Transmission, Powertrain.Hybrid
Electrical.Machines, Electrical.PowerElectronics, Electrical.Battery
Control            ABS, ESP, TCS, Cruise, brake allocation, regen blend
CanBus, Driver, Road, Sensors, Blocks
Examples
  Powertrain       ICE, BEV, Hybrid.Series, Hybrid.Parallel.P1/P2/P3/P4
  Chassis          ABS, ESP, TCS, Brakes
  Network.CanBus
  Energy.Charging
  Platforms        partial platform bases the examples extend
```

Every domain or subdomain with tests has a `Tests` submodule (`Chassis.Brakes.Tests`). The coupled
hybrid is P0/P1 (P0 as a variant inside P1); the output hybrid is P3/P4.

The realtime drive, the human driver and the hardware extensions belong in a second package,
`VehicleComponentsRealtime` under `lib/`, never in this one, so `using VehicleComponents` stays
light.

## Structural rules

**Promotion.** A lecture component enters the library only if it has ports, models a real vehicle
part, controller, sensor or driver (not a teaching device), has no twin already in the library,
and arrives with its own test.

**Simplification.** If a general component only adds to a simple one, it extends it. If it
replaces part of the simple one's equations, keep only the general one, with a structural parameter
selecting the simple form. A reduction that only works numerically (a zero time constant) does not
count; then both stay.

**Naming.** No folder prefix repeated in a name (`Chassis.Brakes.MasterCylinder`, not
`Chassis.Brakes.BrakeMasterCylinder`). US English in every public name. Every rename of a course
component gets its row in `MIGRATION.md`, the old-to-new name table.

**Examples and platforms.** An example's top level shows the vehicle's subsystems one level deep:
driver, body, wheels, brakes, powertrain, controllers and bus as separate blocks, never one opaque
car block. Shared wiring lives in partial platform bases in `Examples.Platforms`. An example extends
a base, adds components and connections, changes parameters, and swaps an inherited subsystem by
redeclaration. A base holds only what every child needs, since an inherited subsystem cannot be
removed.

**Layout.** Important components get a strict diagram layout. Important means every example and
platform, every component they place directly at their top level, and any component whose
docstring marks it as an exception. Strict layout is: explicit non-overlapping positions, signal
flow left to right, physical chains in physical order, every connection routed orthogonally
without crossing a block, and ports on the icon on the side they appear in the diagram. Every other
component needs correct connector placement on its icon (pinned to a specific spot where that
matters); its diagram may be auto-laid-out.

**Icons.** Every public component with ports gets its own icon, in `assets/` under a path that
mirrors its module path. Partials, tests, examples and `Blocks` utilities do not.

**Docstrings.** Each component's docstring states what is modeled, its ports and its assumptions.

**Data.** Library data is referenced as `dyad://VehicleComponents/...` and ships in `assets/`.

## Tests

A test checks external behavior only: the signals and values a model exposes, never its internal
structure. A physically meaningful number (master-cylinder pressure at a given pedal force,
stopping distance, final SoC) beats a structural assertion.

- **Main seam: Dyad test models.** Each one sets fixed solver settings and checks start values, end
  values and named-signal snapshots in its `tests` metadata. The compiler turns them into
  `generated/**/<Model>_test.jl`, which `test/runtests.jl` runs.
- **Second seam: plain Julia test sets** against the public Julia API, only for what a test model
  cannot express (OpenCRG reading, CAN frame encoding and decoding, the realtime drive headless).

Two tiers, chosen by where the test model lives:

| Tier | Test models | Runs | Budget |
|---|---|---|---|
| fast | in a domain's `Tests` submodule | every PR, one process | 30 s per rig, under 10 min in all |
| example | under `Examples` | before merging a PR that touches an example, one process per model | under 60 min |

A test model anywhere else fails the fast tier. The fast tier warms the compiler up on a one-state
model first, then times each rig (one test model, all its cases) and fails any over 30 s. A rig
that needs longer is an example, or a sign the component's test is too big.

Run `mise run test` and `mise run test:examples`, or `julia +dyad-<kernel> --project=.
test/runtests.jl fast|examples`.

The library starts with zero pinned failures, and new failures are fixed, not pinned.

## Snapshots

Snapshots are committed under `test/snapshots/`, mirroring the module path. They change only on
purpose, in the same PR as the model change that moves them: rerun the affected tier with
`DYAD_UPDATE_REFS=1` and commit the new `.ref` files, so the reviewer sees every output change. A
test model run without a snapshot writes one; commit it with the model.

## PR gate

Every PR passes `mise run check` on the author's machine before review, and its description says
so. The check runs the fast tier and the generated-code check, which compiles from an empty
`generated/` (the compiler leaves a deleted module's files in place) and fails on any difference
from the committed code. A PR that touches an example also passes `mise run test:examples`.

## CI

The `CI` and `Nightly` workflows run only by manual dispatch, so no check on a PR shows a result
that never ran. The repo has no long-term JuliaHub token, and the Dyad dependencies resolve only
through the authenticated JuliaHub package server. Once a long-term token is issued (request one
from admin@juliahub.com for a dedicated CI user), store it base64-encoded as `JULIAHUB_AUTH_TOML`
and restore the `pull_request`/`push` triggers and the nightly schedule. CI then writes it to
`~/.julia/servers/juliahub.com/`, uses the `juliahub.com` package server and adds General and
DyadRegistry. Fork PRs receive no secrets and get no CI.
