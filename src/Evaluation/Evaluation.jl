using Distributed
using Dagger
import Statistics

function evaluate(settings;
    model::Model,
    hamiltonian::Hamiltonian)

    nspins = Hamiltonians.nspins(hamiltonian)

    # settings
    sweep = get(settings, "sweep", nspins)
    n_chains = settings["n_chains"]
    nsamples = settings["nsamples"]
    nthermalization = get(settings, "nthermalization", 200)

    # construct mcmcsettings
    mcmc_settings = MCMCSettings(sweep, nsamples*n_chains, nthermalization)

    # create sampler
    sampler = MultiProcessing.ParallelMCMCSampler(mcmc_settings, Samplers.MHSampler(mcmc_settings), n_chains)

    # create observables
    sr_obs = Observables.SRObservables()
    obs = (SR=sr_obs, )

    # sample
    t_sampling = @elapsed states = Samplers.sample(sampler, model)

    
    all_observables = pmap(i -> begin
        states_chain = states.states[:,:,i]
        logwavefunctions_chain = states.logwavefunctions[:,i]
        return Observables.observe(obs; states=states_chain, logwavefunctions=logwavefunctions_chain, model=deepcopy(model), hamiltonian=hamiltonian)
    end, 1:n_chains)

    # collect Elocs and logwavefunctions from all chains
    all_Elocs = hcat([observables.SR.Elocs for observables in all_observables]...)
    all_logwavefunctions = states.logwavefunctions

    energy = Statistics.mean(all_Elocs) / (nspins * 4)
    stddev = Statistics.std(all_Elocs) / (nspins * 4)

    energy_err = Statistics.std(Statistics.mean.(eachcol(all_Elocs)), corrected=true) / sqrt(n_chains) / (nspins * 4)

    v_score = vscore(nspins, energy, stddev^2)

    # prepare output
    raw_data_output = Dict{String,Any}()
    raw_data_output["elocs"] = all_Elocs / (nspins * 4)
    raw_data_output["logwavefunctions"] = all_logwavefunctions

    measurement_data = Dict(
        "energy_mean" => energy,
        "energy_std" => stddev,
        "energy_err" => energy_err,
        "v_score" => v_score,
        "t_sampling" => t_sampling,
        "runtime" => states.metadata.runtime
    )

    if reference_energy(hamiltonian) !== nothing
        relative_error_, metrics = relative_error(energy, hamiltonian)
        measurement_data["relative_error"] = relative_error_
        measurement_data["relative_error_error"] = energy_err / metrics["energy"]
        measurement_data["relative_error_method"] = metrics["method"]
        measurement_data["reference_energy"] = metrics["energy"]
    end
    
    metadata = Dict(
        "sampling" => Samplers.settings(sampler),
        "model" => Models.settings(model),
        "hamiltonian" => Hamiltonians.settings(hamiltonian),
        "nspins" => nspins,
        "UltraFastVersion" => version,
        "metadata" => Dict(
            "ARCH" => string(Sys.ARCH),
            "OS" => string(Sys.KERNEL),
            "Julia" => string(VERSION),
            "CPU" => string(Sys.CPU_NAME),
            "threads" => string(Sys.CPU_THREADS),
            "MACHINE" => string(Sys.MACHINE)
        )
    )
    
    return (raw=raw_data_output, measured=measurement_data, metadata=metadata)
end