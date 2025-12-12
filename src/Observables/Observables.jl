module Observables

import Base.:*

using ..Hamiltonians
using ..Models
using ..Helpers

abstract type Observable end

observe(o::Observable; states::AbstractArray{Int}, logwavefunctions::AbstractArray, model::Model, hamiltonian::Hamiltonian) = error("observe not implemented for $(typeof(o))")

function observe(o::NamedTuple; states::AbstractArray{Int}, logwavefunctions::AbstractArray, model::Model, hamiltonian::Hamiltonian)
    keys_list = keys(o)
    observables = []
    for k in keys_list
        observation = observe(o[k]; states=states, logwavefunctions=logwavefunctions, model=model, hamiltonian=hamiltonian)
        push!(observables, observation)
    end

    return (; zip(keys_list, observables)...)
end


include("VariationalEnergy.jl")
include("SRObservables.jl")

end

