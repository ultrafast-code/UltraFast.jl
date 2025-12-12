function MHSampler(settings::AbstractDict)
    sweep = settings["sweep"]
    nsamples = get(settings, "nsamples", 2000)
    nthermalization = get(settings, "nthermalization", 200)

    mcmcsettings = MCMCSettings(sweep=sweep, nsamples=nsamples, nthermalization=nthermalization)

    return MHSampler(mcmcsettings)

end

function settings(sampler::MHSampler)
    return Dict(
        "type" => "MHSampler",
        "sweep" => sampler.settings.sweep,
        "nsamples" => sampler.settings.nsamples,
        "nthermalization" => sampler.settings.nthermalization
    )
end