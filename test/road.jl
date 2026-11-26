# Reading grip and height from OpenCRG files through `VehicleComponents.Road`.
module RoadTests

using Test, Random, VehicleComponents
import DataInterpolationsND, ForwardDiff, OpenCRG

const R = VehicleComponents.Road
const ROADS = "dyad://VehicleComponents/data/roads/"
const OPENCRG = joinpath(@__DIR__, "data", "opencrg")

gradient(f, x, y) = ForwardDiff.gradient(q -> f(q[1], q[2]), [x, y])

@testset "Grip: finite nodes and rejected unsupported geometry" begin
    for file in ("handmade_straight.crg", "handmade_straight_double.crg")
        path = joinpath(OPENCRG, file)
        data = OpenCRG.read_crg(path)
        road = R.grip(path; fill_missing = 0.0)
        errors = [abs(road(data.refline.start_u + (i-1)*data.refline.increment,
            data.v[j]) - data.z[i,j]) for i in axes(data.z,1), j in axes(data.z,2)
            if isfinite(data.z[i,j])]
        @test maximum(errors) < 1e-9
        # Beyond the grid and its blend the road takes the default grip.
        @test road(-100.0, 0.0) == 1.0
        @test road(100.0, 100.0) == 1.0
    end
    # OpenCRG.jl 0.1 does not implement the upstream minimalist file's implicit v origin.
    @test_throws "LONG_SECTION_V_RIGHT" R.grip(joinpath(OPENCRG, "handmade_straight_minimalist.crg"))
    curved = joinpath(OPENCRG, "handmade_curved.crg")
    curved_grip = R.grip(curved)
    u, v, X, Y, z = OpenCRG.road_surface_grid(OpenCRG.read_crg(curved))
    center = findfirst(==(0.0), v)
    @test center !== nothing
    @test maximum(abs(curved_grip(X[i,center], Y[i,center]) - z[i,center]) for i in axes(z,1)) < 1e-9
    errors = [isfinite(z[i,j]) ? abs(curved_grip(X[i,j],Y[i,j])-z[i,j]) : -Inf
              for i in axes(z,1), j in axes(z,2)]
    # The spline is fitted along the reference line, so off-line nodes of a curved road carry an
    # approximation error, measured at 0.001690.
    @test maximum(errors) < 0.002
    @test_throws r"road filename is empty" R.grip("")
    @test_throws r"absent_mu.crg.*does not exist" R.grip("absent_mu.crg")
    @test_throws r"handmade_straight.crg.*NaN" R.grip(joinpath(OPENCRG, "handmade_straight.crg"))
    mktempdir() do dir
        original = read(R.asset_path(ROADS * "ice_patch_mu.crg"), String)
        modified = joinpath(dir, "modified_mu.crg")
        write(modified, replace(original, "\$KD_DEFINITION" =>
            "\$ROAD_CRG_MODS\nREFLINE_OFFSET_X = 10\n\$!\n\$KD_DEFINITION"))
        base = R.grip(ROADS * "ice_patch_mu.crg")
        shifted = R.grip(modified)
        @test shifted(480.0, 0.0) ≈ base(470.0, 0.0)
        @test shifted(440.0, 0.5) ≈ base(430.0, 0.5)
        @test shifted(500.0, -0.5) ≈ base(490.0, -0.5)
        for key in ("Z", "S", "B", "SLOPE", "BANKING")
            bad = joinpath(dir, "start_" * lowercase(key) * ".crg")
            write(bad, replace(original, "\$ROAD_CRG\n" => "\$ROAD_CRG\nREFERENCE_LINE_START_" * key * " = 1\n"))
            @test_throws Regex(basename(bad) * ".*elevation data") R.grip(bad)
        end
        uniform = read(R.asset_path(ROADS * "uniform_mu.crg"), String)
        for channel in ("slope", "banking")
            bad = joinpath(dir, channel * ".crg")
            write(bad, replace(uniform, r"D:long section at v = [^,]*,m" =>
                "D:reference line " * channel * ",rad"; count = 1))
            @test_throws Regex(basename(bad) * ".*elevation data") R.grip(bad)
        end
        straight = joinpath(dir, "constant_phi.crg")
        header, _ = split(uniform, "\$\$\$\$"; limit = 2)
        header = replace(header, "#:LDFI" => "#:LDFI\nD:reference line phi,rad")
        write(straight, header * "\$\$\$\$\n" * repeat(join(lpad(v, 20) for v in ("0.0", "1.0", "1.0", "1.0")) * "\n", 3))
        @test R.grip(straight)(1.0, 0.0) ≈ 1.0
        rotated = joinpath(dir, "rotated_mu.crg")
        angle = 0.7
        write(rotated, replace(original,
            "REFERENCE_LINE_START_PHI = 0" => "REFERENCE_LINE_START_PHI = $angle",
            "REFERENCE_LINE_START_X = 420.0" => "REFERENCE_LINE_START_X = $(420*cos(angle))",
            "REFERENCE_LINE_START_Y = 0" => "REFERENCE_LINE_START_Y = $(420*sin(angle))"))
        rotated_grip = R.grip(rotated)
        for (x, y) in ((450.0, 0.2), (470.0, -0.4), (496.0, 0.0))
            @test rotated_grip(cos(angle)*x-sin(angle)*y, sin(angle)*x+cos(angle)*y) ≈ base(x,y) atol=1e-9
        end
        back = joinpath(dir, "turning_back.crg")
        write(back, header * "\$\$\$\$\n" * join([join(lpad(value,20) for value in
            (string(phi), "1.0", "1.0", "1.0")) for phi in (0.0, 0.8, 1.8)], '\n') * "\n")
        @test_throws r"turning_back.crg.*reference line turns back" R.grip(back)
    end
