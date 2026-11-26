# Migration from the course repo

Old names are the course repo's (dr14-make/16ESPD at 0e7e92b), relative to its package
`VehicleSystemsComponents`. New names are relative to `VehicleComponents`. A component that is
not listed has not moved yet.

## Components

| Course | Library | Notes |
|---|---|---|
| `Vehicle.VehicleBody` | `Body.Longitudinal.Vehicle` | The rolling resistance coefficient `f_r` is an input, no longer a parameter: wire a constant (0.012 was the default). Starts at rest by default (`mass.s`, `mass.v` = 0), so drop an old `initial` statement for them; give another start at the declaration: `Vehicle(mass(v = initial 10.0))`. |
| `HandsOn.GradeBody` | `Body.Longitudinal.Vehicle` | Same equations as `Vehicle.VehicleBody`; `f_r` and the start at rest as there. |
| `Vehicle.RoadLoad` | `Body.Longitudinal.RoadLoad` | `f_r` is an input, as for `Vehicle`. |
| `Vehicle.GradeForce` | `Body.Longitudinal.GradeForce` | `m` defaults to 1400 kg; the course required it. |
| `HandsOn.GradeForce` | `Body.Longitudinal.GradeForce` | |
| `Roadster.AxleLoad` | `Body.Longitudinal.AxleLoad` | `F_z` output and `downforce` input are now flanges: wire `load` to the wheel's load flange and push `downforce` with a force source; positive force presses the car onto the road. An open `downforce` means zero downforce. Default `m` is 1400 kg, was 2000 kg. |
| `Vehicle.Wheel.TireFrictionCurve` | `Chassis.Wheel.Helpers.TireFrictionCurve` | Input `kappa` is now `u`, output `mu` is now `y`. The law itself is the partial `Chassis.Wheel.TireFriction`, which the block and `Chassis.Wheel.Slip` both extend. |
| `HandsOn.TireFrictionCurve` | `Chassis.Wheel.Helpers.TireFrictionCurve` | Same equations as `Vehicle.Wheel.TireFrictionCurve`; ports as there. |
| `Vehicle.Wheel.SlipWheel1D` | `Chassis.Wheel.Slip` | The `curve` part is gone: `Slip` extends `Chassis.Wheel.TireFriction`, so `curve.mu` is now `mu_ref`. `kappa` is now an output port. The normal load is the variable `F_n`, bound to the parameter `F_z`. |
| `HandsOn.SlipWheel1D` | `Chassis.Wheel.Slip` | Same equations as `Vehicle.Wheel.SlipWheel1D`; the curve's parameters are now the wheel's, with the same defaults. |
| `Vehicle.Wheel.LoadedSlipWheel1D` | `Chassis.Wheel.LoadedSlip` | The `F_z` input is now the `load` flange: wire `Body.Longitudinal.AxleLoad.load` to it, or push it with a force source; positive force presses the tire onto the road. New `mu_scale` input: wire a constant 1 for the old behavior. Extends `Slip`, so the defaults are now `Slip`'s: `radius` 0.31 m (was 0.35 m), `mu_A` 1.0 (was 1.26), `mu_S` 0.7 (was 1.0). |
| `Vehicle.Wheel.BrakeActuator` | `Chassis.Wheel.BrakeActuator` | `tau_actual` starts at 0 by default, so drop an old `initial` statement for it. |
| `Vehicle.Wheel.BrakedWheel` | `Chassis.Wheel.Braked` | Starts at rest by default (`inertia.phi`, `inertia.w`, `brake.tau_actual` = 0), so drop old `initial` statements for them; give another start at the declaration: `Braked(inertia(w = initial 80.0))`. |
| `Vehicle.Wheel.HydraulicBrakedWheel` | `Chassis.Wheel.HydraulicBraked` | Starts at rest as `Braked` does. |
| `Vehicle.Brake.BrakeCaliper` | `Chassis.Brakes.Caliper` | `V` starts at 0 on the variable, as before. |
| `Vehicle.Brake.BrakeLine` | `Chassis.Brakes.Line` | |
| `Driver` | `Driver.Interface` | |
| `ClockedDriver` | not yet in the library | Needs `DiscreteComponents`; FD-CVUT/VehicleComponents#29. |
| `ScriptedDriver` | `Driver.Scripted` | Unclocked: a breakpoint takes effect at its own time, not at the next 10 ms tick. The `period`, `clock`, `*_hold`, `*_sampler` and `*_clock` parts are gone. |
| `CoastDownDriver` | `Driver.CoastDown` | |
| `HardStopDriver` | `Driver.HardStop` | |
| `Vehicle.DriveCycle` | `Driver.DriveCycle` | |
| `RoadGrip` | `Road.Grip` | |
| `RoadSlope` | `Road.Slope` | |
| `Vehicle.GradeProfile` | `Road.GradeProfile` | |
| `Vehicle.FrictionProfile` | `Road.FrictionProfile` | |
| `Vehicle.ToKmPerHour` | `Blocks.ToKmPerHour` | |
| `Vehicle.ToRPM` | `Blocks.ToRPM` | |
| `Vehicle.ToPercent` | `Blocks.ToPercent` | |
| `Vehicle.ParameterSwitch` | `Blocks.ParameterSwitch` | |
| `Vehicle.ParameterGate` | `Blocks.ParameterSwitch` | Wire the gated signal to `u1` and a `BlockComponents.Sources.Constant(k = fallback)` to `u2`; `on` keeps its meaning. |
| `Vehicle.Blocks.ArrheniusFactorEquation` | `Electrical.Battery.Helpers.ArrheniusFactor` | Input `u1` is now `u`. |
| `Vehicle.Blocks.BalancerRequestEquation` | `Electrical.Battery.Helpers.BalancerRequest` | |
| `Vehicle.Blocks.CCCVPowerCurrentEquation` | `Electrical.Battery.Helpers.CCCVPowerCurrent` | |
| `Vehicle.Blocks.CCCVVoltageCurrentEquation` | `Electrical.Battery.Helpers.CCCVVoltageCurrent` | Input `u1` is now `u`. |
| `Vehicle.Blocks.SoCPhaseEquation` | `Electrical.Battery.Helpers.SoCPhase` | Input `u1` is now `u`. |
| `Vehicle.Blocks.TerminalPowerCurrentEquation` | not in the library | It computed `P / max(v, 1 V)` with no state; its one use, a voltage sensor into it into a current source, is a constant-power load. The pin-based constant-power load comes with FD-CVUT/VehicleComponents#14. The course's `Vehicle.Electric.AuxLoad` shows the pattern but is not equivalent: its current is a state that lags `P / v` with a time constant, and it has no 1 V floor. |

