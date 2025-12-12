module Hamiltonians

abstract type Hamiltonian end

import ..Lattice: LatticeConfig, LatticeSettings, is_chain, is_square   
using ..Models

# method to calculate the Eloc energy
Eloc(H::Hamiltonian, m::Model, state, currentstatelog) = error("Not implemented for $(typeof(H))")

# generate random state
random_state(H::Hamiltonian) = error("Not implemented for $(typeof(H))")
random_state(H::Hamiltonian, nsamples::Int) = begin
    states = Array{Int64, 2}(undef, H.lattice.nspins, nsamples)
    
    for i = 1:nsamples
        states[:, i] = random_state(H)
    end

    return states
end

nspins(H::Hamiltonian) = H.lattice.nspins

reference_energy(H::Hamiltonian) = error("Not implemented for $(typeof(H))")

settings(H::Hamiltonian) = error("Not implemented for $(typeof(H))")

# export Hamiltonian
export Hamiltonian, Eloc, nspins, reference_energy

# include the Heisenberg Hamiltonian
include("Heisenberg/Heisenberg.jl")
export Heisenberg

end # module Hamiltonians
