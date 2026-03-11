module CMEModules

include("Types.jl")
include("functionstointerp.jl")
include("RootFinding.jl")

using .Types, .functionstointerp, .RootFinding

# Re-export everything for use in assignment scripts
export AbstractDistribution, ParetoDist, LogLogisticDist, n_par_interp  # from Types
export myf                                                              # from functionstointerp
export bisection                                                        # from RootFinding

end
