using DataFrames, Statistics

# Function to summarize the trace of the optimization, adapted from Finamor's code
function trace_summary(trace0; block=100)
    trace = copy(trace0)
    p = length(trace.theta[1])

    # bin evals
    trace.bin = ((trace.eval .- 1) .÷ block) .+ 1

    # unpack theta into θ1, θ2, ..., θp
    for i in 1:p
        trace[!, Symbol("θ$i")] = getindex.(trace.theta, i)
    end

    θcols   = Symbol.("θ" .* string.(1:p))
    grouped = groupby(trace, :bin)

    summary = combine(grouped,
        θcols .=> mean,
        :value => mean => :avg_value
    )

    return summary
end

export trace_summary