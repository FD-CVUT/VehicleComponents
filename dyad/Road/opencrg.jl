# OpenCRG road surfaces as the callables behind `Road.Grip` and `Road.Slope`.

import DyadData, ForwardDiff, OpenCRG
using LinearAlgebra: Tridiagonal, lu
using ModelingToolkit: Symbolics

"Resolve a `dyad://` or `file://` road asset to its file, or pass a filesystem path through."
asset_path(file::AbstractString) = occursin("://", file) ? uri_path(DyadData.parse_uri(file)...) : file

function uri_path(scheme, location)
    scheme == "dyad" && return DyadData.resolve_dyad_uri(location)
    scheme == "file" && return location
    error("a road file must be local, not a $scheme URI")
end

"Innermost real value of a possibly nested `ForwardDiff.Dual`."
primal(x::ForwardDiff.Dual) = primal(ForwardDiff.value(x))
primal(x::Real) = x

"""
    quadratic_basis(breaks, t) -> (i, b0, b1, b2, beyond)

Nonzero basis values of the clamped quadratic B-spline on strictly increasing `breaks` at `t`:
coefficients `i`, `i+1`, `i+2` carry weights `b0`, `b1`, `b2`. Outside the breaks the spline
continues along the tangent at the nearer edge, so it stays C1 there; `beyond` is the distance
from `t` to that edge, zero inside. Generic in the number type of `t`, including
`ForwardDiff.Dual`, and allocation-free.
"""
@inline function quadratic_basis(breaks::Vector{Float64}, t)
    m = length(breaks)
    @inbounds first_break, last_break = breaks[1], breaks[m]
    # Compare primal values: on the edge itself the spline's one-sided slope applies in every direction.
    value = primal(t)
    held = value < first_break ? first_break + zero(t) : value > last_break ? last_break + zero(t) : t
    i = clamp(searchsortedlast(breaks, value), 1, m - 1)
    @inbounds begin
        left, right = breaks[i], breaks[i+1]
        before, after = breaks[max(i - 1, 1)], breaks[min(i + 2, m)]
    end
    # Cox-de Boor for degree 2; the clamped end knots repeat the first and last breaks.
    scale = 1 / (right - left)
    n0, n1 = (right - held) * scale, (held - left) * scale
    w0 = n0 / (right - before)
    w1 = n1 / (after - left)
    # Edge value plus edge slope times the overshoot; the basis slopes are -2w0, 2(w0-w1), 2w1.
    overshoot = t - held
    return i, (right - held) * w0 - 2 * w0 * overshoot,
        (held - before) * w0 + (after - held) * w1 + 2 * (w0 - w1) * overshoot,
        (held - left) * w1 + 2 * w1 * overshoot, abs(overshoot)
end

"""
    blend_weight(beyond, width)

Weight of a road file's spline at distance `beyond` outside its grid: one on the grid, falling
to zero at `width` along a cubic smoothstep whose slope vanishes at both ends, so the blend to
the default value is C1.
"""
@inline function blend_weight(beyond, width)
    q = beyond / width
    return primal(q) >= 1 ? zero(q) : 1 - q * q * (3 - 2 * q)
end

"""
    spline_dimension(axis) -> (breaks, collocation)

Breaks of the quadratic B-spline that interpolates at the nodes `axis`, and the LU factors of
its collocation matrix: row `k` holds the [`quadratic_basis`](@ref) weights at `axis[k]`, so
fitting and evaluation share one basis.
"""
function spline_dimension(axis)
    n = length(axis)
    n >= 3 || error("a road grid needs at least three nodes per axis")
    breaks = Float64[first(axis); [(axis[j] + axis[j+1]) / 2 for j in 2:n-2]; last(axis)]
    # Each node lies in the break interval centered on it, so its row is tridiagonal; a weight
    # off the band would make `setindex!` throw.
    collocation = Tridiagonal(zeros(n - 1), zeros(n), zeros(n - 1))
    for (k, t) in enumerate(axis)
        i, b0, b1, b2, _ = quadratic_basis(breaks, t)
        for (column, weight) in zip(i:i+2, (b0, b1, b2))
            collocation[k, column] = weight
        end
    end
    return breaks, lu(collocation)
