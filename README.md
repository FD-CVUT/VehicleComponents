# VehicleComponents

A Dyad component library of vehicle models: body, chassis, powertrain, electrical, control and
in-vehicle network components, with example vehicles built from them. It started as the models of
the CVUT vehicle systems course (dr14-make/16ESPD at 0e7e92b) and is now maintained on its own.

The library is being filled domain by domain; see [the spec](https://github.com/FD-CVUT/VehicleComponents/issues/1) for the plan.

## Requirements

- The Dyad Julia build: juliaup channel `dyad-<kernel>` from `https://juliahub.com/juliabin`, where
  `<kernel>` is `[dyad] kernel` in `Project.toml`. It bundles the Dyad standard libraries; the few
  other dependencies come from the General registry, so installing needs no sign-in.
- The Dyad Studio VS Code extension (needs a JuliaHub account) to edit the models, at the release
  pinned by `DYAD_STUDIO_VERSION` in `mise.toml`. Dyad is free for educational and personal use;
  commercial use needs a JuliaHub license.

## Install

The package is not registered. Add it by URL from the Dyad Julia build:

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

## Module tree and tests

Components live in nested submodules by vehicle domain (`Body`, `Chassis`, `Powertrain`,
`Electrical`, `Control`, `CanBus`, `Driver`, `Road`, `Sensors`, `Blocks`), with complete vehicles
under `Examples`. Tests are Dyad test models in each domain's `Tests` submodule (fast tier, every PR)
and under `Examples` (example tier, nightly). [AGENTS.md](AGENTS.md) has the full tree and test rules.

```sh
mise run test            # fast tier
mise run test examples   # example tier
mise run check           # what CI runs on every PR: generated-code check and fast tier
```

## Contributing

Read [AGENTS.md](AGENTS.md) for the component and test rules, and
[docs/agents/toolchain.md](docs/agents/toolchain.md) for the toolchain pin and upgrades.

## License

BSD 3-Clause, see [LICENSE](LICENSE).
