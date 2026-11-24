# VehicleComponents

A Dyad component library of vehicle models: body, chassis, powertrain, electrical, control and
in-vehicle network components, with example vehicles built from them. It started as the models of
the CVUT vehicle systems course (dr14-make/16ESPD at 0e7e92b) and is now maintained on its own.

The library is being filled domain by domain; see [the spec](https://github.com/FD-CVUT/VehicleComponents/issues/1) for the plan.

## Requirements

- A JuliaHub account. The library depends on Dyad packages from DyadRegistry, which JuliaHub serves
  only to signed-in users. Dyad is free for educational and personal use; commercial use needs a
  JuliaHub license.
- The Dyad Julia build and the Dyad Studio VS Code extension. The release in use is pinned by
  `DYAD_STUDIO_VERSION` in `mise.toml`; `[dyad] kernel` in `Project.toml` names the matching
  juliaup channel (`dyad-<kernel>`, served from `https://juliahub.com/juliabin`).

## Install

The package is not registered. Sign in to JuliaHub (Dyad Studio does this for you, or set
`JULIA_PKG_SERVER=juliahub.com` and authenticate), then add it by URL from the Dyad Julia build:

```julia
using Pkg
Pkg.add(url = "https://github.com/FD-CVUT/VehicleComponents")
using VehicleComponents
```

To pin a commit from another package, list it under `[sources]` in that package's `Project.toml`:

```toml
[sources]
VehicleComponents = {url = "https://github.com/FD-CVUT/VehicleComponents", rev = "<commit>"}
```

## Module tree

Components live in nested submodules by vehicle domain. Each domain with tests has its own
`Tests` submodule.

| Module | Contents |
|---|---|
| `Body.Longitudinal`, `Body.Planar` | vehicle bodies |
| `Chassis.Wheel`, `Chassis.Brakes` | tires and wheels, brake system |
| `Powertrain.Engine`, `.Transmission`, `.Hybrid` | engines, gearboxes, hybrid couplings |
| `Electrical.Machines`, `.PowerElectronics`, `.Battery` | electric drive |
| `Control` | ABS, ESP, TCS, cruise, brake allocation, regen blend |
| `CanBus`, `Driver`, `Road`, `Sensors`, `Blocks` | network, drivers, roads, sensors, utilities |
| `Examples` | complete vehicles by what they demonstrate, on shared `Examples.Platforms` |

## Tests

Tests are Dyad test models that check start values, end values and signal snapshots. They run in
two tiers:

| Tier | What | When | Budget |
|---|---|---|---|
| fast | every test model in a domain's `Tests` submodule, one process | every pull request | 30 s per rig, under 10 min in all |
| example | every test model under `Examples`, one process each | PRs that touch an example | under 60 min |

```sh
mise run test            # julia +dyad-<kernel> --project=. test/runtests.jl fast
mise run test:examples   # julia +dyad-<kernel> --project=. test/runtests.jl examples
mise run check           # the PR gate: fast tier, then fail if generated/ is stale
```

The checks run locally: CI is manual-only until the repo has a long-term JuliaHub token (see
[AGENTS.md](AGENTS.md)).

## Contributing

Read [AGENTS.md](AGENTS.md) for the structural rules, test rules and toolchain pin.

## License

BSD 3-Clause, see [LICENSE](LICENSE).