end

"""
Evaluate a fitted road's coefficients with DataInterpolationsND, independently of its own
evaluator, on the file's grid; NaN beyond it.
"""
function reference_surface(road)
    D = DataInterpolationsND
    dimension(breaks) = D.BSplineInterpolationDimension(breaks, 2;
        extrapolation = D.ExtrapolationType.Constant)
    du, dv = dimension(road.u_breaks), dimension(road.v_breaks)
    surface = D.NDInterpolation(road.coefficients, (du, dv))
    curved = !isempty(road.center)
    center = D.NDInterpolation(curved ? road.center : zeros(length(road.u_breaks) + 1), (du,))
    heading = D.NDInterpolation(curved ? road.heading : zeros(length(road.u_breaks) + 1), (du,))
    return (x, y) -> begin
        u = road.c * (x - road.x0) + road.s * (y - road.y0) + road.u0
        v = -road.s * (x - road.x0) + road.c * (y - road.y0)
        v = curved ? cos(heading(u)) * (v - center(u)) : v
        on_grid = road.u_breaks[1] <= u <= road.u_breaks[end] &&
            road.v_breaks[1] <= v <= road.v_breaks[end]
        on_grid ? surface(u, v) : NaN
    end
end

lookup_allocations(f, args...) = (f(args...); @allocated f(args...))

@testset "Lookup: reference spline on the grid, no allocation" begin
    rng = Xoshiro(1)
    files = vcat([ROADS * f for f in ("hill_z.crg", "ramp_hold_z.crg", "ice_patch_mu.crg")],
        [joinpath(OPENCRG, f) for f in ("handmade_straight.crg", "handmade_curved.crg")])
    for file in files
        road = R.surface(file; elevation = true, fill_missing = 0.0)
        reference = reference_surface(road)
        box = R.extent(file; margin = 20.0)
        points = [(box.x[1] + (box.x[2] - box.x[1]) * rand(rng), box.y[1] + (box.y[2] - box.y[1]) * rand(rng))
                  for _ in 1:2000]
        filter!(p -> !isnan(reference(p...)), points)
        # The reference's slope on the first and last along-road nodes depends on which side its
        # interval search lands, so slopes are compared inside only; the blend testset checks the
        # edges.
        edges = filter(p -> !isnan(reference(p...)), vec([
            (road.x0 + road.c * u - road.s * v, road.y0 + road.s * u + road.c * v)
            for u in road.u_breaks[[1, end]] .- road.u0,
                v in range(road.v_breaks[1], road.v_breaks[end]; length = 5)]))
        scale = max(1.0, maximum(abs(reference(p...)) for p in vcat(points, edges)))
        @test maximum(abs(road(p...) - reference(p...)) for p in vcat(points, edges)) < 1e-12 * scale
        @test maximum(maximum(abs, gradient(road, p...) .- gradient(reference, p...)) for p in points) <
            1e-12 * scale
    end
    grip, slope = R.grip(ROADS * "ice_patch_mu.crg"), R.slope(ROADS * "hill_z.crg")
    # Beyond the blend the road is level at its default height, so the grade is exactly zero.
    @test slope(1.0e4, 0.0, 0.0) == 0.0
    dual = ForwardDiff.Dual{typeof(ForwardDiff.Tag(sin, Float64))}(470.3, 1.0)
    for y in (0.1, 1.9, 5.0)
        @test lookup_allocations(grip, 470.3, y) == 0
        @test lookup_allocations(grip, dual, y) == 0
        @test lookup_allocations(slope, 470.3, y, 0.2) == 0
        @test lookup_allocations(slope, dual, y, 0.2) == 0
    end
