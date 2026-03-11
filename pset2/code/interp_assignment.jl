""" interp_assignment.jl
===========================================================

This script explores some of the interpolation tools 
shown in Lecture 3.

Author  : Fred Milhome
Project : eesp-CME
Created : March 2026
""" 

# Load environment (skip if pset2 project is already active)
if !endswith(Base.active_project(), joinpath("pset2", "Project.toml"))
    include(joinpath(@__DIR__, "activate_env.jl"))
end

# Load own submodules
if !isdefined(Main, :CMEModules)
    include(joinpath(@__DIR__, "SubModules", "CMEModules.jl"))
end
using .CMEModules

# Load 3rd party packages
using Interpolations, Distributions, Statistics, Random, Plots, CSV, DataFrames, BenchmarkTools, Base.Threads
@info "Threads" nthreads()

# Set seed
Random.seed!(201010)

# Local paths (robust even if globals from another script/session are stale)
const PS2_ROOT = normpath(joinpath(@__DIR__, ".."))
const DATA_RAW_DIR = joinpath(PS2_ROOT, "data", "raw")
const OUT_FIG_DIR = joinpath(PS2_ROOT, "output", "figures")
const OUT_TAB_DIR = joinpath(PS2_ROOT, "output", "tables")
isdir(OUT_FIG_DIR) || mkpath(OUT_FIG_DIR)
isdir(OUT_TAB_DIR) || mkpath(OUT_TAB_DIR)


# PART 1: LIFE EXPECTANCY INTERPOLATION

# Read in life expectancy data
df = CSV.read(joinpath(DATA_RAW_DIR, "life_expectancy.csv"), DataFrame)
years = Float64.(df.year)
life_exp = Float64.(df.life_expectancy)

# Linearly interpolate life expectancy
interp_life_exp = linear_interpolation(years, life_exp)

# Value for 1996
interp_1996 = interp_life_exp(1996.0)
println("Interpolated life expectancy for 1996: $(interp_1996) years")

# Construct plot
scatter(years, life_exp, label = "Data")
plot!(x -> interp_life_exp(x), minimum(years), maximum(years), label = "Linear interp.")
savefig(joinpath(OUT_FIG_DIR, "life_expectancy_interp.png"))

# PART 2: PARETO INTERPOLATION FROM SAMPLE

# Parameters for the exercise
grid_sizes = [10, 15, 20, 30, 50]
distribution_list = [ParetoDist(α = 10.0, x_m = 1.0), LogLogisticDist(η = 5.0, ξ = 500.0)]
spacing_options = ["linear", "log"]

# Helper function to sample from uniform
function generate_sample(n_par::n_par_interp) 
    rand(Uniform(n_par.a, n_par.b), n_par.n_size)
end

# Helper function to create spaced grid
function generate_grid(n_par::n_par_interp)
    # Build interpolation on transformed coordinates so all methods receive an AbstractRange
    coord, invcoord = if n_par.t_spacing == "linear"
        (identity, identity)
    elseif n_par.t_spacing == "log"
        (log, exp)
    elseif n_par.t_spacing == "double_exp"
        (x -> log(log(x)), x -> exp(exp(x)))
    else
        error("Invalid t_spacing option: $(n_par.t_spacing). Choose 'linear', 'log', or 'double_exp'.")
    end

    # Range of untransformed grid points (meaning, always evenly spaced)
    u = range(coord(n_par.a), coord(n_par.b), length = n_par.t_size)
    # Range of transformed grid points
    t = invcoord.(u)

    return coord, u, t
end

