module Models

using Flux
using Optimisers
using NNlib
using Statistics
using Tullio, LoopVectorization
using Random

using ..FluxComplexInitializers
using ..Lattice

"""
    Model{T}

Abstract base type for all variational ansätze in UltraFast.

# Type Parameters
- `T`: The numeric type used for model parameters (e.g., `Float64`,
  `ComplexF64`)

# Required Methods
## Descriptive methods
Implementations must provide:
- `nspins`: Return the number of spins in the system
- `number_of_parameters`: Return the total number of trainable parameters
- `hyperparameters`: Return model hyperparameters which can be modified to tune accuracy/performance
- `params_description`: Print parameter information in a human-readable format
- `settings`: Return a dictionary of model settings. Note that it should be
  possible to reconstruct the model from these settings.

## Gradients/wavefunction etc.
Implementations must provide:
- `gradient`: Compute gradients with respect to model parameters
- `wavefunction_value`: Evaluate the wavefunction at given state(s), with and without flips

## Optimization methods
Implementations must provide:
- `setup_optimiser`: Set up the optimizer state for training
- `update_weights!`: Update model weights using gradients and optimizer state

## Getting/setting weights
Implementations must provide:
- `get_weights`: Retrieve the current model weights in a form appropriate to the model
- `set_weights!`: Set the model weights to a provided vector of new weights
- `get_flattened_weights`: Retrieve the current model weights as a flattened vector

"""
abstract type Model{T} end

"""
    FluxModel{T} <: Model{T}

Abstract type for models implemented using Flux.jl.
"""
abstract type FluxModel{T} <: Model{T} end

"""
    ComplexFluxModel{T} <: FluxModel{T}

Abstract type for Flux-based models that use complex-valued weights.
"""
abstract type ComplexFluxModel{T} <: FluxModel{T} end

# Methods for abstract model - methods for gradient, wavefunction
"""
    gradient(m::Model, state::AbstractVector) -> Vector

Compute the gradient of the wavefunction with respect to model parameters/weights.

# Arguments
- `m::Model`: The model instance
- `state::AbstractVector`: Quantum state as a spin configuration (e.g., [1, -1, 1, -1])

# Returns
- `Vector`: Gradient vector with respect to model parameters
```
"""
function gradient(m::Model, state::AbstractVector)
    error("gradient must be implemented for type $(typeof(m)). " *
          "Please define: gradient(m::$(typeof(m)), state) = ...")
end

"""
    wavefunction_value(m::Model, state::AbstractVector) -> Number

Evaluate the wavefunction at the given quantum state.

# Arguments
- `m::Model`: The model instance
- `state::AbstractVector`: Quantum state as a spin configuration

# Returns
- `Number`: The wavefunction value (could be real or complex depending on the model)
```
"""
function wavefunction_value(m::Model, state::AbstractVector)
    error("wavefunction_value must be implemented for type $(typeof(m)). " *
          "Please define: wavefunction_value(m::$(typeof(m)), state) = ...")
end

"""
    wavefunction_value(m::Model, state::AbstractVector, flips::AbstractVector) -> Number

Evaluate the wavefunction at a state with specified spin flips applied.

Note that this has a default implementation that applies the flips and calls the standard method.
For performance-critical models, consider overriding this method with a more efficient implementation.

# Arguments
- `m::Model`: The model instance
- `state::AbstractVector`: Original quantum state
- `flips::AbstractVector{Int}`: Indices of spins to flip (1-indexed)

# Returns
- `Number`: The wavefunction value after applying the flips
"""
function wavefunction_value(m::Model, state::AbstractVector, flips::AbstractVector)
    # default implementation applies flips and calls the standard method
    state_flipped = copy(state)
    for flip in flips
        state_flipped[flip] *= -1
    end
    return wavefunction_value(m, state_flipped)
end

# Batched wavefunction_value for processing a batch of states
"""
    wavefunction_values(m::Model, states::AbstractMatrix) -> Vector

Evaluate the wavefunction for a batch of quantum states.

# Arguments
- `states`: Matrix where each column represents a quantum state

# Returns
Vector of wavefunction values corresponding to each state
"""
function wavefunction_values(m::Model, states::AbstractMatrix)
    return [wavefunction_value(m, states[:, index]) for index in axes(states, 2)]
end

# Parallel methods for abstract model - methods for gradient, wavefunction
"""
    gradient_parallel(m::Model, states::AbstractMatrix) -> Matrix
Compute the gradient of the wavefunction with respect to model parameters for a batch of states.
"""
function gradient_parallel(m::Model, states::AbstractMatrix)
    error("gradient_parallel must be implemented for type $(typeof(m)). " *
          "Please define: gradient_parallel(m::$(typeof(m)), states) = ...")
end

"""
    wavefunction_value_parallel(m::Model, state) -> Vector
    wavefunction_value_parallel(m::Model, state, flips) -> Vector
Compute the wavefunction values for a batch of states, with and without flips.
"""
function wavefunction_value_parallel(m::Model, states::AbstractMatrix)
    error("wavefunction_value_parallel must be implemented for type $(typeof(m)). " *
          "Please define: wavefunction_value_parallel(m::$(typeof(m)), states) = ...")
end

