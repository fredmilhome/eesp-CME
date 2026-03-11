module Types

abstract type AbstractDistribution end
Base.broadcastable(d::AbstractDistribution) = Ref(d)  # treat as scalar in broadcasts

Base.@kwdef struct ParetoDist <: AbstractDistribution
    α::Float64
    x_m::Float64
    name::String = "Pareto PDF"
end
Base.@kwdef struct LogLogisticDist <: AbstractDistribution
    η::Float64
    ξ::Float64
    name::String = "Log-Logistic CDF"

end

Base.@kwdef struct n_par_interp
    n_size::Int # Number of observations in the sample for the trying points
    t_size::Int # Number of points for the interpolation
    t_spacing::String = "linear" # Spacing for interpolation points, either :linear or :log
    a::Float64  # Lower bound for uniform distribution
    b::Float64  # Upper bound for uniform distribution
end

export AbstractDistribution, ParetoDist, LogLogisticDist, n_par_interp

end