end

"""
    Surface(x0, y0, c, s, u0, u_breaks, v_breaks, coefficients, center, heading, extent,
        default, blend)

C1 quadratic B-spline road surface of world `(x, y)`, taking the value `default` beyond its
grid. World points are rotated by the start heading (`c`, `s`) about the reference-line start
`(x0, y0)` into along-road `u` (offset by `u0`) and lateral `v`. Empty `center` and `heading`
mean a straight reference line; otherwise they are spline coefficients over `u_breaks` of the
reference line's lateral offset and heading in the start frame, and `v` is measured from that
line along its normal. `extent` is the world bounding box `(; x = (xmin, xmax), y = (ymin,
ymax))` of the file's grid. Within `blend` meters outside the grid, in `u` or `v`, the surface
fades from the spline, continued along its edge tangent, to `default` with
[`blend_weight`](@ref). Calls with numbers run the spline; calls with symbolic arguments stay
one opaque term.
"""
struct Surface <: Function
    x0::Float64
    y0::Float64
    c::Float64
    s::Float64
    u0::Float64
    u_breaks::Vector{Float64}
    v_breaks::Vector{Float64}
    coefficients::Matrix{Float64}
    center::Vector{Float64}
    heading::Vector{Float64}
    extent::@NamedTuple{x::NTuple{2, Float64}, y::NTuple{2, Float64}}
    default::Float64
    blend::Float64
end

(surface::Surface)(x, y) = lookup(surface, x, y)

# Short form, so a symbolic `lookup(surface, x, y)` in an equation or an error prints one line.
Base.show(io::IO, s::Surface) = print(io, "Road.Surface(",
    length(s.u_breaks) + 1, "x", length(s.v_breaks) + 1, " grid, x = ", s.extent.x,
    ", y = ", s.extent.y, ", default = ", s.default, ")")

"Evaluate a fitted road surface at world x and y."
function lookup(surface::Surface, x, y)
    dx, dy = x - surface.x0, y - surface.y0
    u = surface.c * dx + surface.s * dy + surface.u0
    v = -surface.s * dx + surface.c * dy
    i, a0, a1, a2, beyond_u = quadratic_basis(surface.u_breaks, u)
    if !isempty(surface.center)
        center, heading = surface.center, surface.heading
        @inbounds v = cos(a0 * heading[i] + a1 * heading[i+1] + a2 * heading[i+2]) *
            (v - (a0 * center[i] + a1 * center[i+1] + a2 * center[i+2]))
    end
    j, b0, b1, b2, beyond_v = quadratic_basis(surface.v_breaks, v)
    C = surface.coefficients
    @inbounds spline = a0 * (b0 * C[i, j] + b1 * C[i, j+1] + b2 * C[i, j+2]) +
        a1 * (b0 * C[i+1, j] + b1 * C[i+1, j+1] + b2 * C[i+1, j+2]) +
        a2 * (b0 * C[i+2, j] + b1 * C[i+2, j+1] + b2 * C[i+2, j+2])
    w = blend_weight(beyond_u, surface.blend) * blend_weight(beyond_v, surface.blend)
    # On the grid w is exactly one and the default term exactly zero, so the spline is unchanged.
    return spline * w + surface.default * (1 - w)
end

Symbolics.@register_symbolic lookup(surface::Surface, x, y)

"Run `f`, prefixing any error it raises with the road file's name."
function with_file(f, file)
    try
        f()
    catch e
        error("$file: $(sprint(showerror, e))")
    end
end

