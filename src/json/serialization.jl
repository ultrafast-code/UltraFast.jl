module Serialization

import JSON, Dates
using ..Observables
import ..Observables: value
import ..Samplers: GroundStateOptimizationHyperParameters

# # TODO remove remove
# struct GroundStateOptimizationHyperParameters
#     samples::Int64
#     iterations::Int64
#     sweep::Int64
#     thermalizationsweeps::Int64
# end

include("Observables+json.jl")

include("Observables+DataFrame.jl")

include("jsonserialization.jl")

include("UltraFastIO.jl")

function metadata()
    Dict(
        "ARCH" => Sys.ARCH,
        "OS" => Sys.KERNEL,
        "Julia" => VERSION,
        "CPU" => Sys.CPU_NAME,
        "threads" => Sys.CPU_THREADS,
        "MACHINE" => Sys.MACHINE
    )
end

end