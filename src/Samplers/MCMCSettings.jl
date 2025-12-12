
"""
    struct MCMCSettings

The `MCMCSettings` struct represents the settings for a Markov Chain Monte Carlo simulation.

# Fields
- `sweep::Int`: The number of sweeps to perform in the simulation.
- `nsamples::Int`: The number of samples to collect during the simulation.
- `nthermalization::Int`: The number of thermalization steps to perform before collecting samples measured in sweeps.

"""
Base.@kwdef struct MCMCSettings
    sweep::Int
    nsamples::Int
    nthermalization::Int
end
