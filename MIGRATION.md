# Migration from the course repo

Old names are the course repo's (dr14-make/16ESPD at 0e7e92b), relative to its package
`VehicleSystemsComponents`. New names are relative to `VehicleComponents`. A component that is
not listed has not moved yet.

## Components

| Course | Library | Notes |
|---|---|---|
| `Vehicle.VehicleBody` | `Body.Longitudinal.Vehicle` | |
| `HandsOn.GradeBody` | `Body.Longitudinal.Vehicle` | Same equations as `Vehicle.VehicleBody`. |
| `Vehicle.RoadLoad` | `Body.Longitudinal.RoadLoad` | |
| `Vehicle.GradeForce` | `Body.Longitudinal.GradeForce` | |
| `HandsOn.GradeForce` | `Body.Longitudinal.GradeForce` | |
| `Roadster.AxleLoad` | `Body.Longitudinal.AxleLoad` | Default `m` is 1400 kg, was 2000 kg. |
| `Driver` | `Driver.Interface` | |
| `ClockedDriver` | not yet in the library | Needs `DiscreteComponents`; FD-CVUT/VehicleComponents#29. |
| `ScriptedDriver` | `Driver.Scripted` | Unclocked: a breakpoint takes effect at its own time, not at the next 10 ms tick. The `period`, `clock`, `*_hold`, `*_sampler` and `*_clock` parts are gone. |
| `CoastDownDriver` | `Driver.CoastDown` | |
| `HardStopDriver` | `Driver.HardStop` | |
| `Vehicle.DriveCycle` | `Driver.DriveCycle` | |

## Data

| Course | Library |
|---|---|
| `dyad://VehicleSystemsComponents/data/drive_cycles/<file>` | `dyad://VehicleComponents/data/drive_cycles/<file>` |
| `dyad://VehicleSystemsComponents/drivers/coast_down.csv` | `dyad://VehicleComponents/data/drivers/coast_down.csv` |
| `dyad://VehicleSystemsComponents/drivers/hard_stop.csv` | `dyad://VehicleComponents/data/drivers/hard_stop.csv` |