end

@testset "Beyond the grid: C1 blend to the default value" begin
    ice = R.grip(ROADS * "ice_patch_mu.crg")
    # The patch grid is 2 m wide; beside it the grip returns to the uniform 1.0.
    @test ice(475.0, 0.0) < 0.31
    @test ice(475.0, 1.0) ≈ ice(475.0, 0.0)
    @test 0.31 < ice(475.0, 2.0) < 1.0
    @test ice(475.0, 3.0) == ice(475.0, -3.0) == ice(475.0, 50.0) == 1.0
    @test ice(600.0, 0.0) == ice(300.0, 0.0) == 1.0
    custom = R.grip(ROADS * "ice_patch_mu.crg"; default_grip = 0.5, blend_width = 4.0)
    @test custom(475.0, 5.0) == 0.5
    @test custom(475.0, 0.0) == ice(475.0, 0.0)
    @test_throws "blend width" R.grip(ROADS * "ice_patch_mu.crg"; blend_width = 0.0)
    ramp = R.surface(ROADS * "ramp_z.crg"; elevation = true)
    # The ramp's plateau ends the grid 10.4 m up, so past x = 1000 m the road drops to the
    # default height over the blend.
    @test ramp(1003.0, 0.0) == ramp(250.0, 1003.0) == 0.0
    @test ramp(500.0, 0.0) ≈ 10.0
    for road in (ice, ramp, R.surface(ROADS * "hill_z.crg"; elevation = true))
        # Value and gradient agree on both sides of the grid edge and of the blend's far end.
        u_edges = (road.u_breaks[1], road.u_breaks[end])
        v_edges = (road.v_breaks[1], road.v_breaks[end])
        across = [(u, 0.5 * sum(v_edges)) for u in (u_edges..., u_edges[1] - 2.0, u_edges[2] + 2.0)]
        append!(across, [(0.5 * sum(u_edges), v) for v in (v_edges..., v_edges[1] - 2.0, v_edges[2] + 2.0)])
        world(u, v) = (road.x0 + road.c * (u - road.u0) - road.s * v,
                       road.y0 + road.s * (u - road.u0) + road.c * v)
        h = 1e-7
        for (u, v) in across, (du, dv) in ((1.0, 0.0), (0.0, 1.0))
            inner, outer = world(u - h * du, v - h * dv), world(u + h * du, v + h * dv)
            @test road(inner...) ≈ road(outer...) atol = 1e-5
            @test gradient(road, inner...) ≈ gradient(road, outer...) atol = 1e-4
        end
        # ForwardDiff agrees with a central difference inside the blend band.
        for (u, v) in ((u_edges[2] + 0.7, 0.5 * sum(v_edges)), (0.5 * sum(u_edges), v_edges[1] - 1.3))
            x, y = world(u, v)
            e = 1e-6
            fd = [(road(x + e, y) - road(x - e, y)) / 2e, (road(x, y + e) - road(x, y - e)) / 2e]
            @test gradient(road, x, y) ≈ fd atol = 1e-6
        end
    end
end

"Raised-cosine hill slope that `assets/data/roads/generate.jl` writes, with level approaches."
hill_slope(x) = 240 <= x <= 400 ? 0.08sin(2pi*(x-240)/160) : 0.0

