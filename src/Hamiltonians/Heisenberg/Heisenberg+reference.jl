# This file contains the reference/benchmark energies for the 2D Heisenberg model on a square and chain lattice.

# Ground state energies per spin obtained with iTensor DMRG for 1D chains with periodic boundary conditions and antiferromagnetic Heisenberg model.
const dmrg_gs_1d_chain = Dict(
    4 => -0.49999999999999994,
    6 => -0.46712927295533185,
    8 => -0.4563866761171469,
    10 => -0.4515446354492038,
    12 => -0.44894924312043477,
    14 => -0.447396395253359,
    16 => -0.4463935225385468,
    24 => -0.44458393818904723,
    32 => -0.4439539824652493,
    40 => -0.4436630696679645,
    64 => -0.4433484568665842,
    100 => -0.4432295
)

# Ground state energies per spin obtained with QMC for 2D square lattices with periodic boundary conditions and antiferromagnetic Heisenberg model.
const e_qmc = Dict(
    16 => -0.701777, 
    36 => -0.678873, 
    64 => -0.673487, 
    100 => -0.671549, 
    144 => -0.670685, 
    196 => -0.670222, 
    256 => -0.669976
)

"""
    reference_energy(H::Hamiltonian)

    Returns a dictionary containing literature reference ground state energy for the given Hamiltonian `H`.
"""
function reference_energy(H::Heisenberg)
    reference = Dict{String, Float64}()

    if is_chain(H.lattice)
        if haskey(dmrg_gs_1d_chain, H.lattice.nspins)
            reference["DMRG"] = dmrg_gs_1d_chain[H.lattice.nspins]
            return reference
        else
            @warn "No reference energy available for 1D chain with $(H.lattice.nspins) spins."
            return nothing
        end
    elseif is_square(H.lattice)
        if haskey(e_qmc, H.lattice.nspins)
            reference["QMC"] = e_qmc[H.lattice.nspins]
            return reference
        else
            @warn "No reference energy available for 2D square lattice with $(H.lattice.nspins) spins."
            return nothing
        end
    else
        @warn "No reference energy available for non-square 2D lattices."
        return nothing
    end

    return nothing
end