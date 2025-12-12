Base.@kwdef struct Heisenberg <: Hamiltonian
    # Model
    J_x::Float64 = 1.0
    J_y::Float64 = 1.0

    # Size
    lattice::LatticeConfig

    # magnetization
    mag0::Bool = true

    # Calculate the energy by batching or not
    parallel::Bool = false

    # sign rule
    marshall_sign_rule::Bool = true
end

include("Heisenberg+Energy.jl")
include("Heisenberg+io.jl")
include("Heisenberg+prettyio.jl")
include("Heisenberg+reference.jl")