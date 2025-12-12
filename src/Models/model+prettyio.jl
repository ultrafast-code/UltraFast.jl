function Base.show(io::IO, m::Model)
    print(io, "Model: ")
    printstyled(io, identifier(m); color = :blue, bold = true)
    
    print(io, ", nspins: ")
    printstyled(io, nspins(m), color = :green, bold = true)
    
    print(io, ", hyperparameters: ")
    printstyled(io, hyperparameters(m), bold = true)

    print(io, ", n params: ")
    printstyled(io, number_of_parameters(m), color = :red, bold = true)

    println()

    #print(io, "description: ", params_description(m))
end