# Functions adapted from Giammarco Fabiani's https://github.com/ultrafast-code/ULTRAFAST
"""
    random_spin_state(nspins::Int, mag0::Bool)

Initializes a random spin state with `nspins` size.

# Arguments
- `nspins::Int`: The number of spins in the state.
- `mag0::Bool`: If `true`, the initial state is generated with zero total magnetization.

# Returns
- A random spin state with the specified number of spins and magnetization condition.
"""
function random_spin_state(nspins::Int, mag0::Bool)

    state_ = Int64[]

    for i = 1:nspins
        push!(state_, 2 * rand(0:1) - 1)
    end

    if mag0
        magt = 1
        if nspins % 2 == 1
            print("# Error : Cannot initializate a random state with zero magnetization for odd number of spins")
            error()
        end
        while magt != 0
            magt = 0
            for i = 1:nspins
                magt += state_[i]
            end
            if magt > 0
                rs = rand(1:nspins)
                while state_[rs] < 0
                    rs = rand(1:nspins)
                end
                state_[rs] = -1
                magt -= 1

            elseif magt < 0
                rs = rand(1:nspins)
                while state_[rs] > 0
                    rs = rand(1:nspins)
                end
                state_[rs] = 1
                magt += 1

            end
        end
    end
    return state_
end


"""
    random_spin_state(nspins::Int, mag0::Bool, nsamples::Int)

Generate multiple random spin state for a Heisenberg model.

# Arguments
- `nspins::Int`: The number of spins in the system.
- `mag0::Bool`: If `true`, the total magnetization is set to zero.
- `nsamples::Int`: The number of random samples to generate.

# Returns
- List of `nsamples` random spin states for the specified number of spins and samples.
"""
function random_spin_state(nspins::Int, mag0::Bool, nsamples::Int)
    states = Array{Int64, 2}(undef, nspins, nsamples)
    
    for i = 1:nsamples
        states[:, i] = random_spin_state(mag0, nspins)
    end

    return states
end