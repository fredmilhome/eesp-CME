# Replication Package for: *Problem Set 2 - Computational Methods in Economics*

**Authors:**  
Fred Milhome, Sao Paulo School of Economics - FGV, fred.milhome@fgv.br

---

## 1. Overview

This repository contains the code and instructions necessary to reproduce the computational exercises for **Problem Set 2**, focused on interpolation and root-finding methods.

The package is structured so that anyone can clone the repository, instantiate the Julia environment, and run the scripts with consistent package versions.

---

## 2. Repository Structure

```text
.
├── code/
│   ├── activate_env.jl              # Activates the pset2 environment from scripts
│   ├── interp_assignment.jl         # Main interpolation script
│   ├── backlog                      # Notes / backlog file
│   └── SubModules/
│       ├── CMEModules.jl
│       ├── functionstointerp.jl
│       ├── RootFinding.jl
│       └── Types.jl
├── data/
│   └── raw/
│       ├── life_expectancy.csv      # Input dataset
│       └── .gitignore               # Keeps folder tracked
├── output/
│   ├── figures/
│   │   └── .gitignore               # Keeps folder tracked; generated plots ignored
│   └── tables/
│       └── .gitignore               # Keeps folder tracked; generated tables ignored
├── Manifest.toml                    # Fully pinned dependency lockfile
├── Project.toml                     # Direct Julia dependencies
├── setup_env.jl                     # Environment bootstrap (instantiate + precompile)
├── report.qmd                       # Quarto source report
├── FredMilhome_pset2_CME.pdf        # Generated report artifact (local)
├── pset2.pdf                        # Assignment statement
├── .gitignore
└── README.md
```

## 3. Computational Environment

This project was initialized with **Julia 1.12.3** on **Windows**.

Dependency management follows Julia project environments, which are the Julia equivalent of Python virtual environments or R project-local libraries.

## 4. Dependency Management and Reproducibility

This folder is a standalone Julia environment.

- `Project.toml` records direct package dependencies.
- `Manifest.toml` pins all transitive dependencies and exact versions.

To reproduce the environment from scratch, open the `pset2` folder and run:

```text
julia --project=. setup_env.jl
```

## 5. Reproducing Results

### Interpolation assignment

From inside `pset2`, run the following to make use of multiple cores for efficient benchmarking:

```text
julia --threads auto code/interp_assignment.jl
```

If inside `eesp-CME`,
```text
julia --threads auto pset2/code/interp_assignment.jl
```

The script writes outputs into the `output/` folder.

### Root finding assignment

Since this one was simpler, it was done directly in the .qmd file which produces the submitted file, which requires quarto to be reproduced.

## 6. AI usage and acknowledge disclaimer 

The environment setup and reproducibility tasks were delegated to GPT-5.3-Codex and reviewed by me. The core analysis required in the assignment was built by me, with AI assistance for bug fixing, solving specific issues, and plotting/tabulating results. The root finding functions were build directly on top of the ones built in Lucas Finamor's lecture files.