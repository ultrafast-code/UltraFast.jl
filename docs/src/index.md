```@meta
CurrentModule = UltraFast
```

# UltraFast

Documentation for [UltraFast](https://ultrafast-code.pages.science.ru.nl/ultrafast.jl).

UltraFast is an open-source code for the simulation of ground state properties
of quantum spin systems with Neural Quantum States (NQS) [[Carleo and
Troyer](https://doi.org/10.1126/science.aag2302)].

## Installation
To install UltraFast, you can use Julia's package manager. Open the Julia REPL
and enter the following commands:
```julia
using Pkg
Pkg.add("https://github.com/ultrafast-code/UltraFast.jl")
```

## Outline

```@contents
Pages = [
    "chapters/lattice.md",
    "chapters/extra.md",
    "chapters/models.md",
    "docs.md"
]
Depth = 1
```

## Example

### Ground State Optimization
Example for ground state optimization of the Heisenberg model on a 4x4 lattice.

```julia
using UltraFast
using DelimitedFiles
using Statistics
using BenchmarkTools
using ProgressMeter

## The physics
#Define the lattice
lattice = UltraFast.Lattice.LatticeConfig(Lx = 4, Ly = 4)

# Define the hamiltonian
hamiltonian = UltraFast.Hamiltonians.Heisenberg(lattice=lattice, 
                                                  parallel=false,
                                                  marshall_sign_rule=true)

## The model
model = UltraFast.SymmetryRBM.FastTranslationInvariantRBM(lattice, 2, init = UltraFast.Models.default_uniform())

## The sampling
# Setting up the sampling                                                  
samplingSettings = UltraFast.Samplers.MCMCSettings(sweep=lattice.nspins,
                                                 nsamples=2000,
                                                 nthermalization=200)

# Create Metropolis-Hastings sampler with the above settings                                                 
sampler = UltraFast.Samplers.MHSampler(samplingSettings)

# Run the optimization for 300 iterations
niterations = 300

# Use a progress bar to monitor the optimization
p = Progress(niterations; dt=0.5, barglyphs=BarGlyphs("[=> ]"), color=:yellow)

function callback(g::UltraFast.Optimisation.GroundStateOptimisation, data, iteration::Int; total_iterations)
    current_energy = data.energies[iteration]
    current_variance = data.stddevs[iteration]^2
    
    update!(p, iteration; showvalues=[("Energy", current_energy), ("Stddev", current_variance)])
end

## The Ground state optimization
gs = UltraFast.Optimisation.GroundStateOptimisation(sampler=sampler,
                                                    callback = callback,
                                                    niterations = niterations)

output, model = UltraFast.Optimisation.optimize!(gs, model, hamiltonian)

println("Final energy: ", output.energies[end])
```

### Parallel Ground State Optimization

Example for parallel ground state optimization of the Heisenberg model on a 4x4 lattice.

```julia
using Distributed
addprocs(2)
using UltraFast
using Test

Lx = 4
Ly = 4
lattice = UltraFast.LatticeConfig(Lx=Lx, Ly=Ly)

# Load the models TranslationInvariantRBM or FastTranslationInvariantRBM which uses a lookup table for b_i + sum_j W_ij s_j
model = UltraFast.SymmetryRBM.TranslationInvariantRBM(lattice, 2, init=UltraFast.Models.real_default_uniform())
#model = UltraFast.SymmetryRBM.FastTranslationInvariantRBM(lattice, 2, init=UltraFast.Models.real_default_uniform())

# Load the Models
mcset = UltraFast.MCMCSettings(nthermalization=200, nsamples=2000, sweep=lattice.nspins)

# Make a Metropolis-Hastings sampler
sampler = UltraFast.Samplers.MHSampler(mcset)

# Make a parallel sampler with 5 chains which each use the above sampler
sampler = UltraFast.ParallelMCMCSampler(mcset, sampler, 5)

# Test the number of spins
@test UltraFast.Models.nspins(model) == Lx*Ly

# Create Hamiltonian
hamiltonian = UltraFast.Hamiltonians.Heisenberg(lattice=lattice, parallel=false, marshall_sign_rule=true)

# Create Ground state optimization
gs = UltraFast.Optimisation.GroundStateOptimisation(sampler=sampler, callback=UltraFast.EnergyLogger(lattice, hamiltonian, 300))

# Do Ground state optimization
output, model = UltraFast.Optimisation.optimize!(gs, model, hamiltonian)

println("Final energy: ", output.energies[end])
```