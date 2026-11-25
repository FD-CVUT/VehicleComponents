# Stdlib upgrades: library parts waiting on a standard-library release

Each row is a library component that stands in for something a later Dyad standard-library release
provides. When an upgrade brings that release, replace the component, rewire its users, and delete
the row.

## Calculation blocks → BlockComponents equation block

A model that places parts feeds a computed value to a part's input through a block of its own
(`AGENTS.md`, Connections). BlockComponents 5.0.0 has no block that takes an equation, so each
such calculation is a small library block. A BlockComponents release with an equation block
replaces them all.

| Component | Computes |
|---|---|
| `Electrical.Battery.Helpers.ArrheniusFactor` | `exp(Ea / Rg (1 / u - 1 / Tref))` |
| `Electrical.Battery.Helpers.BalancerRequest` | smooth AND of two voltage conditions |
| `Electrical.Battery.Helpers.CCCVPowerCurrent` | `min(I_cc, max(0, u2) / max(u1, 1 V))` |
| `Electrical.Battery.Helpers.CCCVVoltageCurrent` | `min(I_cc, max(0, (V_max - u) / R_reg))` |
| `Electrical.Battery.Helpers.SoCPhase` | `mod(u, period)` |
