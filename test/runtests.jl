# Test tiers over the Dyad test models the compiler turns into `generated/**/<Model>_test.jl`.
#
#   fast      every test model under a `Tests` submodule, in this process, each rig timed and
#             failed past RIG_BUDGET_S (the default tier, and what `Pkg.test()` runs)
#   examples  every test model under `Examples`, each in its own child process
#   example   one rig file, relative to `generated/`; what the examples tier spawns
#
# Select the tier with the first argument (`julia --project test/runtests.jl examples`), with
# `Pkg.test(test_args = ["examples"])`, or with the TEST_TIER environment variable.

# Snapshot paths resolve against the working directory, so every entry point runs from here.
cd(@__DIR__)

using Test

const GENERATED = normpath(@__DIR__, "..", "generated")
const RIG_BUDGET_S = 30.0

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
        occursin("__dyad_run_test_case!(", read(path, String)) || continue
        push!(files, relpath(path, GENERATED))
    end
    return sort!(files)
end

function tier_of(rig)
    modules = splitpath(dirname(rig))
    !isempty(modules) && first(modules) == "Examples" && return :examples
    return "Tests" in modules ? :fast : :unplaced
end

rig_name(rig) = join([splitpath(dirname(rig)); replace(basename(rig), r"_test\.jl$" => "")], '.')

# Package load and the harness's own plotting and CSV dependencies stay out of every rig's time.
function load_harness()
    @eval Main using VehicleComponents
    @eval Main import ModelingToolkit
    Base.include(Main, joinpath(GENERATED, "test_internals.jl"))
    return nothing
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
    return nothing
end

function run_rig(rig)
    stats = @timed @testset "$(rig_name(rig))" begin
        Base.include(Main, joinpath(GENERATED, rig))
    end
    return stats.time
end

function print_times(rows)
    isempty(rows) && return nothing
    width = maximum(r -> length(r.name), rows)
    println("\n", rpad("Rig", width), "   Time  Status")
    for r in rows
        println(rpad(r.name, width), lpad(string(round(r.time; digits = 1), "s"), 7), "  ", r.status)
    end
    return nothing
end

function run_fast()
    rigs = rig_files()
    unplaced = filter(r -> tier_of(r) == :unplaced, rigs)
    fast = filter(r -> tier_of(r) == :fast, rigs)
    isempty(fast) && @warn "No test models under a `Tests` submodule; the fast tier ran no rigs."
    load_harness()
    isempty(fast) || warm_up()
    rows = []
    @testset "fast tier" begin
        @testset "every test model sits in a Tests or Examples submodule" begin
            @test isempty(unplaced)
            isempty(unplaced) || println("Move these test models: ", join(rig_name.(unplaced), ", "))
        end
        for rig in fast
            elapsed = run_rig(rig)
            within = elapsed <= RIG_BUDGET_S
            push!(rows, (; name = rig_name(rig), time = elapsed,
                status = within ? "ok" : "over the $(Int(RIG_BUDGET_S)) s budget"))
            @testset "$(rig_name(rig)) runs within $(Int(RIG_BUDGET_S)) s" begin
                @test elapsed <= RIG_BUDGET_S
            end
        end
        print_times(rows)
    end
    return nothing
end

function run_examples()
    examples = filter(r -> tier_of(r) == :examples, rig_files())
    isempty(examples) && @warn "No test models under `Examples`; the example tier ran no rigs."
    project = Base.active_project()
    rows = []
    for rig in examples
        printstyled("\n── $(rig_name(rig)) ──\n"; bold = true)
        cmd = `$(Base.julia_cmd()) --project=$project --color=yes $(@__FILE__) example $rig`
        started = time()
        proc = run(ignorestatus(cmd))
        status = success(proc) ? "ok" :
                 proc.termsignal != 0 ? "killed (signal $(proc.termsignal))" :
                 "failed (exit $(proc.exitcode))"
        push!(rows, (; name = rig_name(rig), time = time() - started, status))
    end
    print_times(rows)
    all(r -> r.status == "ok", rows) || exit(1)
    return nothing
end

function run_example(rig)
    tier_of(rig) == :examples || error("$rig is not under generated/Examples")
    load_harness()
    run_rig(rig)
    return nothing
end

const TIER = isempty(ARGS) ? get(ENV, "TEST_TIER", "fast") : ARGS[1]

if TIER == "fast"
    run_fast()
elseif TIER == "examples"
    run_examples()
elseif TIER == "example" && length(ARGS) == 2
    run_example(ARGS[2])
else
    error("unknown test tier $(repr(TIER)); use fast, examples, or example <rig>")
end
