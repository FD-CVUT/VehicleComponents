# Migration from the course repo

Old names are the course repo's (dr14-make/16ESPD at 0e7e92b), relative to its package
`VehicleSystemsComponents`. New names are relative to `VehicleComponents`. A component that is
not listed has not moved yet.

Flange sign: the brake chain's pushrod flanges (`Chassis.Brakes.Pedal`, `StaticBooster`,
`VacuumBooster`, `MasterCylinder`) take the stdlib's sign, the force on the part along s, where the
course used the opposite. A stdlib `TranslationalComponents.Sources.Force` with a positive `f` now
pushes a rod toward +s and builds pressure; a chain of the library's own parts behaves as before.

## Components

| Course | Library | Notes |
|---|---|---|
| `Vehicle.VehicleBody` | `Body.Longitudinal.Vehicle` | The rolling resistance coefficient `f_r` is an input, no longer a parameter: wire a constant (0.012 was the default). Starts at rest by default (`mass.s`, `mass.v` = 0), so drop an old `initial` statement for them; give another start at the declaration: `Vehicle(mass(v = initial 10.0))`. |
| `HandsOn.GradeBody` | `Body.Longitudinal.Vehicle` | Same equations as `Vehicle.VehicleBody`; `f_r` and the start at rest as there. |
| `Vehicle.RoadLoad` | `Body.Longitudinal.RoadLoad` | `f_r` is an input, as for `Vehicle`. |
| `Vehicle.GradeForce` | `Body.Longitudinal.GradeForce` | `m` defaults to 1400 kg; the course required it. |
| `HandsOn.GradeForce` | `Body.Longitudinal.GradeForce` | |
| `Roadster.AxleLoad` | `Body.Longitudinal.AxleLoad` | `F_z` output and `downforce` input are now flanges: wire `load_left` and `load_right` to the axle's two wheels' load flanges, each taking half the load, or both to one wheel that stands for the whole axle, and push `downforce` with a force source; positive force presses the car onto the road. An open `downforce` means zero downforce. `F_z` no longer goes negative: a lifted axle carries zero load. Default `m` is 1400 kg, was 2000 kg. |
| `Vehicle.Wheel.TireFrictionCurve` | `Chassis.Wheel.Helpers.TireFrictionCurve` | Input `kappa` is now `u`, output `mu` is now `y`. |
| `HandsOn.TireFrictionCurve` | `Chassis.Wheel.Helpers.TireFrictionCurve` | Same equations as `Vehicle.Wheel.TireFrictionCurve`; ports as there. |
| `Vehicle.Wheel.SlipWheel1D` | `Chassis.Wheel.Slip` | The `curve` part is gone; `curve.mu` is now `mu_ref` and `curve.kappa` is now `s`. A negative `F_z` now passes no force: the tire force is mu max(F_n, 0). |
| `HandsOn.SlipWheel1D` | `Chassis.Wheel.Slip` | Same equations as `Vehicle.Wheel.SlipWheel1D`; the curve's parameters are now the wheel's, with the same defaults. The `curve` part and a negative `F_z` change as for `Vehicle.Wheel.SlipWheel1D`. |
| `Vehicle.Wheel.LoadedSlipWheel1D` | `Chassis.Wheel.LoadedSlip` | The `F_z` input is now the `load` flange: wire it to `Body.Longitudinal.AxleLoad`'s load flanges (see its docstring), or push it with a force source; positive force presses the tire onto the road. New `mu_scale` input: wire a constant 1 for the old behavior. A negative load (a lifted tire) now passes no force. The defaults are now `Slip`'s: `radius` 0.31 m (was 0.35 m), `mu_A` 1.0 (was 1.26), `mu_S` 0.7 (was 1.0). |
| `Vehicle.Wheel.BrakeActuator` | `Chassis.Wheel.BrakeActuator` | `tau_actual` is now `tau`. It starts at 0 by default, so drop an old `initial` statement for it. |
| `Vehicle.Wheel.BrakedWheel` | `Chassis.Wheel.Braked` | The wheel-level parameters are gone: set the part instead, `Braked(inertia(J = 2.0), tire(F_z = 6864.655), brake(tau_max = 3000.0))` for `J_w`, `F_z`, `tau_max`, and `tire(...)` for `radius` and the friction-curve parameters, `brake(...)` for `T_brake` (now `T`) and `w0`. `brake.tau_actual` is now `brake.tau`. Starts at rest by default (`inertia.phi`, `inertia.w`, `brake.tau` = 0), so drop old `initial` statements for them; give another start at the declaration: `Braked(inertia(w = initial 80.0))`. |
| `Vehicle.Wheel.HydraulicBrakedWheel` | `Chassis.Wheel.HydraulicBraked` | The wheel-level parameters are gone, as for `Braked`: `J_w` and `F_z` are `inertia(J = ...)` and `tire(F_z = ...)` (the course's `TCSCar` passed `F_z = m * g / 2`), and the caliper parameters are `caliper_f(...)` and `caliper_r(...)`, with `K_f`, `V0_f`, `K1_f`, `K3_f` now `caliper_f`'s `K`, `V0`, `K1`, `K3` and the same for the rear; `p0` and `w0` are set on each caliper. Starts at rest as `Braked` does. |
| `Vehicle.Brake.BrakeCaliper` | `Chassis.Brakes.Caliper` | `V` counts admitted fluid as its mass over the density at `p_amb`, not at the caliper's pressure, so a fill and a release at different pressures cancel; the pressure-volume law is unchanged. Pressures are now gauge, relative to the new parameter `p_amb` (100325 Pa, the HydraulicComponents medium's reference): the caliper's `p` is `port.p - p_amb`, and `p0`, `K1`, `K3` keep their values as gauge. Add `p_amb` to a source pressure that was meant as gauge. A circuit at ambient pressure now applies no torque, where the course's caliper dragged K (p_amb - p0), about 24.7 N m on the front axle and 10 N m on the rear. |
| `Vehicle.Brake.BrakeLine` | `Chassis.Brakes.Line` | `nu` is gone: the line reads the dynamic viscosity and density from the circuit's medium. Use `VehicleComponents.DOT4` for DOT 4 fluid at 20 °C. |
| `Vehicle.Brake.BrakePedal` | `Chassis.Brakes.Pedal` | Flange sign, see above. The variable `x_rod` is gone: the pushrod travel is `x_ped`/`i_p`. |
| `Vehicle.Brake.StaticBooster` | `Chassis.Brakes.StaticBooster` | Flange sign, see above. The vacuum-chamber pressure `p_vac` is now `p_f`, as on `VacuumBooster`, whose `p_vac` is its sensor output. |
| `Vehicle.Brake.TandemMasterCylinder` | `Chassis.Brakes.MasterCylinder` | The output `p_mc` is gauge and the ports carry `p_amb` + `p_mc`, with the new parameter `p_amb` (100325 Pa), as `Chassis.Brakes.Caliper` reads them. Flange sign, see above. `V_disp` counts displaced fluid as its mass over the density at `p_amb`, as `Caliper` counts `V`, so it always equals the fluid the calipers hold, and a fill and a release at different pressures return `x_rod` to `s_dead`; the course left about -2.6e-8 m³ after a release from 8.9 MPa. Fluid returned with the pistons at rest goes to the reservoir, so `V_disp` never drops below 0 and `x_rod` never below `s_dead`. It starts with nothing displaced by default, so drop an old `initial` statement for `V_disp`. |
| `Vehicle.Brake.ABSValve` | `Chassis.Brakes.ABSValve` | `p_cmd` is gauge and the ports carry absolute pressure, gauge plus the new parameter `p_amb` (100325 Pa); add nothing to a command that was meant as gauge. `p_delayed` is now `p_hold`, with a default start of 0. The inlet's opening is the new state `y` (1 open, starting open), which follows the open-or-closed request with `T_v`, and the wheel side is min(p_a, y p_a + (1 - y) p_hold): a re-apply now takes the solenoid's lag, where the course stepped the wheel side to the master cylinder's pressure at once, and closing takes it too. While the held pressure is more than the new parameter `dp_check` (0.1 bar, the check valve's cracking pressure) above the master-cylinder side, the inlet's check valve returns the caliper's fluid through `port_a` and the wheel side is clamped to p_a + `dp_check`, where the course counted that fluid as dumped and clamped to p_a. The flow splits by the opening: the open share `y` of the caliper's outflow returns to the master cylinder and only the closed share is dumped, where the course dumped all of it from the instant the command dropped. |
| `Vehicle.Brake.ClosedHydraulicPort` | `Chassis.Brakes.ClosedHydraulicPort` | |
| `Vehicle.Brake.VacuumBooster` | `Chassis.Brakes.VacuumBooster` | `p_init` is gone: both chambers start at 33 kPa on their variables, so give another start at the declaration, `VacuumBooster(p_f = initial 101325.0, p_r = initial 101325.0)`. `s_rest` is gone: the piston travel `x_p` is the rod's travel since the start of the run, which is assumed at rest, so it no longer has to match the master cylinder's `s_dead`. Flange sign, see above. |
| `Vehicle.Brake.ElectricVacuumPump` | `Chassis.Brakes.ElectricVacuumPump` | `p_init` is gone: the hose starts at 101325 Pa and the pump running, on the variables `p_h` and `y`. A start below `p_on` sets both at the declaration, `ElectricVacuumPump(p_h = initial 30e3, y = initial 0.0)`, where the course derived the latch's start from `p_init`. `Q` is 0.49e-3 m³/s, was 0.40e-3, which matches the cited Hella UP28 datum, 3.2 L to 50 kPa in 5.5 to 6 s: 0.49e-3 gives 5.79 s, where 0.40e-3 took 7.09 s. |
| `Vehicle.Brake.VacuumSourceSelector` | `Chassis.Brakes.VacuumSourceSelector` | `use_pump` is a structural Boolean, `false` for the manifold, where the course took a Real compared at 0.5: write `use_pump = true` for the pump. |
| `Vehicle.GasPort` | `Gas.Port` | |
| `Vehicle.GasPressureSource` | `Gas.PressureSource` | |
| `Vehicle.Brake.TestBrakeVacuum` | not yet in the library | The booster on the engine's air path needs `Powertrain.Engine`'s `AirPath`; FD-CVUT/VehicleComponents#11. |
| `Vehicle.BrakeSplit` | `Chassis.Brakes.Split` | The `input` mode and the `BrakeInput` enum are gone, and with them the conditional `brake` and `ratio` inputs: `u` is always a magnitude, max(u, 0) `gain`. For `SignedDriver` and `FixedEngine`, feed `u` through a `BlockComponents.Math.Gain(k = -1.0)`. For `FixedElectric`, feed `u` the product of brake and ratio from a `BlockComponents.Math.Product` and set `gain = 2.0`. |
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
| `Vehicle.Planar.PlanarCar` | `Body.Planar.Car` | The `mu_scale_fl` to `mu_scale_rr` parameters are gone: the wheels read their grip from the road `grip`, a `Road.Grip` (uniform grip 1 by default). Give a split or patchy grip as a road file (`right_patch_mu.crg`), and a uniform scale by scaling `mu_A` and `mu_S`. The car fills its own `bus` by equations from sensors on its diagram, and the course `PlanarCarSensors` cluster is gone. The road load is now inside the car: drop a separate `PlanarRoadLoad` on `chassis` and wire the new inputs `grade` (0 on a flat road) and `f_r` (0.012 was the default). The brakes are no longer inside: place a `Chassis.Wheel.BrakeActuator` (or a hydraulic `Chassis.Brakes.Caliper`) on each `spin_*`; the `tau_fl` to `tau_rr` inputs and the `T_brake` and `tau_max` parameters are gone. The wheel-center frame ports `wheel_fl` to `wheel_rr` are gone: read each wheel's slip, slip angle and spin speed from `bus`. The planar `World` is no longer inside: the model that places the car must hold one `MultibodyComponents.PlanarMechanics.World(g = 0)`. Parts renamed: `tf`, `tr` are `front`, `rear`; `fl_arm` to `rr_arm` are `arm_fl` to `arm_rr`; `steerL`, `steerR` are `kingpin_fl`, `kingpin_fr`; each wheel's `joint` is `tire`. The wheel loads never go negative and use g = 9.80665 (was 9.81). Starts at rest at the origin (`body.r`, `body.v`, `body.phi`, `body.w` and every wheel's `inertia`), so drop old `initial` statements for them; give another start at the declaration: `Car(body(v = initial [20.0, 0.0]), fl(inertia(w = initial 64.5)))`. |
| `Vehicle.Planar.RoadCar` | `Body.Planar.Car` | `road_file`, `default_grip` and `blend_width` are now one structural `grip = VehicleComponents.Road.grip(file; default_grip, blend_width)`. The rest as for `Vehicle.Planar.PlanarCar`. |
| `Vehicle.Planar.SlipWheelJoint` | `Body.Planar.SlipWheelJoint` | `flange_a` is now `spline`. The `dynamicLoad` input and the base load `N` are now the `load` flange, positive pressing the tire onto the road. New `mu_scale` input: wire a constant 1 for the old behavior. The driving direction `r` is gone: the wheel heads along the x axis of `frame_a`. New `F_x`, `F_y`, `F_z`. Defaults are now the planar car's tire (radius 0.31 m, mu_A 1, mu_S 0.8, sAdhesion 0.12, vAdhesion_min 0.05 m/s, vSlide_min 0.15 m/s), where the course required them. |
| `Vehicle.Planar.PlanarBrakedWheel` | `Body.Planar.Wheel` | The brake is no longer inside: `tau_cmd`, `T_brake`, `tau_max` and `w0` are gone, and `spin` is the wheel shaft itself; place a `Chassis.Wheel.BrakeActuator` (or a `Chassis.Brakes.Caliper`) on `spin`. `mu_scale` is gone: the grip comes from the road `grip`, a `Road.Grip`. `joint` is now `tire`; `vAdhesion_min` and `vSlide_min` are set on the part, `Wheel(tire(vSlide_min = 0.2))`. Starts at rest (`inertia.phi`, `inertia.w` = 0), so drop old `initial` statements for them. |
| `Vehicle.Planar.RoadBrakedWheel` | `Body.Planar.Wheel` | `road` is now `grip`; the grip it reads is the output `road.grip`. The rest as for `Vehicle.Planar.PlanarBrakedWheel`. |
| `Vehicle.Planar.AckermannSteering` | `Body.Planar.AckermannSteering` | |
| `Vehicle.Planar.QuasiStaticLoads` | `Body.Planar.QuasiStaticLoads` | Each wheel load is floored at zero: a wheel the transfer would lift carries no load. `dN_fl` to `dN_rr` are gone; the loads are `F_fl` to `F_rr`. `Nf`, `Nr` are final parameters. `g` defaults to 9.80665 (was 9.81). |
| `Vehicle.Planar.PlanarRoadLoad` | `Body.Planar.RoadLoad` | The rolling resistance coefficient `f_r` is an input, no longer a parameter: wire a constant (0.012 was the default). `F` is gone: the road load is `-sensor.f`. `v_nominal` is gone; it scaled the stdlib drag law without changing the force. Parts renamed: `vel` is `speed`, `roadload` is `law`. `Body.Planar.Car` places one itself. |
| `Vehicle.Planar.RoadGrade` | `Body.Planar.RoadGrade` | `chassis` is now `frame_a` and `slope` is now `road`, a `Road.Slope` built with `Road.slope(file)`; it defaults to the level road. |
| `Vehicle.Planar.CarBus` | `Body.Planar.CarBus` | Each field has its unit type (`Velocity`, `AngularVelocity`, `Acceleration`, `Position`, `Angle`) instead of `Real`; the slip ratios stay dimensionless. |
| `Vehicle.Planar.CarBusIn` | `Body.Planar.CarBusIn` | Typed as `CarBus`. |
| `Vehicle.Planar.PlanarCarSensors` | not in the library | `Body.Planar.Car` fills its own `bus`: its sensors sit on its diagram and its equations set the bus fields. |
| `Vehicle.Planar.WheelSlipSensor` | `Sensors.WheelSlip` | Part `vel` is now `velocity`. The output `v_long` is gone: read the wheel-center speed from a `MultibodyComponents.PlanarMechanics.AbsoluteVelocity` on the wheel frame. |
| `Vehicle.Planar.BusMotion` | `Body.Planar.BusOut` | One block unpacks every field; outputs a model does not use stay open. |
| `Vehicle.Planar.BusSlip` | `Body.Planar.BusOut` | One block unpacks every field; outputs a model does not use stay open. |
| `Vehicle.Planar.BusSlipAngle` | `Body.Planar.BusOut` | One block unpacks every field; outputs a model does not use stay open. |
| `Vehicle.Planar.BusWheelSpeed` | `Body.Planar.BusOut` | One block unpacks every field; outputs a model does not use stay open. |
| `Lecture1.MeasurementNoise` | `Sensors.Noise` | Time comes from a `ContinuousClock` part. The lecture step copies (`Lecture1.Step07`, `Step08`, `Step10`) stay in the course. |

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
