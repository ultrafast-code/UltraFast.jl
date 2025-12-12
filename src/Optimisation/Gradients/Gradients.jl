abstract type Gradients end

(m::Gradients)(OkconjOkprime, Ok, ElocOkconj, Eloc, iteration) = error("gradient not implemented for $(typeof(m))")

include("Smatrix.jl")
include("PlainDescent.jl")
include("SmatrixDeltaReg.jl")