function wavefunction_value_parallel(m::Model, states::AbstractMatrix, flips::AbstractMatrix)
    error("wavefunction_value_parallel with flips must be implemented for type $(typeof(m)). " *
          "Please define: wavefunction_value_parallel(m::$(typeof(m)), states, flips) = ...")
end

# Methods for abstract model - methods for optimization
"""
    setup_optimiser(m::Model, optimiser::Optimisers.AbstractRule) -> OptimiserState
Set up the optimizer state for training the model.
"""
function setup_optimiser(m::Model, optimiser::Optimisers.AbstractRule)
    error("setup_optimiser must be implemented for type $(typeof(m)). " *
          "Please define: setup_optimiser(m::$(typeof(m)), optimiser) = ...")
end

"""
    update_weights!(opt_state, m::Model, gradient::AbstractVector) -> OptimiserState
Update the model weights using the provided gradient and optimizer state.
"""
function update_weights!(opt_state, m::Model, gradient::AbstractVector)
    error("update_weights! must be implemented for type $(typeof(m)). " *
          "Please define: update_weights!(opt_state, m::$(typeof(m)), gradient) = ...")
end

# Methods for abstract model - methods for getting/setting weights
"""
    get_flattened_weights(m::Model) -> Vector
Retrieve the current model weights as a flattened vector.
"""
function get_flattened_weights(m::Model)
    error("get_flattened_weights must be implemented for type $(typeof(m)). " *
          "Please define: get_flattened_weights(m::$(typeof(m))) = ...")
end

"""
    get_weights(m::Model)
Retrieve the current model weights in a form more natural to the model.
Defaults to calling `get_flattened_weights`, override if needed.
"""
get_weights(m::Model) = get_flattened_weights(m)

"""
    set_weights!(m::Model, new_weights::AbstractVector)
Set the model weights to the provided vector of new weights.
"""
function set_weights!(m::Model, new_weights::AbstractVector)
    error("set_weights! must be implemented for type $(typeof(m)). " *
          "Please define: set_weights!(m::$(typeof(m)), new_weights) = ...")
end

# Methods for abstract model - specific optimization methods
handle_state_update!(m::Model, state::AbstractVector, flips::AbstractVector) = nothing  # for models which need to update their state after a flip
new_state!(m::Model, state::AbstractVector) = nothing  # for models which for a totally new state need to do stuff

# Methods for abstract model - descriptive methods
"""
    number_of_parameters(m::Model) -> Int

Return the total number of trainable parameters in the model.
"""
function number_of_parameters(m::Model)
    error("number_of_parameters must be implemented for type $(typeof(m)). " *
          "Please define: number_of_parameters(m::$(typeof(m))) = ...")
end

"""
    params_description(m::Model)

Print a description of the model parameters.
"""
function params_description(m::Model)
    error("params_description must be implemented for type $(typeof(m)). " *
          "Please define: params_description(m::$(typeof(m))) = ...")
end

"""
    nspins(m::Model) -> Int

Return the number of spins in the quantum system.
"""
function nspins(m::Model)
    error("nspins must be implemented for type $(typeof(m)). " *
          "Please define: nspins(m::$(typeof(m))) = ...")
end

"""
    hyperparameters(m::Model) -> Dict

Return a dictionary of model hyperparameters.
"""
function hyperparameters(m::Model)
    error("hyperparameters must be implemented for type $(typeof(m)). " *
          "Please define: hyperparameters(m::$(typeof(m))) = ...")
end

"""
    settings(m::Model) -> Dict
Return a dictionary of model settings.
"""
function settings(m::Model)
    error("settings must be implemented for type $(typeof(m)). " *
          "Please define: settings(m::$(typeof(m))) = ...")
end

# Methods for describing the model
"""
    identifier(m::Model) -> String

Return a string identifier for the model type.
"""
identifier(m::Model) = string(typeof(m))

"""
    save_model(m::Model)

    Returns a dictionary containing all information needed to reconstruct the model.
"""
function save_model(m::Model)
    flattened_weights = get_flattened_weights(m)
    model_settings = settings(m)
    return Dict("type" => identifier(m), "weights" => copy(flattened_weights), "settings" => model_settings)
end

#### Model Implementations ####
include("fluxmodels.jl")

#### Helpers ####
include("model+io.jl")
include("model+prettyio.jl")

#### Model specific methods ####
"""
    get_RBM_weights(model::Model)

For a model representing a Restricted Boltzmann Machine (RBM), retrieve the weight matrices and biases.

# Arguments
- `model`: An instance of a model that implements the RBM architecture.

# Returns
A named tuple containing:
- `W`: The weight matrix connecting visible and hidden units.
- `b`: The bias vector for the hidden units.
"""
function get_RBM_weights(model::Model)
    error("get_RBM_weights must be implemented for type $(typeof(model)). " *
          "Please define: get_RBM_weights(m::$(typeof(model))) = ...")
end

# Exports organized by functionality
# ===================================

# Abstract types
export Model, FluxModel, ComplexFluxModel

# Core wavefunction evaluation methods
export wavefunction_value, wavefunction_values

# Gradient computation methods  
export gradient

# Parallel computation methods
export wavefunction_value_parallel, gradient_parallel

# Model introspection and description
export number_of_parameters, params_description, nspins, hyperparameters, identifier

# Optimization methods
export setup_optimiser, update_weights!

# State management methods
export new_state!, handle_state_update!

end # module Models

