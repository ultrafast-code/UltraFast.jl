module RBMLoading

import ..UltraFast.Types: FloatType, WeightType

independent_weights(model) = error("loading independent weights not implemented for $(typeof(model))")

weights(model) = error("loading weights not implemented for $(typeof(model))")

set_independent_weights!(model, independent_weights::Array{WeightType}) = error("setting independent weights not implemented for $(typeof(model))")
set_independent_weights!(model, independent_weights::Array{FloatType}) = error("setting independent real weights not implemented for $(typeof(model))")

set_weights!(model, weights::Array{WeightType, 2}, biases::Array{WeightType}) = error("setting weights not implemented for $(typeof(model))")
set_weights!(model, weights::Array{FloatType, 2}, biases::Array{FloatType}) = error("setting weights not implemented for $(typeof(model))")

end
