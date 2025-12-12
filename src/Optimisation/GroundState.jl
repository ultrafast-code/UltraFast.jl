include("GroundStateOptimizationHyperParameters.jl")

"""
    struct GroundStateOptimisation

A struct representing the parameters for ground state optimization.

# Fields
- `H::Hamiltonian`: The Hamiltonian.
- `optimiser::Optimiser.AbstractRule`: The optimizer. Default is `Optimiser.Descent(0.005)`.
- `sampler::Sampler`: The sampler.
- `gradient::Gradients`: The gradient. Default is `SmatrixGradient()`.
- `callback::Function`: The callback function. Default is `() -> nothing`.

"""
Base.@kwdef struct GroundStateOptimisation{O<:Optimisers.AbstractRule,S<:AbstractSampler,G<:Gradients}
    # Optimiser
    optimiser::O = Optimisers.Descent(0.005)
    # Number of iterations
    niterations::Int64 = 300
    # Sampler
    sampler::S
    # Gradient
    gradient::G = SmatrixGradient()
    # Callback function
    callback::Union{Function, Nothing} = nothing
end

include("GroundState+optimise.jl")
include("GroundState+io.jl")