# OpenCRG.jl 0.1 reads the standard _S/_B start keys, not these spelled-out aliases.
const START_ALIAS = r"(?im)^\s*REFERENCE_LINE_START_(?:SLOPE|BANKING)\s*=\s*([^\s!]*)"

"""
    surface(file; fill_missing = nothing, elevation = false,
        default_value = elevation ? 0.0 : 1.0, blend_width = 2.0) -> Surface

Load an OpenCRG grid and fit its world-coordinate [`Surface`](@ref): the file's value on its
grid, `default_value` from `blend_width` meters beyond it, and a C1 blend between. Missing grid
values become `fill_missing`, or raise without it. With `elevation = false` the file must carry
grip only: slope, banking or a reference-line start elevation is an error.
"""
function surface(file::AbstractString; fill_missing = nothing, elevation = false,
        default_value = elevation ? 0.0 : 1.0, blend_width = 2.0)
    kind = elevation ? "height" : "grip"
    isfinite(default_value) || throw(ArgumentError("$file: default $kind must be finite"))
    blend_width > 0 && isfinite(blend_width) ||
        throw(ArgumentError("$file: blend width must be positive and finite"))
    isempty(file) && error("$(repr(file)): road filename is empty")
    return with_file(file) do
        path = asset_path(file)
        isfile(path) || error("road file does not exist")
        data = OpenCRG.read_crg(path)
        if any(isnan, data.z)
            fill_missing === nothing && error("$kind grid contains NaN")
            isfinite(fill_missing) || error("fill_missing must be finite")
            replace!(data.z, NaN => Float64(fill_missing))
        end
        # The reader leaves absent heading samples as NaN, even for a straight reference line.
        replace!(data.phi, NaN => data.refline.start_phi)
        u, v, X, Y, z = OpenCRG.road_surface_grid(data)
        r = data.refline
        for m in eachmatch(START_ALIAS, readuntil(path, "\$\$\$\$"))
            elevation && error("unsupported start slope/banking alias; use REFERENCE_LINE_START_S or REFERENCE_LINE_START_B")
            tryparse(Float64, m.captures[1]) == 0.0 ||
                error("elevation data (slope or banking start value) is not grip")
        end
        !elevation && (data.slope !== nothing || data.banking !== nothing ||
            r.start_z != 0 || r.start_slope != 0 || r.start_banking != 0) &&
            error("elevation data (slope, banking, or reference-line start elevation) is not grip")
        all(isfinite, z) || error("$kind grid contains nonfinite values after modifiers")
        all(>(0), diff(u)) && all(>(0), diff(v)) || error("grid axes must increase")
        # Grid columns are affine in v, including the reader's corner-normal rescaling, so
        # extrapolate them to v = 0 rather than choosing an offset grid column.
        cx = X[:,1] .- v[1] .* (X[:,end] .- X[:,1]) ./ (v[end] - v[1])
        cy = Y[:,1] .- v[1] .* (Y[:,end] .- Y[:,1]) ./ (v[end] - v[1])
        mods = data.mods
        anchored = any(f -> getfield(mods, f) !== nothing,
            (:refpoint_x, :refpoint_y, :refpoint_z, :refpoint_phi))
        phi = anchored ? something(mods.refpoint_phi, 0.0) :
            r.start_phi + something(mods.refline_offset_phi, 0.0)
        c, s = cos(phi), sin(phi)
        xaxis = c .* (cx .- cx[1]) .+ s .* (cy .- cy[1])
        center = -s .* (cx .- cx[1]) .+ c .* (cy .- cy[1])
        all(>(0), diff(xaxis)) || error("reference line turns back in its start frame")
        v_breaks, across = spline_dimension(v)
        # A straight road keeps its file's arc-length axis, so the spline matches the file's
        # nodes exactly.
        straight = maximum(abs, center) <= 1e-12 * max(1.0, last(xaxis))
        u_breaks, along = spline_dimension(straight ? u : xaxis)
        coefficients = permutedims(across \ permutedims(along \ z))
        if straight
            u0, center_coefficients, heading_coefficients = first(u), Float64[], Float64[]
        else
            heading = [atan(center[min(i+1,end)] - center[max(i-1,1)],
                            xaxis[min(i+1,end)] - xaxis[max(i-1,1)]) for i in eachindex(xaxis)]
            u0, center_coefficients, heading_coefficients = 0.0, along \ center, along \ heading
        end
        Surface(cx[1], cy[1], c, s, u0, u_breaks, v_breaks, coefficients,
            center_coefficients, heading_coefficients, (; x = extrema(X), y = extrema(Y)),
            default_value, blend_width)
    end
