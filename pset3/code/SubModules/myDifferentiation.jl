function numdifferentiation(f, x::AbstractVector{<:Real}, m::CentralFDI)
    # Warn if diffs is not even from 2 to 6
    if m.coefs ∉ (2, 4, 6) 
        @warn "Coefficient choice $(m.coefs) is not supported. Defaulting to 2."
        m = CentralFDI(h=m.h, coefs=2)
    end

    if m.coefs == 2
        # Standard central difference: f'(x) ≈ (f(x+h) - f(x-h)) / (2h)
        grad = (f(x .+ m.h) - f(x .- m.h)) ./ (2m.h)
    elseif m.coefs == 4
        # 4th-order
        grad = (f(x .- 2m.h) - 8f(x .- m.h) + 8f(x .+ m.h) - f(x .+ 2m.h)) ./ (12m.h)
    elseif m.coefs == 6
        # 6th-order
        grad = (-f(x .- 3m.h) + 9f(x .- 2m.h) - 45f(x .- m.h) + 45f(x .+ m.h) - 9f(x .+ 2m.h) + f(x .+ 3m.h)) ./ (60m.h)
    end
    
    return grad
end

export numdifferentiation