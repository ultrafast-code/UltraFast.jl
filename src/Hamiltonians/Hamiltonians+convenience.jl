
function random_state(H::Hamiltonian, nsamples::Int)
    states = Array{Int64, 2}(undef, nspins, nsamples)
    
    for i = 1:nsamples
        states[:, i] = GenRandomState(mag0, nspins)
    end

    return states
end