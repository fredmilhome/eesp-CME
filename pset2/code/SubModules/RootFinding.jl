module RootFinding

function bisection(f, a, b; tol=1e-8, max_iter=50)
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
            return c
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
    return c # Return the approximate root
end


end