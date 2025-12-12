using DataFrames

# Export Observable to DataFrame

# Helper function
function split_complex_matrix(input_matrix)
    if eltype(input_matrix) <: Complex
        _, m = size(input_matrix)
        split_array = hcat(real(input_matrix), imag(input_matrix))
        df = DataFrame(split_array, :auto)
        colnames = vcat([Symbol("xre$i") for i in 1:m], [Symbol("xim$i") for i in 1:m])
        rename!(df, colnames)
        return df
    else
        # For Float32/64 matrix, standard processing
        return DataFrame(input_matrix, :auto)
    end
end

# Implementation
dataframe(o::Observables.SimulationObservable) = error("dataframe not implemented for $(typeof(o))")
dataframe(o::Observables.SimulationObservableScalar) = split_complex_matrix(value(o))