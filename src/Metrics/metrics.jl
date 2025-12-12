using ProgressMeter

"""
    Calculates the v-score for a given system.
"""
function vscore(nspins, mean_energy, energy_variance)
    nspins * (energy_variance / (mean_energy^2))
end

"""
    Calculates the relative error between an estimated energy and a reference energy.
"""
function relative_error(estimated::T, reference::T) where T<:AbstractFloat
    abs(estimated - reference) / abs(reference)
end

"""
    Calculates the relative error between an estimated energy and the lowest reference energy of a Hamiltonian.

    Returns a tuple containing the relative error and a dictionary with information about the reference energy (method and energy).
"""
function relative_error(estimated::T, hamiltonian::Hamiltonian) where T<:AbstractFloat
    # get the reference from the Hamiltonian
    reference = reference_energy(hamiltonian)

    energies = collect(values(reference))
    methods = collect(keys(reference))

    lowest_reference = minimum(energies)
    method = methods[argmin(energies)]

    return relative_error(estimated, lowest_reference), Dict("method" => method, "energy" => lowest_reference)
end

function EnergyLogger(lattice::LatticeConfig, hamiltonian::Hamiltonians.Heisenberg, iterations::Int)
    p = Progress(iterations; dt=1.0)   # minimum update interval: 1 second

    function callback_func(g::Optimisation.GroundStateOptimisation, data, iteration::Int; kwargs...)
        current_energy = data.energies[iteration]
        current_variance = data.stddevs[iteration]^2

        v_score = vscore(lattice.nspins, current_energy, current_variance)

        showvalues = [("E", current_energy),("Variance", current_variance), ("V-score", v_score)]

        if reference_energy(hamiltonian) !== nothing

            relative_error_, metrics = relative_error(current_energy, hamiltonian)
            
            push!(showvalues, ("Rel err $(metrics["method"])",relative_error_))
        end

        next!(p, showvalues=showvalues)
    end

    return callback_func

end