using LinearAlgebra


Base.@kwdef struct SmatrixGradient <: Gradients
    max_epsilon::Float64 = 0.0001
    falloff_rate::Float64 = 0.9
    initial_falloff_rate::Float64 = 100
    # mutating values
end

(m::SmatrixGradient)(OkconjOkprime, Ok, ElocOkconj, Eloc, iteration) = begin
    SMatrix = OkconjOkprime - conj(Ok) * transpose(Ok)

    # Add a bias term to the Smatrix
    SMatrix = SMatrix .+ Matrix{Float64}(I, size(SMatrix)...) .* max(m.initial_falloff_rate * ((m.falloff_rate)^iteration), m.max_epsilon)

    invS = inv(SMatrix)

    return invS * (ElocOkconj - (Eloc * conj(Ok)))
end

SmatrixGradient(settings) = SmatrixGradient(
    max_epsilon=get(settings, "max_epsilon", 0.0001),
    falloff_rate=get(settings, "falloff_rate", 0.9),
    initial_falloff_rate=get(settings, "initial_falloff_rate", 100)
)


