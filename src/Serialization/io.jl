# extra io for external package called (Optimisers)
include("optimisers+io.jl")

"""
    struct IOConstructor

A struct representing an IO constructor.

# Fields
- `lookup::Dict{String, Dict{String, Function}}`: A dictionary that maps strings to dictionaries of strings and functions. The first level describes the top level abstract type, and the second level corresponds to the name of the object and the constructor function.

"""
struct IOConstructor
    lookup::Dict{Symbol,Dict{String,Function}}
    fileversion::String
end

function IOConstructor()
    return IOConstructor(Dict(
        :lattice => Dict(
            "Default" => (settings; ioconstructor=IOConstructor()) -> LatticeConfig(settings)
        ),
        :model => Dict(
            "FastTranslationInvariantRBM" => (settings; ioconstructor=IOConstructor(), lattice) -> SymmetryRBM.FastTranslationInvariantRBM(settings; lattice=lattice),
            "TranslationInvariantRBM" => (settings; ioconstructor=IOConstructor(), lattice) -> SymmetryRBM.TranslationInvariantRBM(settings; lattice=lattice),
            "RBM" => (settings; ioconstructor=IOConstructor(), lattice) -> Models.RBM(settings; lattice=lattice)
        ),
        :hamiltonian => Dict(
            "Heisenberg" => (settings; ioconstructor=IOConstructor(), lattice) -> Hamiltonians.Heisenberg(settings; lattice=lattice)
        ),
        :sampler => Dict(
           "MHSampler" => (settings; ioconstructor=IOConstructor()) -> MHSampler(settings;),
           "ParallelMCMCSampler" => (settings; ioconstructor=IOConstructor()) -> begin
               sampler_settings = Dict("sampler" => settings["sampler"])
               ParallelMCMCSampler(settings; sampler=construct_object(:sampler, sampler_settings, ioconstructor; ignore_version=true))
           end
        ),
        :gradient => Dict(
            "StochasticReconfiguration" => (settings; ioconstructor=IOConstructor()) -> Optimisation.SmatrixGradient(settings),#Gradients.Smatrix(settings),
            "Plain" => (settings; ioconstructor=IOConstructor()) -> Optimisation.PlainDescent(), #Gradients.Plain(settings)
            "StochasticReconfigurationDeltaRegulariser" => (settings; ioconstructor=IOConstructor()) -> Optimisation.SmatrixGradientDeltaReg(settings)
        ),
        :optimiser => Dict(
            "GradientDescent" => (settings; ioconstructor=IOConstructor()) -> GradientDescent(settings),
        ),
        :groundstateoptimiser => Dict(
            "DefaultGroundState" => (settings; ioconstructor=IOConstructor(), model, hamiltonian, sampler, optimiser, gradient, callback) -> Optimisation.GroundStateOptimisation(settings; model=model, hamiltonian=hamiltonian, sampler=sampler, optimiser=optimiser, gradient=gradient, callback=callback)
        ),
        :evaluation => Dict(
            "Default" => (settings; ioconstructor=IOConstructor(), model, hamiltonian) -> evaluate(settings; model=model, hamiltonian=hamiltonian)
        )
    )
    , "2.0")
end


"""
    extend(ioconstructor::IOConstructor, category::Symbol, name::String, constructor::Function)

Extend the `ioconstructor` by adding a new constructor function for a given category and name.

# Arguments
- `ioconstructor::IOConstructor`: The IOConstructor object to extend.
- `category::Symbol`: The category of the constructor.
- `name::String`: The name of the constructor.
- `constructor::Function`: The constructor function to add.

"""
function extend!(ioconstructor::IOConstructor, category::Symbol, name::String, constructor::Function)
    if haskey(ioconstructor.lookup, category)
        if haskey(ioconstructor.lookup[category], name)
            error("Constructor for $category $name already exists.")
        else
            ioconstructor.lookup[category][name] = constructor
        end
    else
        ioconstructor.lookup[category] = Dict(name => constructor)
    end

    return ioconstructor
end

