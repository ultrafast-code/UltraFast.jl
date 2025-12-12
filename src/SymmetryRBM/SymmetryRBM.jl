module SymmetryRBM

using ..Models
using ..Lattice
using Optimisers
using Flux


include("pbc/pbc.jl")
include("neuralNetwork/nn.jl")

include("neuralNetwork/WtoPar_ti.jl")

import .TranslationInvarianceTools: WeightTranslator, weights_from!, independent_weights_from!, independent_weights_from, weights_from

include("Models/FastTranslationInvariantRBM/FastTranslationInvariantRBM.jl")
include("Models/TranslationInvariantRBM/TranslationInvariantRBM.jl")

end