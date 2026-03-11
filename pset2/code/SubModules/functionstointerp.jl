module functionstointerp

using ..Types

myf(dist::ParetoDist, x::Float64) = (dist.α * dist.x_m^dist.α) / x^(dist.α + 1)
myf(dist::LogLogisticDist, x::Float64) = 1/(1 + exp(-dist.η * log(x/dist.ξ)))

export myf

end