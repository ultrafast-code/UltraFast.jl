using UltraFast
using DelimitedFiles

@testset "run model" begin
    # setup
    mag0 = true
    Lx = 4
    Ly = 4
    lattice, samplingConfig = latticesetup(Lx, Ly)

    # model
    alpha = 1
    model = UltraFast.FastTranslationInvariantRBM(lattice, alpha)

    # Generate a spin state
    state = UltraFast.GenRandomState2(mag0, lattice.nspins)

    println(UltraFast.wavefunction_value(model, state))
    println(UltraFast.wavefunction_value(model, state))

    UltraFast.new_state!(model, state)

    println(UltraFast.wavefunction_value(model, state))
    println(UltraFast.wavefunction_value(model, state, [1,2]))

end

@testset "comparison" begin
    # setup
    mag0 = true
    Lx = 4
    Ly = 4
    lattice, samplingConfig = latticesetup(Lx, Ly)

    # model
    alpha = 1
    model = UltraFast.FastTranslationInvariantRBM(lattice, alpha)

    # flux independent RBM
    model_flux = UltraFast.RBMModelLogIndep(lattice, alpha)

    W_RBM = UltraFast.independent_weights(model_flux)

    # load weights from Flux into RBM
    UltraFast.loadweights!(model, W_RBM)

    # Get weights from Flux
    W_flux, b_flux = UltraFast.weights(model_flux)
    @test W_flux ≈ model.RBMPar.W
    @test W_RBM ≈ model.W_RBM

    # generate state
    state = UltraFast.GenRandomState2(mag0, lattice.nspins)

    # for FastTranslationInvariantRBM
    UltraFast.new_state!(model, state)

    # testing
    @test UltraFast.gradient(model, state) ≈ UltraFast.gradient(model_flux, state)

    @test UltraFast.wavefunction_value(model, state) ≈ UltraFast.wavefunction_value(model_flux, state)

    # conclusion from above is that gradient and wavefunction values should be fully correct
    @test UltraFast.independent_weights(model_flux) ≈ UltraFast.independent_weights(model)

    # now check the state updates
    flips = [1,2]
    #UltraFast.handle_state_update!(model, state, flips)
    new_state2 = copy(state)
    new_state2[flips] = -new_state2[flips]

    @test all(model.RBMPar.a .≈ 0.0 + 0.0im)

    # so biases are zero
    #println(UltraFast.wavefunction_value(model, state)," ", UltraFast.wavefunction_value(model_flux, state))
    @test UltraFast.wavefunction_value(model, state) ≈ UltraFast.wavefunction_value(model_flux, state)
    @test UltraFast.wavefunction_value(model_flux, new_state2) ≈ UltraFast.wavefunction_value(model, state, flips)

    #println(UltraFast.wavefunction_value(model_flux, new_state2), UltraFast.wavefunction_value(model, state, flips))

    # now check the state updates
    flips = [1,2]
    UltraFast.handle_state_update!(model, state, flips)

    new_state = copy(state)
    new_state[flips] = -new_state[flips]

    @test UltraFast.wavefunction_value(model, new_state) ≈ UltraFast.wavefunction_value(model_flux, new_state)
    @test UltraFast.gradient(model, new_state) ≈ UltraFast.gradient(model_flux, new_state)

end

# @testset "sampling" begin
#     # setup
#     mag0 = true
#     Lx = 4
#     Ly = 4
#     lattice, samplingConfig = latticesetup(Lx, Ly)
#     heisSettings = UltraFast.heisenbergDefaultSettings()

#     # model
#     alpha = 1
#     model = UltraFast.FastTranslationInvariantRBM(lattice, alpha)
    
#     # # flux
#     # model_flux = UltraFast.SetupLogRBM(lattice, alpha)

#     # setup observable
#     EnergyObs = UltraFast.EnergyObservable(samplingConfig.samples, samplingConfig.iterations)

#     # run the optimization
#     @time model, energies, stddevs, observables = UltraFast.samplingHeisenberg2DModel(lattice, heisSettings, samplingConfig, model, UltraFast.SmatrixGradient(), optimiser = UltraFast.Optimisers.Descent(0.005), observables=(energy=EnergyObs,))

#     indepweights = UltraFast.independent_weights(model)

#     #display(indepweights)

#     #display(real(indepweights))
#     #display(im(indepweights))

#     open("test/pretrained/model_re_$(Lx)_$(Ly)_$(alpha).jl", "w") do io
#         writedlm(io, real(indepweights))
#     end

#     open("test/pretrained/model_im_$(Lx)_$(Ly)_$(alpha).jl", "w") do io
#         writedlm(io, imag(indepweights))
#     end
# end


# @testset "sampling_log" begin
#     # setup
#     mag0 = true
#     Lx = 4
#     Ly = 4
#     lattice, samplingConfig = latticesetup(Lx, Ly)
#     heisSettings = UltraFast.heisenbergDefaultSettings()

#     # model
#     alpha = 1
#     model = UltraFast.RBMModelLogIndep(lattice, alpha, initializer=UltraFast.real_default_uniform)
    
#     # # flux
#     # model_flux = UltraFast.SetupLogRBM(lattice, alpha)

#     # setup observable
#     EnergyObs = UltraFast.EnergyObservable(samplingConfig.samples, samplingConfig.iterations)

#     # run the optimization
#     @time model, energies, stddevs, observables = UltraFast.samplingHeisenberg2DModel(lattice, heisSettings, samplingConfig, model, UltraFast.SmatrixGradient(), optimiser = UltraFast.Optimisers.Descent(0.005), observables=(energy=EnergyObs,))

# end