end

"""
    grip(file; fill_missing = nothing, default_grip = 1.0, blend_width = 2.0) -> Surface

A `Grip` callable: load an OpenCRG grip file once and return a C1 function of world x
and y in meters, the file's grip on its grid and `default_grip` from `blend_width` meters
beyond it.
"""
grip(file::AbstractString; fill_missing = nothing, default_grip = 1.0, blend_width = 2.0) =
    surface(file; fill_missing, elevation = false, default_value = default_grip, blend_width)

"""
    slope(file; fill_missing = nothing, default_height = 0.0, blend_width = 2.0) -> SurfaceSlope

A `Slope` callable: load an OpenCRG height file once and return a function of world x and y
in meters and heading in radians, giving tan of the road angle along that heading. Beyond the
grid the road is level at `default_height`, reached over `blend_width` meters.
"""
slope(file::AbstractString; fill_missing = nothing, default_height = 0.0, blend_width = 2.0) =
    SurfaceSlope(surface(file; fill_missing, elevation = true, default_value = default_height,
        blend_width))

"""
    SurfaceSlope(height::Surface)

Tan of the road angle of the height surface `height` along a heading: called with world x and y
in meters and heading in radians. [`slope`](@ref) builds one; `height` is the fitted surface it
differentiates, which [`mesh`](@ref) draws.
"""
struct SurfaceSlope <: Function
    height::Surface
end

(road::SurfaceSlope)(x, y, psi) = directional_slope(road.height, x, y, psi)

Base.show(io::IO, road::SurfaceSlope) = print(io, "Road.SurfaceSlope(", road.height, ")")

"Directional derivative of a height surface along heading `psi`; one opaque term symbolically."
directional_slope(height::Function, x, y, psi) = ForwardDiff.derivative(t ->
    height(x + t * cos(psi), y + t * sin(psi)), zero(x + y + psi))

Symbolics.@register_symbolic directional_slope(height::Function, x, y, psi)

"""
    extent(roads...; margin = 20.0) -> (; x = (xmin, xmax), y = (ymin, ymax))

World bounding box, in meters, of the grids of one or more fitted roads, a [`Surface`](@ref)
or a [`SurfaceSlope`](@ref), grown by `margin` on every side. Use it to pick the sampling window
for [`mesh`](@ref).
"""
function extent(roads::Union{Surface, SurfaceSlope}...; margin = 20.0)
    isempty(roads) && throw(ArgumentError("extent needs at least one road"))
    boxes = map(road -> height_surface(road).extent, roads)
    return (; x = (minimum(b -> b.x[1], boxes) - margin, maximum(b -> b.x[2], boxes) + margin),
              y = (minimum(b -> b.y[1], boxes) - margin, maximum(b -> b.y[2], boxes) + margin))
end

height_surface(road::Surface) = road
height_surface(road::SurfaceSlope) = road.height

