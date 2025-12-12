using Random
using StaticArrays

function antiferromagnetic_flip(state::Array{Int, 1})
    nspins = size(state)[1]
    flips = randperm(nspins)[1:2]
    return state[flips[2]] !== state[flips[1]], flips
end

function antiferromagnetic_flip_original(state::Array{Int, 1})
    nspins = size(state)[1]
    flips = rand(1:nspins, 2)
    return state[flips[2]] !== state[flips[1]], flips
end

function rejection_free_antiferromagnetic_flip(state::Array{Int, 1})
    nspins = size(state)[1]

    flips = rand(1:Int(nspins/2), 2)
    #flip_indices = @MVector zeros(Int, 2)
    flip_indices = Array{Int, 1}(undef, 2)

    up_index = Int(0)
    down_index = Int(0)

    for (i, s) in enumerate(state)
        if s == 1
            up_index += 1
            if up_index == flips[1]
                flip_indices[1] = i
            end
        else
            down_index += 1
            if down_index == flips[2]
                flip_indices[2] = i
            end
        end
    end
    return true, flip_indices
end

function rejection_free_ferromagnetic_flip(state::Array{Int, 1})
    nspins = size(state)[1]

    flips = rand(1:Int(nspins), 1)

    return true, flips
end

"""
    generate_flip(state::AbstractArray{<:Integer, 2}, flip_generator::Function)

Generate flips and acceptance flags using a flip generator function.

# Arguments
- `state::AbstractArray{<:Integer, 2}`: The state array, or `state::AbstractArray{<:Integer, 1}`: The state array.
- `flip_generator::Function`: The flip generator function.

# Returns
- `accepts::Array{Bool, 1}`: An array of acceptance flags.
- `flips::Array{Int64, 2}`: An array of flips.

# Examples
```julia
nspins = 4
nparallel = 2

states = UltraFast.GenRandomStates(true, 4, 2)

accepts, flips = UltraFast.generate_flip(states, UltraFast.antiferromagnetic_flip_original)
```

"""
function generate_flip(state::Array{Int, 2}, flip_generator::Function)
    nparallel = size(state)[2]

    flips = Array{Int64, 2}(undef, 2, nparallel)
    accepts = Array{Bool, 1}(undef, nparallel)

    for i in 1:nparallel
        @views accept, flip = flip_generator(state[:, i])

        flips[:, i] .= flip
        accepts[i] = accept
    end
    return accepts, flips
end

generate_flip(state::Array{Int, 1}, flip_generator::Function) = flip_generator(state)