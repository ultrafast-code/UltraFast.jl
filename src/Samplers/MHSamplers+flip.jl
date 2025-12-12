include("FlipGenerators/FlipGenerator.jl")

function flip!(state::MCState, sampler::MHSampler, model::Model)
    accept, flips = antiferromagnetic_flip_original(state.currentstate)

    state.n_flips += 1

    # reject based on flip
    if !accept
        return state
    end

    # calculate the new wavefunction
    newstatelog = wavefunction_value(model, state.currentstate, flips)

    # calculate the acceptance probability
    acceptanceprobability = abs2(exp(newstatelog - state.currentlog))

    # reject based on acceptance probability
    if !(acceptanceprobability > rand())
        # rejected
        return state
    end

    # update the currentlog
    state.currentlog = newstatelog
    
    # accepted
    state.n_accepted += 1
    handle_state_update!(model, state.currentstate, flips)

    # update the state
    for i = 1:2
        state.currentstate[flips[i]] *= -1
    end

    return state
end