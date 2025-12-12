Base.@kwdef struct MHSampler <: AbstractMCMCSampler
    # settings
    settings::MCMCSettings
end

# Very simple internal object which keeps information about the current state
Base.@kwdef mutable struct MCState{T <: Number}
    # statistics
    n_flips::Int
    n_accepted::Int

    # state description
    currentlog::T
    currentstate::Vector{Int} # spin vector [-1, 1, 1, -1, ...]

    # output
    const logwavefunctions::Vector{T} # log of wavefunctions after each sweep
    const states::Matrix{Int} # states after each sweep
end

function MCState(initial_state::Vector{Int}, currentlog::T, nsamples::Int, nspins::Int) where T
    return MCState(
        0,
        0,
        currentlog,
        copy(initial_state),
        zeros(T, nsamples),
        zeros(Int, nspins, nsamples)
    )
end

function sample(sampler::MHSampler, 
                model::Model;
                initial_state::Vector{Int} = random_spin_state(nspins(model), true),
                nsamples::Int = sampler.settings.nsamples,
                nthermalization::Int = sampler.settings.nthermalization,
                sweep::Int = sampler.settings.sweep,
                callback::Function = (phase, step, total) -> nothing)
    # set the state
    new_state!(model, initial_state)

    # find the first wavefunction value
    currentlog = wavefunction_value(model, initial_state)

    # create the state object
    state = MCState(initial_state, currentlog, nsamples, nspins(model))

    # create final mc settings if user decided to change them
    mcsettings = MCMCSettings(nthermalization=nthermalization, nsamples=nsamples, sweep=sweep)

    # run the sampling
    runtime = @elapsed state = mc_sampling!(state, sampler, model, mcsettings, callback)

    return (states=state.states, 
            logwavefunctions=state.logwavefunctions,
            metadata=(
                n_accepted=state.n_accepted, 
                n_flips=state.n_flips, 
                n_chains=1, 
                runtime=runtime)
            )
end

# MC sampler
function mc_sampling!(state::MCState{T},
                      sampler::MHSampler,
                      model::Model{T},
                      mcsettings::MCMCSettings,
                      callback::Function = (phase, step, total) -> nothing) where T

    # thermalization
    @inbounds for n = 1:mcsettings.nthermalization
        # run one sweep
        @inbounds for _ = 1:mcsettings.sweep
            # make a flip
            state = flip!(state, sampler, model)
        end

        # report progress
        callback(:thermalization, n, mcsettings.nthermalization)
    end

    # sequence of sweeps to calculate energy and gradient of wavefunction
    @inbounds for n = 1:mcsettings.nsamples
        # run one sweep
        @inbounds for _ = 1:mcsettings.sweep
            # make a flip
            state = flip!(state, sampler, model)
        end

        # save the state
        state.logwavefunctions[n] = state.currentlog
        state.states[:, n] .= state.currentstate

        # report progress
        callback(:sampling, n, mcsettings.nsamples)
    end

    return state
end

include("MHSamplers+flip.jl")
include("MHSamplers+io.jl")