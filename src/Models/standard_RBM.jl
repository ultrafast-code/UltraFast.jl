# Standard RBM
abstract type AbstractFluxRBM{T} <: ComplexFluxModel{T} end


# Gradients/wavefunction
function gradient(m::AbstractFluxRBM, state::AbstractVector)
    if m.isComplex == true
        return conj(Flux.destructure(Flux.gradient(model_ -> mean(real(model_(state))), m.model))[1])
    else
        return Flux.destructure(Flux.gradient(model_ -> mean(model_(state)), m.model))[1]
    end
end

gradient_parallel(m::AbstractFluxRBM, states::AbstractMatrix) = gradient(m, states)

"""
    RBM

A Restricted Boltzmann Machine (RBM)

The wavefunction_value method returns the logarithm of the wavefunction.
``
\\log \\psi(s) = \\beta \\sum_j \\log(2 \\cosh(b_j + \\sum_i W_{ij} s_i))
``

# Fields
- `lattice::LatticeSettings`: The lattice settings defining the number of spins and dimensions
- `alpha::Int`: The hidden layer density (number of hidden units per visible unit)
- `isComplex::Bool`: Whether the model uses complex numbers
- `restructure::Optimisers.Restructure`: A function to restructure the parameter vector into model
- `model`: The underlying Flux model representing the RBM

"""
mutable struct RBM{T} <: ComplexFluxModel{T}
    # hyperparameters
    lattice::LatticeSettings
    alpha::Int # hidden layer density
    beta::Float64
    isComplex::Bool # whether the model uses complex numbers

    # required parts for Flux model
    restructure::Optimisers.Restructure
    model
end

# Descriptive methods
nspins(m::RBM) = m.lattice.nspins

function settings(m::RBM)
    return Dict(
        "type" => identifier(m),
        "Lx" => m.lattice.Lx,
        "Ly" => m.lattice.Ly,
        "nspins" => m.lattice.nspins,
        "isComplex" => m.isComplex,
        "beta" => m.beta,
        "alpha" => m.alpha
    )
end

function hyperparameters(m::RBM)
    return Dict(
        "isComplex" => m.isComplex,
        "beta" => m.beta,
        "alpha" => m.alpha
    )
end

function params_description(m::RBM) 
    println("nparams = $(number_of_parameters(m)) - indep = $(m.lattice.nspins * m.alpha + m.alpha), tot = $(m.lattice.nspins * m.alpha + m.alpha + m.lattice.nspins^2)")
end


# Helpers for pretty printing
Base.show(io::IO, model::RBM) = print(io, "RBM(nspins = $(model.lattice.Lx) x $(model.lattice.Ly) = $(model.lattice.nspins), alpha = $(model.alpha))")


## Initializers

"""
RBM(lattice::LatticeSettings, alpha::Int; init=complex_glorot_uniform(gain=0.001), isComplex = true, beta=1.0)

# Arguments
- `lattice::LatticeSettings` or `LatticeConfig`: The lattice settings defining the number of spins and dimensions
- `alpha::Int`: The hidden layer density (number of hidden units per visible unit)
- `init`: Weight initializer function (default: `complex_glorot_uniform(gain=0.001)`)
- `isComplex::Bool`: Whether the model uses complex numbers (default: `true`)
- `beta::Float64`: Inverse temperature parameter (default: `1.0`)

# Examples
```julia
# Create an RBM with 10 visible units and alpha = 5
model = RBM(10, 5)

# Generate a random input vector
input = rand(10)

# Compute the output of the RBM
output = model(input)
```
"""
function RBM(lattice::LatticeSettings, alpha::Int; init=complex_glorot_uniform(gain=0.001), isComplex = true, beta=1.0)
    # calculate the number of hidden units
    hidden = lattice.nspins * alpha

    model_type = eltype(init(1))

    # define the model
    model = Chain(Dense(lattice.nspins, hidden, init=init), x -> beta .* sum(log.(2cosh.(x)), dims=1))
    
    _, re = Flux.destructure(model)

    RBM{model_type}(lattice, alpha, beta, isComplex, re, model)
end

RBM(lattice::LatticeConfig, alpha::Int; init=complex_glorot_uniform(gain=0.001), isComplex=true, beta=1.0) = RBM(lattice.settings, alpha; init=init, isComplex=isComplex, beta=beta)

## Initialize from settings dictionary
function RBM(hyperparameters; lattice::LatticeConfig)
    alpha = hyperparameters["alpha"]
    init = hyperparameters["weight_initializer"]
    beta = hyperparameters["beta"]

    if init == "complex_default_uniform"
        RBMModelLog(lattice.settings, alpha; init = Models.default_uniform(), isComplex=false, beta=beta)
    elseif init == "real_default_uniform"
        RBMModelLog(lattice.settings, alpha; init = Models.real_default_uniform(), isComplex=true, beta=beta)
    else
        error("Unknown weight initializer: $init")
    end
end

# loading/saving weights

function set_weights!(m::RBM, W::AbstractMatrix, b::AbstractVector)
    params = Flux.state(m.model)
    params.layers[1].weight .= W
    params.layers[1].bias .= b
    return nothing
end

function get_weights(m::RBM)
    params = Flux.state(m.model)
    W = params.layers[1].weight
    b = params.layers[1].bias
    return (W=W, b=b)
end

function get_RBM_weights(m::RBM)
    return get_weights(m)
end

# convenience initializer from weights
function RBM(lattice::LatticeConfig, alpha::Int, W::AbstractMatrix, b::AbstractVector; isComplex=true, beta=1.0)
    new_model = RBM(lattice.settings, alpha; isComplex=isComplex, beta=beta)
    set_weights!(new_model, W, b)
    return new_model
end

