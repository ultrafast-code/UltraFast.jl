using LinearAlgebra


# Regularisation scheme adapted from https://arxiv.org/pdf/2301.06788
Base.@kwdef struct SmatrixGradientDeltaReg <: Gradients
    delta_1::Float64 = 10 # diagonal elements multiplied by a factor 1+delta_1
    delta_2::Float64 = 1E-4 # adding delta_2 to all diagonal entries

    # mutating values
    falloff_rate = 0.9 # exponential decay rate
end

(m::SmatrixGradientDeltaReg)(OkconjOkprime, Ok, ElocOkconj, Eloc, iteration) = begin
    SMatrix = OkconjOkprime - conj(Ok) * transpose(Ok)

    # Add a bias term to the Smatrix
    SMatrix = SMatrix + (Matrix{Float64}(I, size(SMatrix)...) .* m.delta_2) + Diagonal(diag(SMatrix)) * m.delta_1 * (m.falloff_rate^iteration) #(Matrix{Float64}(I, size(SMatrix)...) .* m.delta_1)

    invS = inv(SMatrix)

    return invS * (ElocOkconj - (Eloc * conj(Ok)))
end

SmatrixGradientDeltaReg(settings) = SmatrixGradientDeltaReg(
    delta_1=settings["delta_1"],
    delta_2=settings["delta_2"],
    falloff_rate=settings["falloff_rate"]
)