## Data

| Course | Library |
|---|---|
| `dyad://VehicleSystemsComponents/data/drive_cycles/<file>` | `dyad://VehicleComponents/data/drive_cycles/<file>` |
| `dyad://VehicleSystemsComponents/drivers/coast_down.csv` | `dyad://VehicleComponents/data/drivers/coast_down.csv` |
| `dyad://VehicleSystemsComponents/drivers/hard_stop.csv` | `dyad://VehicleComponents/data/drivers/hard_stop.csv` |
| `dyad://VehicleSystemsComponents/roads/<file>` | `dyad://VehicleComponents/data/roads/<file>` |

## Julia functions

The OpenCRG reader moved from the package root into the `Road` submodule.

| Course | Library | Notes |
|---|---|---|
| `road_grip` | `Road.grip` | |
| `road_height` | `Road.slope` | Named for what it returns: tan of the road angle along a heading, not a height. It returns a `Road.SurfaceSlope`, a callable that holds its fitted height `Surface` in `height`, not an anonymous function. |
| `road_surface` | `Road.surface` | |
| `RoadSurface` | `Road.Surface` | |
| `road_lookup` | `Road.lookup` | |
| `road_directional_slope` | `Road.directional_slope` | |
| `road_extent` | `Road.extent` | Takes fitted roads (`Surface` or `SurfaceSlope`), no longer file names. |
| `road_axes` | `Road.sample_axes` | Takes fitted roads, as `Road.extent` does. |
| `road_mesh` | `Road.mesh` | Takes the fitted roads, not file names: `mesh(slope; grip = grip)` with what `Road.slope` and `Road.grip` return, so the drawing uses their default values, blend width and missing-value policy. |
| `read_road` | not in the library | `Road.surface` reads and fits a file in one step. |
| `road_dimension` | `Road.spline_dimension` | |
| `road_path` | `Road.asset_path` | Resolves any `dyad://` URI through `DyadData`, not only this package's, and like `Driver.DriveCycle` finds the package through `Base.find_package`: a `dyad://VehicleComponents/...` path fails when `VehicleComponents` is only an indirect dependency of the active environment. |
