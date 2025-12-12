using DelimitedFiles

@testset "sampling energy" begin
    # setup
    mag0 = true
    Lx = 4
    Ly = 4
    nspins = Lx * Ly

    lattice = UltraFast.LatticeConfig(Lx, Ly)
    samplingConfig = UltraFast.SetupMonteCarloSampling(lattice; iterations = 1, samples=10000)

    #lattice, samplingConfig = latticesetup(Lx, Ly)
    heisSettings = UltraFast.heisenbergDefaultSettings()

    # model
    alpha = 1
    model = UltraFast.Models.FastTranslationInvariantRBM(lattice, alpha) #RBMModelLogIndep(lattice, alpha)

    #independent_weights = readdlm("test/pretrained/model_re_$(Lx)_$(Ly)_$(alpha).jl")[:] .+ im * readdlm("test/pretrained/model_im_$(Lx)_$(Ly)_$(alpha).jl")[:]
    
    
    independent_weights = readdlm("test/pretrained/W_RBM_$(nspins)_1_ti.jl")[:] .+ 0.0im

    display(independent_weights)

    UltraFast.loadweights!(model, independent_weights)

    function relative_wavefunction(state, flips)
        UltraFast.wavefunction_value(model, state, flips)
    end

    # # flux
    # model_flux = UltraFast.SetupLogRBM(lattice, alpha)

    # setup observable
    EnergyObs = UltraFast.EnergyObservable(samplingConfig.samples, samplingConfig.iterations)
    BoltzmannObs = UltraFast.BoltzmannStateObservable(samplingConfig.samples, samplingConfig.iterations)
    StateObservable = UltraFast.StateObservable(samplingConfig.samples, samplingConfig.iterations, lattice.nspins)

    ## UltraFast.HeisenbergEnergy(lattice, )


    function neel_state(n)
        if n % 2 != 0
            throw(ArgumentError("n must be an even number for a Neel state."))
        end
        
        neel = fill(0, n, n)
        for i in 1:n
            for j in 1:n
                neel[i, j] = (-1)^(i + j)
            end
        end
        
        return neel
    end

    # generate random state
    state = reduce(vcat,(neel_state(Lx))) #UltraFast.GenRandomState2(mag0, lattice.nspins)

    display(state)

    UltraFast.new_state!(model, state)
    wave1 = UltraFast.wavefunction_value(model, state)
    wave2 = UltraFast.wavefunction_value(model, state)

    print(wave1, wave2)
    
    #currentlog = log(wave1)
    
    #UltraF
    #print(wave)
    
    energy = UltraFast.HeisenbergEnergy(lattice, state, wave1, relative_wavefunction)
    display(energy)
    # run the optimization
   #@time model, energies, stddevs, observables = UltraFast.samplingHeisenberg2DModel(lattice, heisSettings, samplingConfig, model, UltraFast.SmatrixGradient(), optimiser = UltraFast.Optimisers.Descent(0.005), observables=(energy=EnergyObs, boltzmann=BoltzmannObs, state=StateObservable))

    #boltz = -UltraFast.value(observables.boltzmann)
    #states = UltraFast.value(observables.state)
    #display(boltz)
    #display(states)


    


    #display()
    #display(sort(-UltraFast.value(observables.boltzmann)))
end