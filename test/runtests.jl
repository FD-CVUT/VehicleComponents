# Test tiers over the Dyad test models the compiler turns into `generated/**/<Model>_test.jl`.
#
#   fast      every test model under a `Tests` submodule, in this process, each rig timed and
#             failed past RIG_BUDGET_S (the default tier, and what `Pkg.test()` runs)
#   examples  every test model under `Examples`, each in its own child process
#   example   one rig file, relative to `generated/`; what the examples tier spawns
#
# Select the tier with the first argument (`test/runtests.jl examples`) or with
# `Pkg.test(test_args = ["examples"])`.

# Snapshot paths resolve against the working directory, so every entry point runs from here.
cd(@__DIR__)

using Test

const GENERATED = normpath(@__DIR__, "..", "generated")
const RIG_BUDGET_S = 30

"""
    rig_files() -> Vector{String}

Every generated test file that holds at least one test case, relative to `generated/`. The
compiler writes a `_test.jl` for every component, so files without a case are skipped.
"""
function rig_files()
    files = String[]
    for (root, _, names) in walkdir(GENERATED), name in names
        endswith(name, "_test.jl") || continue
        path = joinpath(root, name)
        occursin("__dyad_run_test_case!(", read(path, String)) && push!(files, relpath(path, GENERATED))
    end
    return sort!(files)
end

function tier_of(rig)
    modules = splitpath(rig)
    first(modules) == "Examples" && return :examples
    return "Tests" in modules ? :fast : :unplaced
end

rigs(tier) = filter(r -> tier_of(r) == tier, rig_files())

rig_name(rig) = join([splitpath(dirname(rig)); replace(basename(rig), r"_test\.jl$" => "")], '.')

# Package load and the harness's own plotting and CSV dependencies stay out of every rig's time.
function load_harness()
    @eval Main using VehicleComponents
    @eval Main import ModelingToolkit
    Base.include(Main, joinpath(GENERATED, "test_internals.jl"))
end

"""
    warm_up()

Run a one-state model through the same test-case path the rigs take, outside any timing. A
cold process spends about a minute compiling that path on the first model it simulates, which
would otherwise land on whichever rig runs first and fail it against the budget.
"""
function warm_up()
    elapsed = @elapsed Base.include(Main, joinpath(@__DIR__, "warm_up.jl"))
    println("Harness warm-up: $(round(elapsed; digits = 1)) s")
end

run_rig(rig) = @elapsed @testset "$(rig_name(rig))" begin
    Base.include(Main, joinpath(GENERATED, rig))
end

function run_fast()
    fast = rigs(:fast)
    isempty(fast) && @warn "No test models under a `Tests` submodule; the fast tier ran no rigs."
    load_harness()
    isempty(fast) || warm_up()
    @testset verbose = true "fast tier" begin
        @testset "every test model sits in a Tests or Examples submodule" begin
            @test rig_name.(rigs(:unplaced)) == String[]
        end
        for rig in fast
            elapsed = run_rig(rig)
            @testset "$(rig_name(rig)) runs within $RIG_BUDGET_S s" begin
                @test elapsed <= RIG_BUDGET_S
            end
        end
    end
end

function run_examples()
    examples = rigs(:examples)
    isempty(examples) && @warn "No test models under `Examples`; the example tier ran no rigs."
    project = Base.active_project()
    rows = map(examples) do rig
        name = rig_name(rig)
        printstyled("\n── $name ──\n"; bold = true)
        cmd = `$(Base.julia_cmd()) --project=$project --color=yes $(@__FILE__) example $rig`
        proc = nothing
        time = @elapsed proc = run(ignorestatus(cmd))
        status = success(proc) ? "ok" :
                 proc.termsignal != 0 ? "killed (signal $(proc.termsignal))" :
                 "failed (exit $(proc.exitcode))"
        (; name, time, status)
    end
    if !isempty(rows)
        width = maximum(r -> length(r.name), rows)
        println("\n", rpad("Example", width), "   Time  Status")
        for r in rows
            println(rpad(r.name, width), lpad(string(round(r.time; digits = 1), "s"), 7), "  ", r.status)
        end
    end
    all(r -> r.status == "ok", rows) || exit(1)
end

function run_example(rig)
    load_harness()
    run_rig(rig)
end

const TIER = get(ARGS, 1, "fast")

if TIER == "fast"
    run_fast()
elseif TIER == "examples"
    run_examples()
elseif TIER == "example" && length(ARGS) == 2
    run_example(ARGS[2])
else
    error("unknown test tier $(repr(TIER)); use fast, examples, or example <rig>")
end
