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