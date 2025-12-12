using LinearAlgebra
import Statistics
using Dagger

"""
    windowed_energy(energy, window_size, at)

Compute the mean energy within a window of a given size. The mean energy is computed as the average of [at - window_size, at].

# Arguments
- `energy`: An array of energy values.
- `window_size`: The size of the window.
- `at`: The index at which to compute the windowed energy.

# Returns
The mean energy within the specified window.

"""
function windowed_energy(energy, window_size, at)
    return Statistics.mean(energy[max(at-window_size, 1):at])
end

function optimize!(g::GroundStateOptimisation, model::Model{T}, hamiltonian::Hamiltonian) where {T}
    #@assert Samplers.supports_SR(g.sampler) "The sampler does not support the stochastic reconfiguration method."

    opt_state = Models.setup_optimiser(model, g.optimiser)

    output_data = NamedTuple( ( :energies => zeros(T, g.niterations), 
                                :stddevs => zeros(T, g.niterations), 
                                :elapsed_time_sampling => zeros(g.niterations), 
                                :elapsed_time_gradient => zeros(g.niterations), 
                                :norm_gradient => zeros(T, g.niterations),
                                :states => [],
                                :logwavefunctions => [],
                                :metadata => []))

    sr_obs = Observables.SRObservables()

    obs = (SR=sr_obs, )

    for i in 1:g.niterations
        #initial_state = random_spin_state(Models.nspins(model), true)

        # sample the configuration
        t_sampling = @elapsed states = sample(g.sampler, model)#Samplers.sample!(g.sampler)
        output_data.elapsed_time_sampling[i] = t_sampling

        # get the observables
        observables = Observables.observe(obs; states=states.states, logwavefunctions=states.logwavefunctions, model=model, hamiltonian=hamiltonian)

        push!(output_data.states, Int8.(states.states))
        push!(output_data.logwavefunctions, states.logwavefunctions)
        push!(output_data.metadata, states.metadata)

        # compute the gradient
        t_gradient = @elapsed pseudogradient = g.gradient(observables.SR.OkconjOkprime, 
                                                            observables.SR.Ok, 
                                                            observables.SR.ElocOkconj, 
                                                            observables.SR.Eloc, 
                                                            i)
        
        output_data.elapsed_time_gradient[i] = t_gradient   
        
        # compute the norm of the gradient
        output_data.norm_gradient[i] = norm(pseudogradient)
        
        # update the weights using the chosen optimiser
        opt_state = update_weights!(opt_state, model, pseudogradient)

        # save the energy and the standard deviation
        output_data.energies[i] = observables.SR.Eloc / (Hamiltonians.nspins(hamiltonian) * 4)
        output_data.stddevs[i] = observables.SR.StdEloc / (Hamiltonians.nspins(hamiltonian) * 4)

        if !isnothing(g.callback)
            g.callback(g, output_data, i; total_iterations=g.niterations)
        end
    end

    output_data = (
        energies = output_data.energies,
        stddevs = output_data.stddevs,
        elapsed_time_sampling = output_data.elapsed_time_sampling,
        elapsed_time_gradient = output_data.elapsed_time_gradient,
        norm_gradient = output_data.norm_gradient,
        states = cat(output_data.states..., dims=ndims(output_data.states[1])+1),
        logwavefunctions = cat(output_data.logwavefunctions..., dims=ndims(output_data.logwavefunctions[1])+1),
        metadata = condense_namedtuples_into_dict(output_data.metadata)
    )

    return output_data, model
end

