module RootFinding

function bisection(f::Function, a::Real, b::Real; tol::Real=1e-8, max_iter::Int=50)
    a = float(a)
    b = float(b)
    tol = float(tol)

    # Check if the initial interval is valid
    if f(a) * f(b) > 0
        error("Function values at the interval endpoints must have opposite signs.")
    end

    # Initialize variables
    iter = 0
    c = (a + b) / 2.0 # Initialize the midpoint

    while abs(b - a) > tol && iter < max_iter
        c = (a + b) / 2.0 # Update the midpoint

        if abs(f(c)) < tol
            # Found the root
            return c, iter
        elseif f(a) * f(c) < 0
            b = c # Root is in the left subinterval
        else
            a = c # Root is in the right subinterval
        end

        iter += 1
    end

    # Check if the solution converged
    if iter == max_iter
        error("Bisection method did not converge within the maximum number of iterations.")
    end
    return c, iter # Return the approximate root and the number of iterations
end

function secant(f::Function, a::Real, b::Real; tol::Real=1e-8, max_iter::Int=2000)
    a = float(a)
    b = float(b)
    tol = float(tol)

    iter = 0
    
    c = 0.0
    
    while abs(b-a) > tol && iter < max_iter
        # Calculate the next approximation
        fa = f(a)
        fb = f(b)
        
        if abs(fb - fa) < 1e-14 # Avoid division by very small values
            error("Denominator too small; method may not converge.")
        end
        
        c = b - fb * (b - a) / (fb - fa) # Secant method formula
        
        # Update points for the next iteration
        a = b
        b = c
        iter += 1
    end
    
    # Check if the solution converged
    if iter == max_iter
        error("Secant method did not converge within the maximum number of iterations.")
    end
    
    return c, iter # Return the approximate root and the number of iterations
    
end

function newton_raphson(f::Function, df::Function, x0::Real; tol::Real=1e-8, max_iter::Int=100)
    x0 = float(x0)
    tol = float(tol)

    x = x0  # Initial guess
    iter = 0
    x_old = x0 + 10 * tol  # Ensure the first iteration is executed

    while abs(x - x_old) > tol && iter < max_iter
        fx = f(x)
        dfx = df(x)

        if abs(dfx) < 1e-14  # Avoid division by very small values
            error("Derivative is too close to zero; method may not converge.")
        end
        # Update using Newton-Raphson formula
        x_old = x
        x = x - fx / dfx
        iter += 1
    end

    # Check if the solution converged
    if iter == max_iter
        error("Newton-Raphson method did not converge within the maximum number of iterations.")
    end

    return x, iter # Return the approximate root and the number of iterations

end

end