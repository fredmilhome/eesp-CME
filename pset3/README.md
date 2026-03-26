# Replication Package for: *Problem Set 3 - Computational Methods in Economics*

**Author:**
Fred Milhome, Sao Paulo School of Economics - FGV, fred.milhome@fgv.br

---

## 1. Overview

This package contains all code needed to reproduce the computational exercises for **Problem Set 3**, covering optimization, numerical integration, and numerical differentiation.

The environment is defined via Julia's `Project.toml`. Running `setup_env.jl` installs all dependencies and generates a local `Manifest.toml` lockfile (not tracked).

---

## 2. Repository Structure

```text
pset3/
├── code/
│   ├── setup_env.jl              # Environment bootstrap (instantiate + precompile)
│   ├── Pset3.jl                  # Main module — loads all SubModules
│   └── SubModules/
│       ├── Types.jl              # Abstract and concrete type definitions
│       ├── Utils.jl              # Utilities (e.g. trace_summary)
│       ├── myIntegration.jl      # Numerical integration (Trapezoidal, Gauss-Hermite, MC)
│       ├── myOptimization.jl     # Numerical optimization (Nelder-Mead, GD, CRS, SA)
│       └── myDifferentiation.jl  # Numerical differentiation (central finite differences)
├── misc/
│   ├── qje.csl                   # Citation style
│   └── references.bib            # Bibliography
├── output/
│   ├── figures/                  # Kept tracked; generated figures are gitignored
│   └── tables/                   # Kept tracked; generated tables are gitignored
├── Project.toml                  # Direct Julia dependencies
├── report.qmd                    # Quarto source — renders to PDF
├── .gitignore
└── README.md
```

Generated locally (gitignored): `figures/`, `Manifest.toml`, `FredMilhome_pset3_CME.pdf`.

---

## 3. Computational Environment

- **Julia:** 1.12.3
- **Platform:** Windows (also tested on macOS)
- **Quarto:** any recent version supporting `jupyter: julia-1.12`

---

## 4. Dependency Management

`Project.toml` records direct dependencies. `Manifest.toml` is generated locally by `setup_env.jl` and is not tracked — on a fresh clone, Julia resolves the latest compatible versions of all transitive dependencies and writes the lockfile locally.

Direct dependencies: `DataFrames`, `Distributions`, `FastGaussQuadrature`, `ForwardDiff`, `IJulia`, `Interpolations`, `NLopt`, `Optim`, `Plots`, `PrettyTables`, `Random`.

---

## 5. Reproducing Results

From inside the `pset3/` directory, run **two commands in order**:

```bash

# 0. You may need to install quarto, jupyter and/or TinyTex. Download quarto at quarto.org. 

# To install jupyter, use
python -m pip install jupyter

# To install tinytex, use
quarto install tinytex

# 1. Bootstrap: install pinned packages, the Julia kernel and precompile
julia code/setup_env.jl

# 2. Render the full PDF report from a terminal
quarto render report.qmd
```

The output PDF (`FredMilhome_pset3_CME.pdf`) will appear in `pset3/`.

**Notes:**
- Step 1 creates the `data/raw/`, `output/figures/`, and `output/tables/` directories automatically if they do not exist.
- Step 1 is optional if you only want to render — `report.qmd` includes `setup_env.jl` in its first cell — but running it separately precompiles all packages and makes the render faster.
- The random seed is fixed (`Random.seed!(201010)`) so stochastic results (SA optimization, Monte Carlo) are exactly reproducible.

---

## 6. AI Usage Disclaimer

Environment setup and reproducibility tooling were delegated to Claude Code and reviewed by me. The core analysis was built by me, with AI assistance for bug fixing, specific implementation issues, and producing tables and plots.
