import Pkg

# Activate the project environment located in the pset2 root (one level up)
Pkg.activate(joinpath(@__DIR__, ".."))
Pkg.instantiate()  # download & install all resolved packages
Pkg.precompile()   # precompile all packages for faster loading in future sessions

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
