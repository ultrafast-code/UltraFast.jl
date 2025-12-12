using Distributed
addprocs(2)
using Dagger
using UltraFast
using ProgressMeter
using Test

function EnergyLogger(lattice::UltraFast.LatticeConfig, hamiltonian::UltraFast.Hamiltonians.Heisenberg, iterations::Int)
    p = Progress(iterations; dt=1.0)   # minimum update interval: 1 second

    function callback_func(g::UltraFast.Optimisation.GroundStateOptimisation, data, iteration::Int)
        current_energy = data.energies[iteration]
        current_variance = data.stddevs[iteration]^2

        v_score = UltraFast.vscore(lattice.nspins, current_energy, current_variance)

        showvalues = [("E", current_energy),("Variance", current_variance), ("V-score", v_score)]

        if UltraFast.reference_energy(hamiltonian) !== nothing

            relative_error, metrics = UltraFast.relative_error(current_energy, hamiltonian)
            
            push!(showvalues, ("Rel err $(metrics["method"])",relative_error))
        end

        next!(p, showvalues=showvalues)
    end

    return callback_func

end

@testset "Ground state" begin
    Lx = 4
    Ly = 4
    lattice = UltraFast.LatticeConfig(Lx=Lx, Ly=Ly)

    # Load the models
    #model = UltraFast.SymmetryRBM.RBMModelLogIndep(lattice, 2, init=UltraFast.Models.real_default_uniform())
    model = UltraFast.SymmetryRBM.FastTranslationInvariantRBM(lattice, 2, init=UltraFast.Models.real_default_uniform())

    # Load the Models
    mcset = UltraFast.MCMCSettings(nthermalization=200, nsamples=2000, sweep=lattice.nspins)
    sampler = UltraFast.Samplers.MHSampler(mcset)

    sampler = UltraFast.ParallelMCMCSampler(mcset, sampler, 4)

    # Test the number of spins
    @test UltraFast.Models.nspins(model) == Lx*Ly

    # Hamiltonian
    hamiltonian = UltraFast.Hamiltonians.Heisenberg(lattice=lattice, parallel=false, marshall_sign_rule=true)

    # Create gs object
    gs = UltraFast.Optimisation.GroundStateOptimisation(sampler=sampler, callback=EnergyLogger(lattice, hamiltonian, 300))

    Dagger.enable_logging!()

    # do gs optimization
    UltraFast.Optimisation.optimize!(gs, model, hamiltonian)

    logs = Dagger.fetch_logs!()

    Dagger.disable_logging!()

    # make a metrics function, variational energy, v-score, and if available relative error based on QMC.
    
end