function flatten_json(json_obj; prefix="")
    flat_dict = Dict{String, Any}()
    
    for (key, value) in json_obj
        if isa(value, Dict)
            # If the current key is "settings", do not include it in the prefix
            new_prefix = (key == "settings") ? prefix : prefix * key * "."
            # Recursively flatten the dictionary
            nested_dict = flatten_json(value; prefix=new_prefix)
            for (nested_key, nested_value) in nested_dict
                flat_dict[nested_key] = nested_value
            end
        else
            # Add the key-value pair to the flattened dictionary
            flat_dict[prefix * key] = value
        end
    end
    
    return flat_dict
end

function unflatten_json(flat_dict)
    special_keys = ["fileversion", "type"]
    nested_dict = Dict{String, Any}()

    for (key, value) in flat_dict
        parts = split(key, ".")
        current_dict = nested_dict

        for (i, part) in enumerate(parts)
            if i == length(parts)
                current_dict[part] = value
            else
                if !haskey(current_dict, part)
                    current_dict[part] = Dict{String, Any}()
                end
                current_dict = current_dict[part]
            end
        end
    end

    return nested_dict
end


function construct_object(category::Symbol, config::Dict, constructors::IOConstructor; ignore_version=false, extra_args...)
    # check for version number
    if haskey(config, "version") && !ignore_version
        version = config["version"]["fileversion"]
        if version != constructors.fileversion
            error("Version mismatch: $version != $(constructors.fileversion)")
        end
    elseif !ignore_version
        error("Version number not found in configuration.")
    else end

    if haskey(config, string(category))
        type_and_settings = config[string(category)]
        object_type = type_and_settings["type"]

        constructor = constructors.lookup[category][object_type]

        return constructor(type_and_settings; ioconstructor=constructors, extra_args...)
    else
        error("Category $category not found in configuration.")
    end
end

function construct_lattice(config::Dict, constructors::IOConstructor=IOConstructor())
    return construct_object(:lattice, config, constructors)
end

function construct_model(config::Dict, constructors::IOConstructor=IOConstructor(); lattice)
    return construct_object(:model, config, constructors; lattice=lattice)
end

function construct_hamiltonian(config::Dict, constructors::IOConstructor=IOConstructor(); lattice)
    return construct_object(:hamiltonian, config, constructors; lattice=lattice)
end

function construct_sampler(config::Dict, constructors::IOConstructor=IOConstructor())
    return construct_object(:sampler, config, constructors)
end

function construct_gradient(config::Dict, constructors::IOConstructor=IOConstructor())
    return construct_object(:gradient, config, constructors)
end

function construct_optimiser(config::Dict, constructors::IOConstructor=IOConstructor())
    return construct_object(:optimiser, config, constructors)
end

function construct_gs_optimiser(config::Dict, constructors::IOConstructor=IOConstructor(); model, hamiltonian, sampler, callback=nothing)
    gradient = construct_gradient(config, constructors)
    optimiser = construct_optimiser(config, constructors)
    
    return construct_object(:groundstateoptimiser, config, constructors; model=model, hamiltonian=hamiltonian, sampler=sampler, gradient=gradient, optimiser=optimiser, callback=callback)
end

function construct_gs_optimiser_convenience(config::Dict, constructors::IOConstructor=IOConstructor(); callback=nothing)
    lattice=construct_lattice(config, constructors)

    model = construct_model(config, constructors; lattice=lattice)
    hamiltonian = construct_hamiltonian(config, constructors; lattice=lattice)

    sampler = construct_sampler(config, constructors)

    return construct_gs_optimiser(config, constructors; model=model, hamiltonian=hamiltonian, sampler=sampler, callback=callback)
end

function construct_evaluation(config::Dict, constructors::IOConstructor=IOConstructor(); model)
    lattice = construct_lattice(config, constructors)
    hamiltonian = construct_hamiltonian(config, constructors; lattice=lattice)
    return construct_object(:evaluation, config, constructors; model=model, hamiltonian=hamiltonian)
end

export IOConstructor