# Helper function to compare interpolation methods for different functions and numerical parameters
function interp_compare(dist::AbstractDistribution, n_par::n_par_interp, 
                        sample::Vector{Float64},
                        omit_true::Bool = true, omit_ind_plots::Bool = true)

    # Compute true function values at trying points for MSE calculation
    true_vals = myf.(dist, sample)

    # Construct grid for interpolation and evaluate function at grid points for interpolation
    coord, u, t = generate_grid(n_par)
    vals = myf.(dist, t)

    # BENCHMARK PART
    samples_for_each_b = 10000

    # Run linear interpolation once for JIT
    linear_interpolation(u, vals)

    t_lin = Threads.@spawn @benchmark linear_interpolation($u, $vals) samples = samples_for_each_b
    t_spl = Threads.@spawn @benchmark cubic_spline_interpolation($u, $vals) samples = samples_for_each_b
    t_pchip = Threads.@spawn @benchmark interpolate($u, $vals, FritschButlandMonotonicInterpolation()) samples = samples_for_each_b

    benchmark_lin = fetch(t_lin)
    benchmark_spl = fetch(t_spl)
    benchmark_pchip = fetch(t_pchip)

    avg_times = Dict(
        "lin"   => mean(benchmark_lin.times),
        "spl"   => mean(benchmark_spl.times),
        "pchip" => mean(benchmark_pchip.times)
    )

    # FIT COMPARISON PART

    # Init dicts
    mse = Dict{String, Float64}()
    interp_vals = Dict{String, Vector{Float64}}()

    # Interpolate in transformed coordinates
    interp_lin = linear_interpolation(u, vals)
    interp_spl = cubic_spline_interpolation(u, vals)
    interp_pchip = interpolate(u, vals, FritschButlandMonotonicInterpolation())

    interps = Dict(
        "lin"   => interp_lin,
        "spl"   => interp_spl,
        "pchip" => interp_pchip
    )

    # Loop across interpolation methods for MSEs and plotting
    methods = ["lin", "spl", "pchip"]

    # Plotting true values
    p = scatter(sample, true_vals, label = "Data", title = "$(dist.name), $(n_par.t_spacing) spacing", xlabel = "x", ylabel = "Function",
            markersize = 2, markerstrokewidth = 0)

    sample_u = coord.(sample)

    for m in methods
        interp = interps[m]
        interp_vals[m] = interp.(sample_u)
        mse[m] = mean((true_vals .- interp_vals[m]).^2)
        plot!(p, x -> interp(coord(x)), n_par.a, n_par.b, label = "$m, MSE = $(round(mse[m], digits=4))")
    end

    # Plotting options
    !omit_true && plot!(p, x -> myf(dist, x), n_par.a, n_par.b, label = "True Function")
    !omit_ind_plots && savefig(joinpath(OUT_FIG_DIR, "$(dist.name)_t$(n_par.t_size)_$(n_par.t_spacing)spacing_interp_ind.png"))

    return p, mse, avg_times
end

# IMPLEMENTATION: Loop across distributions and grid sizes for plotting and tabulating MSEs

# Create dicts to store MSEs by dist and spacing, and plots for each t_size
panel_mses_by_group = Dict{Tuple{String,String},DataFrame}()

for dist in distribution_list
    for spacing in spacing_options
        key = (dist.name, spacing)
        panel_mses_by_group[key] = DataFrame(
            dist=String[], t_size=Int[], spacing=String[],
            lin_mse=Float64[], lin_time=Float64[], spl_mse=Float64[], spl_time=Float64[], pchip_mse=Float64[], pchip_time=Float64[]
        )
    end
end

panel_plots = Dict{Int, Vector{Any}}()

# initialize t_size and spacing due to my program logic
t_size = 10
spacing = "linear"
panel_plots = Dict{Int, Vector{Any}}(t_size => Vector{Any}() for t_size in grid_sizes)

# Main loop to populate MSE tables and plots
for dist in distribution_list
    n_par = dist isa ParetoDist ?
                n_par_interp(n_size=2500, t_size=t_size, t_spacing=spacing, a=1.0, b=5.0) :
                n_par_interp(n_size=2500, t_size=t_size, t_spacing=spacing, a=200.0, b=1000.0)
    sample = generate_sample(n_par)
    for spacing in spacing_options
        for t_size in grid_sizes
            # Set up n_par_interp for this loop iteration
            n_par_iter = n_par_interp(
                n_size = n_par.n_size,
                t_size = t_size,
                t_spacing = spacing,
                a = n_par.a,
                b = n_par.b
            )
            # Apply interpolation comparison function and store results
            p, mse, avg_times = interp_compare(dist, n_par_iter, sample)
            # Store to dicts
            push!(panel_plots[t_size], p)
            push!(panel_mses_by_group[(dist.name, spacing)],
                  (dist.name, t_size, spacing, mse["lin"], avg_times["lin"], mse["spl"], avg_times["spl"], mse["pchip"], avg_times["pchip"]))
        println("Completed interpolation comparison for $(dist.name) with $(spacing) spacing and t_size=$(t_size).")
        end
    end
end

# Export tables to compare MSEs across methods and grid sizes for each distribution and spacing combination
for key in keys(panel_mses_by_group)
    df = panel_mses_by_group[key]
    # Drop dist and spacing columns — the filename identifies the pair
    df_export = select(df, Not([:dist, :spacing]))
    fname = replace("$(key[1])_$(key[2])", " " => "_")
    CSV.write(joinpath(OUT_TAB_DIR, "mse_times_$(fname).csv"), df_export)
    println("Exported table for $(key[1]) with $(key[2]) spacing.")
end

# Generate plots to compare interpolants across distributions and spacing for each grid size
for t_size in grid_sizes
    p = plot(panel_plots[t_size]..., layout=(2,2), plot_title = "Interpolants comparison for $(t_size) points",
    size=(800, 600))
    savefig(joinpath(OUT_FIG_DIR, "panel_interp_t$(t_size).png"))
end