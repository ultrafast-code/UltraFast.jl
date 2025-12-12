
@testset "Easy GS optimization" begin
    json_str = """
    {
        "version": {
            "fileversion": "1.0"
        },
        "lattice": {
            "type": "Default",
            "Lx": 8,
            "Ly": 8
        },
        "hamiltonian": {
            "type": "Heisenberg",
            "J_x": 1.0,
            "J_y": 1.0
        },
        "model": {
            "type": "DefaultRBM",
            "alpha": 4,
            "weight_initializer": "real_default_uniform"
        },
        "sampler": {
            "type": "MultiProcessingMHSampler",
            "nthermalization": 200,
            "nsamples": 2000,
            "nprocesses": 1
        },
        "gradient": {
            "type": "StochasticReconfiguration",
            "max_epsilon" : 0.0001,
            "falloff_rate": 0.9,
            "initial_falloff_rate": 200
        },
        "optimiser": {
            "type": "GradientDescent",
            "learning_rate": 0.005
        },
        "groundstateoptimiser": {
            "type": "DefaultGroundState",
            "niterations": 50
        }
    }
    """

    # Parse the JSON string into a dictionary
    config = JSON.parse(json_str)

    gs = UltraFast.construct_gs_optimiser_convenience(config)

    time_spent = @elapsed UltraFast.Optimisation.optimize!(gs)

    display(gs.energies)

    println("Time spent: ", time_spent)

    display(gs.elapsed_time_sampling)
    display(gs.elapsed_time_gradient)
    
    display(gs.ψ)

    println("Time spent in total ", sum(gs.elapsed_time_sampling)  + sum(gs.elapsed_time_gradient))
    

end