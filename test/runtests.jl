using Test
using DelimitedFiles
using Documenter

if isdefined(@__MODULE__, :LanguageServer)
  @info "Using VS Code workaround..."
  include("../src/UltraFast.jl")
  using .UltraFast
else
  @info "Not using VS Code workaround"
  using UltraFast
end

@testset "UltraFast.jl" begin
    lattice = LatticeConfig(Lx=4, Ly=1) 
end

@testset "Serialization" begin
    include("serialization/test_serialization.jl")
end

@testset "Hamiltonians" begin
    include("Hamiltonians/test_hamiltonians.jl")
end

@testset "Lattice construction" begin
    lattice = LatticeConfig(Lx=4, Ly=4)

    @test lattice.nspins == 16
    @test length(lattice.bonds_x) == 16
    @test length(lattice.bonds_y) == 16

end

@testset "Doctest" begin
    DocMeta.setdocmeta!(UltraFast,:DocTestSetup,:(using UltraFast);recursive=true)
    doctest(UltraFast; manual = false)
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
    parallel_sampler = UltraFast.ParallelMCMCSampler(mcset, sampler, 10)

    # Test the number of spins
    @test UltraFast.Models.nspins(model) == Lx*Ly

    # Hamiltonian
    hamiltonian = UltraFast.Hamiltonians.Heisenberg(lattice=lattice, parallel=false, marshall_sign_rule=true)

    # Create gs object
    gs = UltraFast.Optimisation.GroundStateOptimisation(sampler=parallel_sampler, callback=UltraFast.EnergyLogger(lattice, hamiltonian, 300))

    # do gs optimization
    opt, model = UltraFast.Optimisation.optimize!(gs, model, hamiltonian)

    #display(opt.metadata)

    # make a metrics function, variational energy, v-score, and if available relative error based on QMC.
    metrics = UltraFast.evaluate(Dict("n_chains" => 10, "nsamples" => 2000, "sweep" => lattice.nspins, "nthermalization" => 200), model = model, hamiltonian = hamiltonian)
    
    display(UltraFast.Models.save_model(model))

    #display(metrics)
end

@testset "model" begin
    Lx = 6
    Ly = 6
    lattice = UltraFast.LatticeConfig(Lx=Lx, Ly=Ly)

    #UltraFast.LatticeConfig(Lx=Lx, Ly=Ly)

    # Load the models
    #model = UltraFast.SymmetryRBM.RBMModelLogIndep(lattice, 2, init=UltraFast.Models.real_default_uniform())
    model = UltraFast.SymmetryRBM.FastTranslationInvariantRBM(lattice, 2, init=UltraFast.Models.real_default_uniform())

    WRBM = readdlm("pretrained/36_2_weights.txt", Float64)[:]

    UltraFast.Models.set_weights!(model, WRBM)

    sr_obs = UltraFast.Observables.SRObservables()

    obs = (SR=sr_obs,)

    nspins = Lx*Ly
    nsamples = 100
    states = hcat(map(x -> random_spin_state(x, true), nspins*ones(Int64, nsamples))...)
    display(states)

    logwav = UltraFast.Models.wavefunction_values(model, states)

    hamiltonian = UltraFast.Hamiltonians.Heisenberg(lattice=lattice, parallel=false, marshall_sign_rule=true)

    #display(logwav)

    observables = UltraFast.Observables.observe(obs; states=states, logwavefunctions=logwav, model=model, hamiltonian=hamiltonian)

    #display(observables.SR.Eloc / (Lx*Ly*4))
    
end
