module UltraFast

version = "3.0.0"

using LinearAlgebra, Statistics, Optimisers

# Helpers
include("helpers/helpers.jl")
using .Helpers
export random_spin_state

# Lattice definition and construction
include("Lattice/lattice.jl")
using .Lattice
export LatticeConfig, LatticeSettings, is_chain, is_square

# Flux Helpers
include("FluxComplexIntializers/FluxComplexInitializers.jl")
using .FluxComplexInitializers

# Models
include("Models/model.jl")
using .Models
export Model, FluxModel, ComplexFluxModel

include("SymmetryRBM/SymmetryRBM.jl")
using .SymmetryRBM

# Hamiltonians
include("Hamiltonians/Hamiltonians.jl")
using .Hamiltonians
export Hamiltonian, reference_energy

# Observables
include("Observables/Observables.jl")
using .Observables: Observable

# Samplers
include("Samplers/Samplers.jl")
using .Samplers
export MCMCSettings, MHSampler, sample

# Multiprocessing Samplers
include("Multiprocessing/Multiprocessing.jl")
using .MultiProcessing
export ParallelMCMCSampler

# Optimisation
include("Optimisation/Optimisation.jl")
using .Optimisation

# Metrics
include("Metrics/metrics.jl")

# Evaluation
include("Evaluation/Evaluation.jl")

# Serialization
include("Serialization/io.jl")

end # module UltraFast

