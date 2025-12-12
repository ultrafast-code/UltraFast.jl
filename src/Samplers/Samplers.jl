
module Samplers

using ..Models: Model, new_state!, wavefunction_value, nspins, handle_state_update!
using ..Helpers

abstract type AbstractSampler end

# method to get sampling settings, like number of samples, number of iterations, number of thermalization sweeps, number of sweeps per iteration
settings(sampler::AbstractSampler) = error("Not implemented for $(typeof(sampler))")

# standard methods for Sampler
sample(sampler::AbstractSampler, model::Model) = error("Not implemented for $(typeof(sampler))")

# ######## Full summation Samplers ########
abstract type AbstractExactSampler <: AbstractSampler end

###### Markov Chain Monte Carlo Samplers ######
abstract type AbstractMCMCSampler <: AbstractSampler end

include("MCMCSettings.jl")

include("MHSamplers.jl")

###### Exports ######
export AbstractSampler, AbstractMCMCSampler, sample, settings, MCMCSettings, MHSampler

end