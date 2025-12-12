#include("EverywhereCode.jl")
using Statistics
using Dagger

struct ParallelMCMCSampler{T<:AbstractMCMCSampler} <: AbstractMCMCSampler
    mcmcsettings::MCMCSettings
    sampler::T
    n_chains::Int
end

function Samplers.sample(sampler::ParallelMCMCSampler, 
                model::Model;
                initial_states::Matrix{Int} = hcat([random_spin_state(nspins(model), true) for _ in 1:sampler.n_chains]...),
                nsamples::Int = sampler.mcmcsettings.nsamples,
                nthermalization::Int = sampler.mcmcsettings.nthermalization,
                sweep::Int = sampler.mcmcsettings.sweep,
                n_chains::Int = sampler.n_chains,
                callback::Function = (phase, step, total) -> nothing)
    
    @assert size(initial_states, 1) == nspins(model) "Initial states must have size (nspins, n_chains)"
    @assert size(initial_states, 2) == n_chains "Initial states must have size (nspins, n_chains)"
    @assert nsamples % n_chains == 0 "nsamples must be divisible by n_chains"

    # create final mc settings if user decided to change them
    mcsettings = MCMCSettings(nthermalization=nthermalization, nsamples=Int(nsamples / n_chains), sweep=sweep)

    #output_states = []
    # run the sampling for each chain

    output_states = pmap(i -> begin
        states_ = Samplers.sample(sampler.sampler, 
                                        deepcopy(model); 
                                        initial_state=initial_states[:, i], 
                                        nsamples=mcsettings.nsamples, 
                                        nthermalization=mcsettings.nthermalization, 
                                        sweep=mcsettings.sweep, 
                                        callback=callback)
    end, 1:n_chains)

    # concatenate results
    states = cat([s.states for s in output_states]..., dims=3)
    logwavefunctions = cat([s.logwavefunctions for s in output_states]..., dims=2)

    metadata = condense_namedtuples_into_dict([s.metadata for s in output_states])

    return (states=states, 
            logwavefunctions=logwavefunctions, 
            metadata=(metadata..., n_chains=n_chains))
end

include("ParallelMCMCSampler+io.jl")

export ParallelMCMCSampler