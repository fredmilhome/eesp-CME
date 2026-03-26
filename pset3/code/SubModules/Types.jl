# Talking to Claude, I figured it would be best to define types
# over methods and define functions that take the types themselves
# as arguments, then wrapping up on generic functions, making use
# of multiple dispatch to call the right method, and writing cleaner
# loops. "I" by the end of each concrete type indicates 
# I'm instantiating a method's parameters, not calling it.

# ============================================================
# Differentiation types
# ============================================================

abstract type AbstractDifferentiator end

Base.@kwdef struct CentralFDI  <: AbstractDifferentiator
    h::Float64 = 1e-7 
    coefs::Int = 2
end

# ============================================================
# Optimization types
# ============================================================

abstract type AbstractOptimizer end

struct NelderMeadI      <: AbstractOptimizer; x0::Vector{Float64} end
struct GradientDescentI <: AbstractOptimizer; x0::Vector{Float64} end
NelderMeadI(;      x0) = NelderMeadI(x0 isa Real      ? [Float64(x0)] : Vector{Float64}(x0))
GradientDescentI(; x0) = GradientDescentI(x0 isa Real ? [Float64(x0)] : Vector{Float64}(x0))

struct CRSI <: AbstractOptimizer
    N_args  ::Int
    lb      ::Vector{Float64}
    ub      ::Vector{Float64}
    pop     ::Int
    maxeval ::Int
end
function CRSI(; N_args, lb, ub, pop=300, maxeval=15_000)
    tovec(v) = v isa Real ? [Float64(v)] : Vector{Float64}(v)
    CRSI(N_args, tovec(lb), tovec(ub), pop, maxeval)
end

struct SimAnnI <: AbstractOptimizer
    lb                ::Vector{Float64}
    ub                ::Vector{Float64}
    x0                ::Vector{Float64}
    temp_schedule_par ::Float64
    maxiter           ::Int
end
function SimAnnI(; lb, ub, x0, temp_schedule_par=0.5, maxiter=25_000)
    tovec(v) = v isa Real ? [Float64(v)] : Vector{Float64}(v)
    SimAnnI(tovec(lb), tovec(ub), tovec(x0), temp_schedule_par, maxiter)
end

struct SimAnnNBI <: AbstractOptimizer
    x0        ::Vector{Float64}
    step_size ::Float64
    maxiter   ::Int
end
function SimAnnNBI(; x0, step_size=0.5, maxiter=25_000)
    tovec(v) = v isa Real ? [Float64(v)] : Vector{Float64}(v)
    SimAnnNBI(tovec(x0), Float64(step_size), maxiter)
end

# Struct to hold optimization results in a clean way
struct OptimResult
    minimizer ::Vector{Float64}
    f_min     ::Float64
    f_evals   ::Int
end

# ============================================================
# Integration types
# ============================================================

abstract type AbstractIntegrator  end
abstract type AbstractQuadrature  <: AbstractIntegrator end  # integrate(f, a, b, method)
abstract type AbstractExpectation <: AbstractIntegrator end  # expect(f, dist, method)

# Expectations
Base.@kwdef struct GaussHermiteI  <: AbstractExpectation; n::Int = 10  end
Base.@kwdef struct MonteCarloI    <: AbstractExpectation end

# Quadratures over [a, b]
Base.@kwdef struct TrapezoidalI   <: AbstractQuadrature;  n::Int = 100 end
Base.@kwdef struct GaussLegendreI <: AbstractQuadrature;  n::Int = 10  end

export AbstractDifferentiator, ForwardFDI, BackwardFDI, CentralFDI, AutoDiff
export AbstractOptimizer, NelderMeadI, GradientDescentI, CRSI, SimAnnI, SimAnnNBI, OptimResult
export AbstractIntegrator, AbstractQuadrature, AbstractExpectation, GaussHermiteI, MonteCarloI, TrapezoidalI, GaussLegendreI