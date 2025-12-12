module TranslationInvarianceTools

import ..WvDerivativeTi: cod

#import ..Types: ComplexType

"""
    WeightTranslator

A struct representing a weight translator used for restricted boltzmann machine
with periodic boundary conditions.

# Fields
- `independent_weights::Array{ComplexType,1}`: An array of independent weights.
- `weights::Array{ComplexType,2}`: A 2D array of weights.
- `biases::Array{ComplexType,1}`: An array of biases.
- `construction_table_weights::Array{Int64,2}`: A 2D array representing the construction
  table.

# Description
The `construction_table_weights` is a 2D array of index of the independent weights. The first index is the row of the
weight matrix. The second index is column of the weight matrix.

"""
struct WeightTranslator
    construction_table_weights::Array{Int,2}
    construction_table_biases::Array{Int,1}
    alpha::Int
    nspins::Int
    Lx::Int
    Ly::Int
end

"""
    WeightTranslator(nspins::Int, alpha::Int, Lx::Int, Ly::Int)

Constructs a `WeightTranslator` object that translates the independent weights into the full weight matrix and biases.

# Arguments
- `nspins::Int`: the number of spins in the system
- `alpha::Int`: the number of independent weights
- `Lx::Int`: the number of spins in the x-direction
- `Ly::Int`: the number of spins in the y-direction

# Returns
- `WeightTranslator`: a `WeightTranslator` object that can be used to translate the independent weights into the full weight matrix and biases.

# Examples
```julia
# Create a weight translator
Lx = 2
Ly = 2
nspins = Lx * Ly
alpha = 2
translator = WeightTranslator(nspins, alpha, Lx, Ly)

# Create a random set of independent weights
independent_weights = randn(ComplexType, alpha + alpha*nspins)

# Translate the independent weights into the full weight matrix and biases
weights, biases = weights_from(translator, independent_weights)

```

"""
function WeightTranslator(nspins::Int, alpha::Int, Lx::Int, Ly::Int)
    # matrix to construct the weight matrix from the independent weights
    construction_table_weights = zeros(Int, nspins, alpha*nspins)
    
    # matrix to construct the biases from the independent weights
    construction_table_biases = zeros(Int, alpha*nspins)

    # construction table weights
    for h in 1:alpha
        construction_table_weights[:,(h-1)*nspins+1:h*nspins] = cod(h-1, Lx, Ly) .+ alpha
    end

    # construction table biases
    for h in 1:alpha
        construction_table_biases[(h-1)*nspins+1:h*nspins] = ones(Int64, nspins)*h
    end

    WeightTranslator(construction_table_weights, construction_table_biases, alpha, nspins, Lx, Ly)
end

Base.show(io::IO, t::WeightTranslator) = let
    println(io, "Weights = ")
    println(io, t.construction_table_weights)
    println(io, "Biases = ")
    println(io, t.construction_table_biases)
    println(io, "Number of parameters = ")
    println(length(t.construction_table_weights) + length(t.construction_table_biases), " == ", t.alpha * t.nspins + t.alpha * t.nspins^2)
    println(io, "Number of independent parameters = ")
    println(t.alpha + t.alpha * t.nspins)
end 

function weights_from!(translator::WeightTranslator, independent_weights::Array{T,1}, weights::Array{T, 2}, biases::Array{T, 1}) where {T <: Number}
    # weights
    weights[:] = independent_weights[translator.construction_table_weights]
    # biases
    biases[:] = independent_weights[translator.construction_table_biases]

    return weights, biases
end

function weights_from(translator::WeightTranslator, independent_weights::Array{T,1}) where {T <: Number}
    # weight matrix is nspins x alpha * nspins
    weights = zeros(T, translator.nspins, translator.alpha*translator.nspins)
    # bias matrix is alpha * nspins
    biases = zeros(T, translator.alpha*translator.nspins)

    return weights_from!(translator, independent_weights, weights, biases) 
end

function independent_weights_from_inefficient(translator::WeightTranslator, weights::Array{T, 2}, biases::Array{T, 1}) where {T <: Number}
    println("WARNING: DO NOT USE THIS FUNCTION, IT RESULTS IN UNDEFINED BEHAVIOUR")

    # independent weights
    independent_weights = zeros(T, translator.alpha + translator.alpha * translator.nspins)
    # weights
    independent_weights[translator.construction_table_weights] = weights[:]
    # biases
    independent_weights[translator.construction_table_biases] = biases[:]

    return independent_weights
end

function independent_weights_from!(translator::WeightTranslator, weights::Array{T, 2}, biases::Array{T, 1}, independent_weights::Array{T,1}) where {T <: Number}
    alpha = translator.alpha
    nspins = translator.nspins
    # weights
    independent_weights[alpha+1:alpha+alpha*nspins] = weights[1, :]
    # biases
    independent_weights[1:alpha] = biases[1:nspins:nspins*alpha]

    return independent_weights
end

function independent_weights_from(translator::WeightTranslator, weights::Array{T, 2}, biases::Array{T, 1}) where {T <: Number}
    alpha = translator.alpha
    nspins = translator.nspins
    # independent weights
    independent_weights = zeros(ComplexType, alpha + alpha * nspins)

    return independent_weights_from!(translator, weights, biases, independent_weights)
end

end
