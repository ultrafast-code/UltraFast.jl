module MultiProcessing

using Distributed

using ..Samplers
using ..Models
using ..Lattice
using ..Helpers

include("ParallelMCMCSampler.jl")

end