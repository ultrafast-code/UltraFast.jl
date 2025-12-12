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