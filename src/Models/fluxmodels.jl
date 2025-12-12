##### Flux #####

# Methods for Flux-based models which store their model in a field called `model`
number_of_parameters(m::FluxModel) = get_number_of_parameters(m.model)
wavefunction_value(m::FluxModel, state::AbstractVector) = m.model(state)[1]
wavefunction_values(m::FluxModel, states::AbstractMatrix) = m.model(states)
wavefunction_value_parallel(m::FluxModel, states::AbstractMatrix) = m.model(states)
setup_optimiser(m::FluxModel, optimiser::Optimisers.AbstractRule) = Optimisers.setup(optimiser, m.model)
get_flattened_weights(m::FluxModel) = Optimisers.destructure(m.model)[1]

_internal_restructure(m::FluxModel, params::AbstractVector) = m.restructure(params)

function update_weights!(opt_state, m::FluxModel, gradient::AbstractVector)
    opt_state, m.model = Optimisers.update!(opt_state, m.model, _internal_restructure(m, gradient))
    return opt_state
end

function wavefunction_value(m::FluxModel, state::AbstractVector, flips::AbstractVector)
    # make a new state with the changes
    newstate = copy(state)
    for i = 1:2
        @inbounds newstate[flips[i]] *= -1
    end
    
    return wavefunction_value(m, newstate)
end

function wavefunction_value_parallel(m::FluxModel, states::AbstractMatrix, flips::AbstractMatrix)
    # make a new state with the changes
    # flips is layed out like [nflips, nparallel]
    # states is layed out like [nspins, nparallel]
    newstates = copy(states)
    nparallel = size(states)[2]

    # flip the states
    for i = 1:nparallel
        for flip in flips[:, i]
            @inbounds newstates[flip, i] *= -1
        end
    end

    return wavefunction_value_parallel(m, newstates)
end

"""
    gradient(m::ComplexFluxModel, state::AbstractVector) -> Vector{T}
Compute the gradient of the log wavefunction with respect to the model parameters for a given state.
ComplexFluxModel which is meant for models made with Flux which use Complex weights
"""
gradient(m::ComplexFluxModel, state::AbstractVector) = conj(Optimisers.destructure(Flux.gradient(model_ -> real(model_(state)), m.model))[1])


##### Models made with Flux ##### 
# RBM Model and invariant RBM model
include("standard_RBM.jl")
