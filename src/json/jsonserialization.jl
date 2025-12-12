import Optimisers: AbstractRule
import ..Models: Model, identifier, settings
using ..Lattice: LatticeConfig, LatticeSettings
using ..Systems: Heisenberg
using ..Samplers: Gradients

struct UltraFastSettings
    experiment::String
    lattice::LatticeConfig
    model::Model
    optimiser::AbstractRule
    system::Heisenberg
    optimization::GroundStateOptimizationHyperParameters
    observables::NamedTuple
    gradientfunction::Gradients
end

# Function to write SimulationData to a JSON file
function jsonsettings(filename, settingsstore::UltraFastSettings, date::Dates.DateTime; elapsed = nothing, seed = nothing)
    extra = Dict()

    if !isnothing(elapsed)
        extra["elapsed"] = elapsed
    end

    if !isnothing(seed)
        extra["seed"] = seed
    end

    json_data = Dict(
        "experiment" => settingsstore.experiment,
        "version" => "1.1.0",
        "sampling_size" => settingsstore.optimization.samples,
        "niterations" => settingsstore.optimization.iterations,
        #"precision" => ComplexType,
        "model" => Dict(
            "type" => identifier(settingsstore.model),
            "settings" => settings(settingsstore.model)
        ),
        "optimiser" => Dict(
            "type" => typeof(settingsstore.optimiser),
            "settings" => settingsstore.optimiser
        ),
        "system" => Dict(
            "type" => "Heisenberg",
            "settings" => Dict(
                "Jx" => settingsstore.system.J_x,
                "Jy" => settingsstore.system.J_y,
                "Lx" => settingsstore.lattice.settings.Lx,
                "Ly" => settingsstore.lattice.settings.Ly,
                "nspins" => settingsstore.lattice.settings.nspins
            )
        ),
        "optimization" => Dict(
            "type" => "metropolis",
            "settings" => Dict(
                "thermalizationsweeps" => settingsstore.optimization.thermalizationsweeps,
                "sweep" => settingsstore.optimization.sweep,
                "samples" => settingsstore.optimization.samples,
                "niterations" => settingsstore.optimization.iterations
            )
        ),
        "observables" => settingsstore.observables,
        "gradientfunction" => Dict(
            "type" => typeof(settingsstore.gradientfunction),
            "settings" => settingsstore.gradientfunction
        ),
        "extra" => extra,
        "metadata" => Dict(
            "date" => Dates.format(date, "yyyymmdd-HH:MM:SS"),
            "system" => Dict(
                "ARCH" => Sys.ARCH,
                "OS" => Sys.KERNEL,
                "Julia" => VERSION,
                "CPU" => Sys.CPU_NAME,
                "threads" => Sys.CPU_THREADS,
                "MACHINE" => Sys.MACHINE
            )
        )
    )

    open(filename, "w") do io
        JSON.print(io, json_data)
    end
end