"""
    sample_axes(roads...; margin = 20.0, max_points = 160_000, min_step = 0.25) -> (; x, y)

Evenly spaced world sample axes over [`extent`](@ref) with one spacing on both axes, no finer
than `min_step` meters and with at most about `max_points` grid points.
"""
function sample_axes(roads::Union{Surface, SurfaceSlope}...; margin = 20.0,
        max_points = 160_000, min_step = 0.25)
    box = extent(roads...; margin)
    wx, wy = box.x[2] - box.x[1], box.y[2] - box.y[1]
    step = max(min_step, sqrt(wx * wy / max_points))
    return (; x = range(box.x[1], box.x[2]; length = max(2, ceil(Int, wx / step) + 1)),
              y = range(box.y[1], box.y[2]; length = max(2, ceil(Int, wy / step) + 1)))
end

"""
    mesh(height; grip = nothing, x, y) -> (; x, y, vertices, faces, height, grip)

Sample a road on the world grid `x` by `y` (meters) for drawing.

`height` is the fitted road a [`slope`](@ref) callable holds (or its height
[`Surface`](@ref)), and `grip` the [`Surface`](@ref) that [`grip`](@ref) returns, so the
picture is what the tires feel, with the same default values, blend width and missing-value
policy, including the blend to the defaults beyond a file's grid. Without `height` (`nothing`)
the road is flat at zero; without `grip` the grip is one everywhere. At least one road is
needed. `x` and `y` default to [`sample_axes`](@ref) over the roads given.

Everything is in the CRG world frame: right-handed and z-up, x and y the planar car's world
coordinates. Returns plain arrays:

- `x::Vector{Float64}` (length `nx`), `y::Vector{Float64}` (length `ny`): the sample axes.
- `height::Matrix{Float64}`, `grip::Matrix{Float64}` (`nx` by `ny`): `height[i, j]` is the road
  elevation and `grip[i, j]` the grip multiplier at `(x[i], y[j])`; ready for a top-view
  `heatmap(x, y, grip)`.
- `vertices::Vector{NTuple{3, Float64}}`: `(x[i], y[j], height[i, j])` at linear index
  `i + (j - 1) * nx`, so `vec(height)` and `vec(grip)` are per-vertex values.
- `faces::Vector{NTuple{3, Int}}`: two counter-clockwise triangles (seen from +z) per grid cell,
  1-based indices into `vertices`.

A y-up scene such as the multibody world takes each vertex through `(x, y, z) -> (x, z, -y)`, a
proper rotation about x. The swap `(x, z, y)` is a mirror: it reverses face winding and the sign
of yaw.
"""
function mesh(height::Union{Nothing, Surface, SurfaceSlope};
        grip::Union{Nothing, Surface} = nothing, x = nothing, y = nothing)
    height === grip === nothing && throw(ArgumentError("mesh needs a height, a grip, or both"))
    elevation = height === nothing ? nothing : height_surface(height)
    if x === nothing || y === nothing
        sampled = sample_axes((r for r in (elevation, grip) if r !== nothing)...)
        x = something(x, sampled.x)
        y = something(y, sampled.y)
    end
    xs, ys = collect(Float64, x), collect(Float64, y)
    nx, ny = length(xs), length(ys)
    nx >= 2 && ny >= 2 || throw(ArgumentError("mesh needs at least two samples per axis"))
    sample(road, fallback) = road === nothing ? fill(fallback, nx, ny) :
        Float64[road(xi, yi) for xi in xs, yi in ys]
    heights, grip_values = sample(elevation, 0.0), sample(grip, 1.0)
    vertices = vec([(xs[i], ys[j], heights[i, j]) for i in 1:nx, j in 1:ny])
    index(i, j) = i + (j - 1) * nx
    faces = NTuple{3, Int}[]
    sizehint!(faces, 2 * (nx - 1) * (ny - 1))
    for j in 1:ny-1, i in 1:nx-1
        push!(faces, (index(i, j), index(i + 1, j), index(i + 1, j + 1)))
        push!(faces, (index(i, j), index(i + 1, j + 1), index(i, j + 1)))
    end
    return (; x = xs, y = ys, vertices, faces, height = heights, grip = grip_values)
end
