mutable struct ComplexDenseNetwork <: ComplexFluxModel
    model
    restructure::Optimisers.Restructure
end

# implementation of the Model abstract type
number_of_parameters(m::ComplexDenseNetwork) = get_number_of_parameters(m.model)
params_description(m::ComplexDenseNetwork) = println("nparams = $(number_of_parameters(m)) - DenseNetwork")

function ComplexDenseNetwork(nspins::Int, alpha::Int)
    # calculate the number of hidden units
    hidden = nspins * alpha

    # define the model
    model = Chain(Dense(nspins => hidden, init = complex_glorot_uniform), 
                  Dense(hidden => 1),
                  x -> prod(log.(x)))

    _, re = Flux.destructure(model)

    ComplexDenseNetwork(model, re)
end

settings(m::ComplexDenseNetwork) = Dict("type" => "Dense", "model" => m.model)
