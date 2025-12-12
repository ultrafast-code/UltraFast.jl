# Translation invariant RBM
mutable struct TranslationInvariantRBM{T} <: Models.AbstractFluxRBM{T}
  lattice::LatticeSettings
  alpha::Int
  beta::Float64
  restructure::Optimisers.Restructure
  isComplex::Bool
  model
end

# Descriptive methods
Models.nspins(m::TranslationInvariantRBM) = m.lattice.nspins

function Models.settings(m::TranslationInvariantRBM)
  Dict(
    "type" => "TranslationInvariantRBM", 
    "Lx" => m.lattice.Lx,
    "Ly" => m.lattice.Ly,
    "nspins" => m.lattice.nspins, 
    "isComplex" => m.isComplex,
    "beta" => m.beta,
    "alpha" => m.alpha,
  )
end

function Models.hyperparameters(m::TranslationInvariantRBM)
  Dict(
    "isComplex" => m.isComplex,
    "beta" => m.beta,
    "alpha" => m.alpha,
  )
end

function Models.set_weights!(m::TranslationInvariantRBM, new_independent_weights::AbstractVector)
  m.model.independent_weight .= new_independent_weights
end

function Models.get_weights(model::TranslationInvariantRBM)
  W, b = weights_from(model.model.translator, model.model.independent_weight)
  return (W=W, b=b)
end

Models.get_RBM_weights(model::TranslationInvariantRBM) = Models.get_weights(model)

"""
    RBMModelLogIndep(nspins, alpha; initializer)

Translation-invariant Restricted Boltzmann Machine (RBM) model using Flux.jl.

# Arguments
- `nspins::Int`: The number of visible units (or spins) in the RBM.
- `alpha::Int`: The number of hidden units in the RBM as a multiple of the
  number of visible units/nspins.

# Returns
A Flux.jl model representing a Restricted Boltzmann Machine with the specified
number of visible and hidden units.

# Description
This function creates an RBM model using the Flux.jl library.

The `complex_glorot_uniform` initializer is used to initialize the weights. This
initializer is designed to handle complex-valued weights.

# Examples
```julia
# Create an RBM with 10 visible units and 5 hidden units
model = RBMModel(10, 5)

# Generate a random input vector
input = rand(10)

# Compute the output of the RBM
output = model(input)
```

"""
function TranslationInvariantRBM(lattice::LatticeSettings, alpha::Int; init=Models.default_uniform(), isComplex=true, beta=1.0)
    model = RBMIndepLayer(lattice.Lx, lattice.Ly, alpha; beta=beta, init=init)
    
    _, re = Flux.destructure(model)
    return TranslationInvariantRBM{eltype(model.independent_weight)}(lattice, alpha, beta, re, isComplex, model)
end

TranslationInvariantRBM(lattice::LatticeConfig, alpha::Int; beta=1.0, init=Models.default_uniform(), isComplex=true) = TranslationInvariantRBM(lattice.settings, alpha; beta=beta, init=init, isComplex=isComplex)

"""
    RBMIndepLayer

A struct representing an independent layer of a Restricted Boltzmann Machine
(RBM) neural network.

# Fields
- `Lx::Int`: The width of the layer.
- `Ly::Int`: The height of the layer.
- `alpha::Int`: The number of hidden units in the layer.
- `nspins::Int`: The total number of spins in the layer (equal to `Lx * Ly`).
- `independent_weight::Array{ComplexType,1}`: The independent weights of the
  layer.
- `W::Array{ComplexType, 2}`: The weight matrix connecting the visible and
  hidden units.
- `b::Array{ComplexType, 1}`: The bias vector of the hidden units.

# Usage

```julia

layer = RBMIndepLayer(Lx=2, Ly=2, alpha=2)

```

# Description

The only parameter that should be changed is `independent_weight`. The other are
constants, including W and b.

"""
Base.@kwdef struct RBMIndepLayer{A <: AbstractArray{<:Number, 1}}
    Lx::Int
    Ly::Int
    alpha::Int
    beta::Float64
    independent_weight::A = randn(ComplexType, alpha + alpha*nspins)
    nspins::Int = Lx*Ly
    translator::WeightTranslator = WeightTranslator(nspins, alpha, Lx, Ly)
end

# Overload call, so the object can be used as a function
(m::RBMIndepLayer)(x) = m.beta*sum(log.(2cosh.(transpose(m.independent_weight[m.translator.construction_table_weights]) * x .+ m.independent_weight[m.translator.construction_table_biases])), dims=1)

Flux.@layer :noexpand RBMIndepLayer trainable=(independent_weight,)

function RBMIndepLayer(Lx::Int, Ly::Int, alpha::Int; beta=1.0, init=default_uniform())
    independent_weight = init(alpha + alpha*Lx*Ly)
    return RBMIndepLayer(Lx=Lx, Ly=Ly, beta=beta, alpha=alpha, independent_weight=independent_weight)
end

include("TranslationInvariantRBM+io.jl")