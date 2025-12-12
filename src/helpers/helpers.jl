module Helpers

"""
    flatten_batch(A; keep=2)

Reshape an array `A` by flattening all dimensions after the `keep`-th dimension into a single dimension.
"""
flatten_batch(A; keep=2) = reshape(A, size(A)[1:keep-1]..., prod(size(A)[keep:end]))

"""
    condense_namedtuples_into_dict(vector::AbstractVector, names::Tuple)

Condense a vector of named tuples into a dictionary of arrays, where each key corresponds to a field in the named tuples and each value is an array containing the concatenated values of that field across all named tuples.
# Examples
```jldoctest
julia> data = [(a=ones(2), b=ones(3)*2) for _ in 1:5];

julia> result = UltraFast.Helpers.condense_namedtuples_into_dict(data)
Dict{Symbol, Any} with 2 entries:
  :a => [1.0 1.0 … 1.0 1.0; 1.0 1.0 … 1.0 1.0]
  :b => [2.0 2.0 … 2.0 2.0; 2.0 2.0 … 2.0 2.0; 2.0 2.0 … 2.0 2.0]
```

"""
function condense_namedtuples_into_dict(vector::AbstractVector; names::Tuple = keys(vector[1]))
    for item in vector
        for name in names
            haskey(item, name) || throw(ArgumentError("Missing key $name in named tuple"))
        end
    end

    storage_cat = Dict{Symbol, Any}()
    
    for name in names
        # Collect all values for the current name
        values = [item[name] for item in vector]
        
        # Concatenate the values along extra dimension
        storage_cat[name] = cat(values...; dims=ndims(values[1])+1)
    end

    return storage_cat
end

include("random_spin_state_generator.jl")
export random_spin_state, flatten_batch, condense_namedtuples_into_dict

end