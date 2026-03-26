import Pkg

# Activate the project environment at pset3/ (one level up from this script)
Pkg.activate(joinpath(@__DIR__, ".."))

# ------------------------------------------------------------
# Setup dependencies
# ------------------------------------------------------------
# List of packages to be used in this project
packages = [
    "Interpolations",
    "Distributions",
    "Random",
    "Plots",
    "DataFrames",
    "PrettyTables",
    "IJulia",
    "Optim",
    "NLopt",
    "ForwardDiff",
    "FastGaussQuadrature"
]

# Add any packages not yet in the project (handles both first run and new additions)
installed = keys(Pkg.project().dependencies)
to_add = filter(p -> p ∉ installed, packages)
isempty(to_add) || Pkg.add(to_add)

Pkg.instantiate()   # download any packages not yet installed locally
Pkg.precompile()    # precompile all packages for faster loading in future sessions

# ------------------------------------------------------------
# Define main project directories
# ------------------------------------------------------------
# ROOT points to the root folder of the project repository.

const ROOT     = normpath(joinpath(@__DIR__, "../.."))

# Raw data folder
const DATA_RAW = joinpath(ROOT, "data", "raw")

# Output folders for figures and tables
const OUT_FIG  = joinpath(ROOT, "output", "figures")
const OUT_TAB  = joinpath(ROOT, "output", "tables")

# Ensure required folders exist
for p in (DATA_RAW, OUT_FIG, OUT_TAB)
    isdir(p) || mkpath(p)
end
