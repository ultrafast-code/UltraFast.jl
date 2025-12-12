using JSON
using Dates

JSON.lower(gs::GroundStateOptimisation) = Dict(
    "niterations" => gs.niterations,
    "optimiser" => gs.optimiser,
    "gradient" => gs.gradient,
    "sampler" => Samplers.settings(gs.sampler)
)

hyperparameters(gs::GroundStateOptimisation) = Dict(
    "optimiser" => gs.optimiser,
    "gradient" => gs.gradient,
    "sampler" => Samplers.settings(gs.sampler)
)

settings(gs::GroundStateOptimisation) = JSON.parse(JSON.json(gs))

const dmrg_gs_1d_chain = Dict(
    4 => -0.49999999999999994,
    6 => -0.46712927295533185,
    8 => -0.4563866761171469,
    10 => -0.4515446354492038,
    12 => -0.44894924312043477,
    14 => -0.447396395253359,
    16 => -0.4463935225385468,
    24 => -0.44458393818904723,
    32 => -0.4439539824652493,
    40 => -0.4436630696679645,
    64 => -0.4433484568665842,
    100 => -0.4432295
)

function GroundStateOptimisation(settings::Dict; model, hamiltonian, sampler, optimiser, gradient, callback=nothing)
    niterations = get(settings, "niterations", 300)
    return GroundStateOptimisation(optimiser, niterations, sampler, gradient, callback)
end