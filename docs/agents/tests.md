# Tests and snapshots

A rig is one test model with all its cases. Assert only on external behavior: the signals and
values a model exposes. Prefer a physically meaningful number (master-cylinder pressure at a given
pedal force, stopping distance, final SoC).

One rig covers a base and its presets that only change parameters, whichever of them it places; a
preset that adds parts or equations needs its own rig.

## Seams

- **Main seam: Dyad test models.** Each case pins `solver`, `abstol` and `reltol`, and checks start
  and end values in its `tests` metadata; a named-signal snapshot only for what those cannot show.
  `"solver": "Auto"` is the pin; name an algorithm only where `Auto` fails or drifts, with a
  comment saying why. To check one component at several inputs, wire one instance to constant
  sources and give each case its own `params` (`{"voltage.k": 400.0}`), rather than placing
  several instances that share sources. A start every case shares goes on the part's declaration;
  a start that differs between cases goes in each case's `initial` (`{"body.mass.v": 10.0}`).
- **Second seam: plain Julia test sets** against the public Julia API, only for what a test model
  cannot express (OpenCRG reading, CAN frame encoding and decoding, the realtime drive headless).

## Tiers

Two tiers, chosen by where the test model lives:

| Tier | Test models | Runs | Budget |
|---|---|---|---|
| fast | in a `Tests` submodule of its domain or subdomain (`Chassis.Brakes.Tests`) | every PR and push to `main`, one process | 30 s per rig, under 10 min in all |
| example | under `Examples` | nightly, one process per model | under 60 min |

Place every test model in one of the two; the fast tier fails on a test model anywhere else, and
on any rig over budget. A rig's budget is its warm time inside a tier run, after the compilation
the process shares; a cold single-rig run takes longer and is not the measure. A rig that needs
longer is an example, or a sign the component's test is too big. CI runs the example tier only
nightly, so run `mise run test examples` yourself when a change reaches an example.

The library starts with zero pinned failures, and a new failure gets fixed.

## Snapshots

Snapshots are committed under `test/snapshots/`, mirroring the module path. A snapshot changes in
the same PR as the model change that moves it: rerun the affected tier with `DYAD_UPDATE_REFS=1`
and commit the new `.ref` files, so the reviewer sees every output change. A test model run
without a committed snapshot seeds one and fails its tier; commit the seeded file with the model.
