# Roads

OpenCRG road files. A Dyad model reaches one as `dyad://VehicleComponents/data/roads/<file>`
and turns it into a callable with `VehicleComponents.Road.grip(file)` (a `Road.Grip`) or
`VehicleComponents.Road.slope(file)` (a `Road.Slope`). A `_mu` file holds a dimensionless grip
multiplier in its height channel; a `_z` file holds elevation in meters. Beyond a file's grid the
road blends over 2 m to grip 1 or height 0.

`generate.jl` writes every file here; rerun it with `julia generate.jl` after changing it.

The reader fits a quadratic spline through the file's nodes, so a sharp corner in the data
overshoots slightly: the grip patches below reach about 0.01 past their nominal values
(`right_patch_mu.crg` spans 0.290 to 1.008, `ice_patch_mu.crg` 0.298 to 1.002).

| File | Road |
|---|---|
| `uniform_mu.crg` | Grip 1 over x, y = -1000…1000 m |
| `uniform_low_mu.crg` | Grip 0.3 over x, y = -1000…1000 m |
| `ice_patch_mu.crg` | Grip 0.3 on x = 459…491 m, smoothstepping from 1 over the 4 m on either side; the grid is the strip y = -1…1 m |
| `right_patch_mu.crg` | Grip 0.3 on x = 450…462 m for y up to -1 m (the right side), smoothstepping from 1 over 4 m along x and over y = -1…1 m |
| `flat_z.crg` | Level at height 0 |
| `hill_z.crg` | Raised-cosine hill on x = 240…400 m, peak grade 8 %, level across y = -1000…1000 m |
| `hill_across_z.crg` | The same hill along y, on y = -40…120 m |
| `ramp_z.crg` | 2 % climb on x = 0…500 m, eased over 40 m onto a 10.4 m plateau to x = 1000 m; past the grid end the road drops to 0 over the 2 m blend |
| `ramp_hold_z.crg` | 2 % climb on x = -250…250 m, eased onto a 10.4 m plateau to x = 1030 m; past the grid end the road drops to 0 over the 2 m blend |
