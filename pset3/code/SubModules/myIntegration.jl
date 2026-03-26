# Integration algorithms from Driscoll & Braun (2022).

using LinearAlgebra, FastGaussQuadrature

"""
    trapezoid_rule(f, a, b, n)

Perform trapezoidal integration for the function `f` over `[a, b]` using `n` subintervals.
Returns the integral estimate.
"""
function trapezoid_rule(f, a, b, m::TrapezoidalI)
    h = (b - a)/m.n
    t = range(a, stop=b, length=m.n+1)
    y = f.(t)
    T = h * (sum(y[2:m.n]) + 0.5*(y[1] + y[m.n+1]))
    return T
end

"""
    glint(f, a, b, n)

Perform Gauss-Legendre integration for the function `f` on `n` nodes
in (a, b). Returns the integral estimate and a vector of the nodes used.
"""
function glint(f, a, b, m::GaussLegendreI)
    β = @. 0.5/sqrt(1-(2*(1:m.n-1))^(-2))
    T = diagm(-1=>β, 1=>β)          # ← always -1 and 1 (diagonal offsets)
    λ, V = eigen(T)
    p = sortperm(λ)
    x̃ = λ[p]                        # nodes on (-1, 1)
    c = @. 2V[1,p]^2                # weights for (-1, 1)

    # Change of variables: shift nodes from (-1,1) to (a,b)
    x = @. (b-a)/2 * x̃ + (a+b)/2
    I = (b-a)/2 * dot(c, f.(x))    # scale weights by (b-a)/2
    return I, x
end

numintegrate(f, a, b, m::TrapezoidalI) = trapezoid_rule(f, a, b, m)
numintegrate(f, a, b, m::GaussLegendreI) = glint(f, a, b, m)

function gauss_hermite_exp(f, m::GaussHermiteI)
    x, w = gausshermite(m.n)
    # E[f(X)] for X ~ N(0,1): change of vars t = x/√2 gives (1/√π)∑ wᵢ f(√2·xᵢ)
    result = sum(w[i] * f(x[i] * √2) for i in 1:m.n) / √π
    return result
end

function monte_carlo_exp(f, samples, m::MonteCarloI)
    result = mean(f(row...) for row in eachrow(samples))
    return result
end

numexpectation(f, m::GaussHermiteI) = gauss_hermite_exp(f, m)
numexpectation(f, samples, m::MonteCarloI) = monte_carlo_exp(f, samples, m)

export numintegrate, numexpectation