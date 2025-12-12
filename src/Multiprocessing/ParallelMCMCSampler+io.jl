using JSON

function ParallelMCMCSampler(settings::AbstractDict; sampler::T) where {T<:AbstractMCMCSampler}
    sweep = settings["sweep"]

    # Load the settings from the Monte Carlo settings
    nsamples = settings["nsamples"]
    nthermalization = settings["nthermalization"]

    n_chains = settings["n_chains"]

    mcmcsettings = MCMCSettings(sweep=sweep, nsamples=nsamples, nthermalization=nthermalization)

    return ParallelMCMCSampler{T}(mcmcsettings, sampler, n_chains)

end

JSON.lower(s::ParallelMCMCSampler) = Dict(
    "type" => "ParallelMCMCSampler",
    "settings" => s.settings,
    "n_chains" => s.n_chains
)

function Samplers.settings(sampler::ParallelMCMCSampler)
    return Dict(
        "type" => "ParallelMCMCSampler",
        "sweep" => sampler.mcmcsettings.sweep,
        "nsamples" => sampler.mcmcsettings.nsamples,
        "nthermalization" => sampler.mcmcsettings.nthermalization,
        "n_chains" => sampler.n_chains,
        "base_sampler" => string(typeof(sampler.sampler)),
        "base_sampler_settings" => Samplers.settings(sampler.sampler)
    )
end