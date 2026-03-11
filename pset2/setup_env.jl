import Pkg

# Activate the project environment located in the same directory as this script
Pkg.activate(@__DIR__)

# ------------------------------------------------------------
# Setup dependencies
# ------------------------------------------------------------
# List of packages to be used in this project
packages = [
    "Interpolations",
    "Distributions",
    "Random",
    "Plots",
    "CSV",
    "DataFrames",
    "BenchmarkTools",
    "PrettyTables",
    "IJulia"
]

Pkg.add(packages)   # add missing packages and resolve Manifest.toml
Pkg.instantiate()   # download any packages not yet installed locally
Pkg.precompile()    # precompile all packages for faster loading in future sessions

# ------------------------------------------------------------
# Define main project directories
# ------------------------------------------------------------
# ROOT points to the root folder of the project repository.

const ROOT     = normpath(joinpath(@__DIR__, ".."))

# Raw data folder
const DATA_RAW = joinpath(ROOT, "data", "raw")

# Output folders for figures and tables
const OUT_FIG  = joinpath(ROOT, "output", "figures")
const OUT_TAB  = joinpath(ROOT, "output", "tables")

# Ensure required folders exist
for p in (DATA_RAW, OUT_FIG, OUT_TAB)
    isdir(p) || mkpath(p)
end