@testset "Height: analytic directional slopes" begin
    for (file, axis, phi, offset, analytic, bound) in (
        ("flat_z.crg", 0.0:1.0:2.0, 0.0, 0.0, x -> 0.0, 1e-12),
        # The hill's C1 joins to its level approaches have a second-derivative jump that the
        # quadratic spline smooths, measured at 5.554e-4 on the nodes.
        ("hill_z.crg", 220.0:1.0:420.0, 0.0, 0.0, hill_slope, 6e-4),
        ("hill_across_z.crg", 220.0:1.0:420.0, pi/2, -280.0, hill_slope, 6e-4),
        ("ramp_z.crg", 0.0:250.0:500.0, 0.0, 0.0, x -> 0.02, 1e-12),
        ("ramp_hold_z.crg", -250.0:250.0:250.0, 0.0, 0.0, x -> 0.02, 1e-12))
        slope = R.slope(ROADS * file)
        for psi in (0.0, pi/2, pi, pi/4), between in (false, true)
            points = between ? (axis[1:end-1] .+ step(axis)/2) : axis
            @test maximum(abs(slope(x*cos(phi), x*sin(phi)+offset, psi) -
                analytic(x)*cos(psi-phi)) for x in points) < bound
        end
        @test all(isfinite, ForwardDiff.gradient(q -> slope(q...), [280.1, 0.1, 0.3]))
    end
    @test_throws r"\"\".*empty" R.slope("")
    @test_throws r"absent_z.crg.*does not exist" R.slope("absent_z.crg")
    holes = joinpath(OPENCRG, "handmade_straight.crg")
    @test_throws r"handmade_straight.crg.*height grid contains NaN" R.slope(holes)
    @test isfinite(R.slope(holes; fill_missing = 0.0)(1.0, 0.0, 0.0))
    mktempdir() do dir
        source = read(R.asset_path(ROADS * "flat_z.crg"), String)
        combined = joinpath(dir, "reference_elevation.crg")
        write(combined, replace(source, "\$ROAD_CRG\n" => "\$ROAD_CRG\nREFERENCE_LINE_START_Z = 3\nREFERENCE_LINE_START_S = 0.02\nREFERENCE_LINE_START_B = 0.03\n"))
        height = R.surface(combined; elevation = true)
        slope = R.slope(combined)
        # 3 m start height, plus 0.02 x 1 m along and 0.03 x 0.5 m across.
        @test height(1.0, 0.5) ≈ 3.035 atol = 1e-12
        @test slope(1.0, 0.5, 0.0) ≈ 0.02 atol = 1e-12
        @test slope(1.0, 0.5, pi/2) ≈ 0.03 atol = 1e-12
        alias = joinpath(dir, "alias_z.crg")
        write(alias, replace(source, "\$ROAD_CRG\n" => "\$ROAD_CRG\nREFERENCE_LINE_START_SLOPE = 0.02\n"))
        @test_throws r"alias_z.crg.*unsupported start" R.slope(alias)
    end
end

@testset "Height: curved road, world-coordinate chain rule" begin
    file = joinpath(OPENCRG, "handmade_curved.crg")
    height = R.surface(file; elevation = true)
    slope = R.slope(file)
    _, _, X, Y, _ = OpenCRG.road_surface_grid(OpenCRG.read_crg(file))
    errors = Float64[]
    for i in 3:size(X,1)-2, j in 2:size(X,2)-1, psi in (0.0, pi/2, pi, pi/4)
        x, y, h = X[i,j], Y[i,j], 1e-5
        finite_difference = (height(x+h*cos(psi), y+h*sin(psi)) -
            height(x-h*cos(psi), y-h*sin(psi)))/(2h)
        push!(errors, abs(slope(x,y,psi)-finite_difference))
    end
    @test maximum(errors) < 1e-7
    q = [X[5,2], Y[5,2], 0.4]
    h = 1e-5
    finite_gradient = [(slope((q .+ h.*(1:3 .== j))...) - slope((q .- h.*(1:3 .== j))...))/(2h)
        for j in 1:3]
    @test maximum(abs.(ForwardDiff.gradient(p -> slope(p...), q) .- finite_gradient)) < 1e-7
end

