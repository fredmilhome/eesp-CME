# Optimization

using NLopt, Optim

# Scalar functions are called with a Vector by Optim/NLopt; unpack for 1D.
scalar_wrap(f, n) = n == 1 ? (x -> f(only(x))) : f

# Nelder Mead
function numoptimize(f, m::NelderMeadI)
    g = scalar_wrap(f, length(m.x0))
    res = Optim.optimize(g, m.x0, NelderMead())
    return OptimResult(res.minimizer, res.minimum, res.f_calls)
end

# Gradient Descent
function numoptimize(f, m::GradientDescentI)
    g = scalar_wrap(f, length(m.x0))
    res = Optim.optimize(g, m.x0, GradientDescent())
    return OptimResult(res.minimizer, res.minimum, res.f_calls)
end

# Controlled Random Search
function numoptimize(f, m::CRSI)
    g = scalar_wrap(f, m.N_args)
    function obj(x::Vector, grad::Vector)
        return g(Vector{Float64}(x))
    end

    opt = Opt(:GN_CRS2_LM, m.N_args)
    NLopt.lower_bounds!(opt, m.lb)
    NLopt.upper_bounds!(opt, m.ub)
    NLopt.maxeval!(opt, m.maxeval)
    NLopt.population!(opt, m.pop)
    NLopt.min_objective!(opt, obj)

    x0 = (m.lb .+ m.ub) ./ 2
    min_f, min_x, _ = NLopt.optimize(opt, x0)
    return OptimResult(min_x, min_f, NLopt.numevals(opt))
end

# Simulated Annealing (with bounds, SAMIN)
function numoptimize(f, m::SimAnnI)
    g = scalar_wrap(f, length(m.x0))
    res = Optim.optimize(g, m.lb, m.ub, m.x0, SAMIN(rt = m.temp_schedule_par), Optim.Options(iterations = m.maxiter))
    return OptimResult(res.minimizer, res.minimum, res.f_calls)
end

# Simulated Annealing (no bounds, Gaussian neighbor)
function numoptimize(f, m::SimAnnNBI)
    g = scalar_wrap(f, length(m.x0))
    neighbor!(xc, xp) = (xp .= xc .+ m.step_size .* randn(length(xc)))
    res = Optim.optimize(g, m.x0, Optim.SimulatedAnnealing(neighbor = neighbor!), Optim.Options(iterations = m.maxiter))
    return OptimResult(res.minimizer, res.minimum, res.f_calls)
end

export numoptimize