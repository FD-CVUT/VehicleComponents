# Included into Main by runtests.jl after the harness is loaded, so it sees `ODEAlg` and
# `__dyad_run_test_case!` from generated/test_internals.jl.

function __harness_warm_up_model(; name, __overrides = Dict{String, Any}())
    t = ModelingToolkit.t_nounits
    D = ModelingToolkit.D_nounits
    x = only(ModelingToolkit.@variables x(t))
    return ModelingToolkit.System([D(x) ~ -x], t, [x], []; name, initialization_eqs = [x ~ 1])
end

__dyad_run_test_case!(__harness_warm_up_model, "harness warm-up";
    case_name = "warm_up", component_stem = "warm_up", module_path = String[],
    start = 0.0, stop = 1.0, abstol = 1e-6, reltol = 1e-6, solver = ODEAlg.Auto(),
    expected_final = Tuple[(m -> m.x, "x", exp(-1), 1e-4, 1e-4)])