@testset "Height: no cliff beside a strip or along it" begin
    # Start heading and lateral offset of the reference line, stations along it, and the grade
    # the generator writes; the fitted hill overshoots its 0.08 by under 6e-4. The samples run
    # 100 m past the last station, which stays inside the ramps' grids: those end high, and the
    # drop past their end is the blend testset's.
    for (file, phi, offset, stations, max_grade, max_height) in (
            ("hill_z.crg", 0.0, 0.0, (260.0, 320.0, 380.0), 0.08, 4.08),
            ("hill_across_z.crg", pi/2, -280.0, (260.0, 320.0, 380.0), 0.08, 4.08),
            ("ramp_z.crg", 0.0, 0.0, (100.0, 250.0, 500.0), 0.02, 10.4),
            ("ramp_hold_z.crg", 0.0, 0.0, (-100.0, 0.0, 250.0), 0.02, 10.4))
        road = R.surface(ROADS * file; elevation = true)
        world(u, v) = (u * cos(phi) - v * sin(phi), u * sin(phi) + v * cos(phi) + offset)
        sideways = [[world(u, v) for v in -50.0:0.25:50.0] for u in stations]
        past = [world(u, 0.0) for u in last(stations):0.25:last(stations) + 100.0]
        points = vcat(past, sideways...)
        heights = [road(p...) for p in points]
        grades = [hypot(gradient(road, p...)...) for p in points]
        @test all(isfinite, heights) && all(isfinite, grades)
        # The fitted hill dips 9e-5 m below zero at its feet, where the cosine meets the level.
        @test all(h -> -1e-4 <= h <= max_height + 1e-9, heights)
        @test maximum(grades) <= 1.01max_grade
        # Level across the road: the height 50 m to either side is the center-line height.
        @test all(line -> maximum(p -> road(p...), line) - minimum(p -> road(p...), line) < 1e-9, sideways)
    end
end

@testset "Mesh: what is drawn is what the tires feel" begin
    hill, ice = ROADS * "hill_z.crg", ROADS * "ice_patch_mu.crg"
    # The patch grid spans x = 420..530 m and y = -1..1 m, grown by the 5 m margin.
    box = R.extent(ice; margin = 5.0)
    @test all(box.x .≈ (415.0, 535.0))
    @test all(box.y .≈ (-6.0, 6.0))
    x, y = 430.0:2.5:520.0, -3.0:0.5:3.0
    mesh = R.mesh(hill; grip_file = ice, x, y)
    nx, ny = length(x), length(y)
    @test mesh.x == collect(x) && mesh.y == collect(y)
    @test size(mesh.height) == size(mesh.grip) == (nx, ny)
    @test length(mesh.vertices) == nx * ny
    @test length(mesh.faces) == 2 * (nx - 1) * (ny - 1)
    @test all(f -> all(in(1:nx*ny), f), mesh.faces)
    @test all(mesh.vertices[i + (j - 1) * nx] == (x[i], y[j], mesh.height[i, j])
              for i in 1:nx, j in 1:ny)
    # Counter-clockwise seen from +z: the z-up frame, not a mirrored one.
    @test all(mesh.faces) do (a, b, c)
        p, q, r = mesh.vertices[a], mesh.vertices[b], mesh.vertices[c]
        (q[1] - p[1]) * (r[2] - p[2]) - (q[2] - p[2]) * (r[1] - p[1]) > 0
    end
    grip = R.grip(ice)
    height = R.surface(hill; elevation = true)
    for (i, j) in ((1, 1), (11, 7), (20, 3), (nx, ny))
        @test mesh.grip[i, j] == grip(x[i], y[j])
        @test mesh.height[i, j] == height(x[i], y[j])
    end
    @test minimum(mesh.grip) < 0.3 && maximum(mesh.grip) ≈ 1.0
    flat = R.mesh(ROADS * "flat_z.crg"; x = -50.0:10.0:50.0, y = -5.0:5.0:5.0)
    @test all(iszero, flat.height)
    @test all(==(1.0), flat.grip)
    # Without a height file the road is level and the sampling box is the grip file's alone.
    grip_only = R.mesh(nothing; grip_file = ice)
    @test all(iszero, grip_only.height)
    @test all(extrema(grip_only.x) .≈ R.extent(ice).x)
    @test all(extrema(grip_only.y) .≈ R.extent(ice).y)
    @test R.extent(R.surface(ice)) == R.extent(ice)
    @test_throws ArgumentError R.mesh(nothing)
    default_axes = R.mesh(ROADS * "hill_across_z.crg")
    @test length(default_axes.vertices) <= 170_000
    @test first(default_axes.x) < -600 && last(default_axes.y) > 140
end

end # module RoadTests
