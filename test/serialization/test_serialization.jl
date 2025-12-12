using Test
using JSON3
using UltraFast

@testset "Serialization Tests" begin
    
    @testset "IOConstructor Basic Functionality" begin
        io_constructor = UltraFast.IOConstructor()
        
        @test io_constructor.fileversion == "2.0"
        @test haskey(io_constructor.lookup, :lattice)
        @test haskey(io_constructor.lookup, :model)
        @test haskey(io_constructor.lookup, :hamiltonian)
        @test haskey(io_constructor.lookup, :sampler)
        @test haskey(io_constructor.lookup, :gradient)
        @test haskey(io_constructor.lookup, :optimiser)
        
        # Test extend! function
        test_constructor = (settings; ioconstructor=UltraFast.IOConstructor()) -> "test_object"
        UltraFast.extend!(io_constructor, :test_category, "TestType", test_constructor)
        
        @test haskey(io_constructor.lookup, :test_category)
        @test haskey(io_constructor.lookup[:test_category], "TestType")
        
        # Test that extending existing constructor throws error
        @test_throws ErrorException UltraFast.extend!(io_constructor, :test_category, "TestType", test_constructor)
    end
    
    @testset "Individual Constructor Tests - Part 1: Manual Dictionaries" begin
        
        @testset "construct_lattice" begin
            lattice_config = Dict(
                "version" => Dict("fileversion" => "2.0"),
                "lattice" => Dict(
                    "type" => "Default",
                    "Lx" => 4,
                    "Ly" => 4
                )
            )
            
            lattice = UltraFast.construct_lattice(lattice_config)
            @test lattice isa UltraFast.LatticeConfig
            @test lattice.nspins == 16
            @test lattice.settings.Lx == 4
            @test lattice.settings.Ly == 4
        end
        
        @testset "construct_model" begin
            model_config = Dict(
                "version" => Dict("fileversion" => "2.0"),
                "model" => Dict(
                    "type" => "FastTranslationInvariantRBM",
                    "alpha" => 2,
                    "weight_initializer" => "real_default_uniform"
                )
            )
            
            lattice = UltraFast.LatticeConfig(Lx=4, Ly=4)
            model = UltraFast.construct_model(model_config; lattice=lattice)
            
            @test model isa UltraFast.SymmetryRBM.FastTranslationInvariantRBM
            @test UltraFast.Models.nspins(model) == 16
        end
        
        @testset "construct_hamiltonian" begin
            hamiltonian_config = Dict(
                "version" => Dict("fileversion" => "2.0"),
                "hamiltonian" => Dict(
                    "type" => "Heisenberg",
                    "J_x" => 1.0,
                    "J_y" => 1.0
                )
            )
            
            lattice = UltraFast.LatticeConfig(Lx=4, Ly=4)
            hamiltonian = UltraFast.construct_hamiltonian(hamiltonian_config; lattice=lattice)
            
            @test hamiltonian isa UltraFast.Hamiltonians.Heisenberg
        end
        
        @testset "construct_sampler - MHSampler" begin
            sampler_config = Dict(
                "version" => Dict("fileversion" => "2.0"),
                "sampler" => Dict(
                    "type" => "MHSampler",
                    "nthermalization" => 200,
                    "nsamples" => 2000,
                    "sweep" => 16
                )
            )
            
            sampler = UltraFast.construct_sampler(sampler_config)
            @test sampler isa UltraFast.Samplers.MHSampler
            @test sampler.settings.nthermalization == 200
            @test sampler.settings.nsamples == 2000
            @test sampler.settings.sweep == 16
        end
        
        @testset "construct_sampler - ParallelMCMCSampler" begin
            parallel_sampler_config = Dict(
                "version" => Dict("fileversion" => "2.0"),
                "sampler" => Dict(
                    "type" => "ParallelMCMCSampler",
                    "sweep" => 16,
                    "nthermalization" => 200,
                    "nsamples" => 2000,
                    "n_chains" => 4,
                    "sampler" => Dict(
                        "type" => "MHSampler",
                        "sweep" => 16
                    )
                )
            )
            
            sampler = UltraFast.construct_sampler(parallel_sampler_config)
            @test sampler isa UltraFast.MultiProcessing.ParallelMCMCSampler
            @test sampler.n_chains == 4
            @test sampler.sampler isa UltraFast.Samplers.MHSampler
        end
        
        @testset "construct_gradient" begin
            @testset "StochasticReconfiguration" begin
                gradient_config = Dict(
                    "version" => Dict("fileversion" => "2.0"),
                    "gradient" => Dict(
                        "type" => "StochasticReconfiguration",
                        "max_epsilon" => 0.0001,
                        "falloff_rate" => 0.90,
                        "initial_falloff_rate" => 100
                    )
                )
                
                gradient = UltraFast.construct_gradient(gradient_config)
                @test gradient isa UltraFast.Optimisation.SmatrixGradient
            end
            
            @testset "Plain" begin
                gradient_config = Dict(
                    "version" => Dict("fileversion" => "2.0"),
                    "gradient" => Dict(
                        "type" => "Plain"
                    )
                )
                
                gradient = UltraFast.construct_gradient(gradient_config)
                @test gradient isa UltraFast.Optimisation.PlainDescent
            end
            
        end
        
       
        
        @testset "construct_gs_optimiser" begin
            gs_config = Dict(
                "version" => Dict("fileversion" => "2.0"),
                "gradient" => Dict(
                    "type" => "StochasticReconfiguration",
                    "max_epsilon" => 0.0001,
                    "falloff_rate" => 0.90,
                    "initial_falloff_rate" => 100
                ),
                "optimiser" => Dict(
                    "type" => "GradientDescent",
                    "learning_rate" => 0.005
                ),
                "groundstateoptimiser" => Dict(
                    "type" => "DefaultGroundState",
                    "niterations" => 500
                )
            )
            
            # Create required objects
            lattice = UltraFast.LatticeConfig(Lx=4, Ly=4)
            model = UltraFast.SymmetryRBM.FastTranslationInvariantRBM(lattice, 2)
            hamiltonian = UltraFast.Hamiltonians.Heisenberg(lattice=lattice)
            sampler = UltraFast.Samplers.MHSampler(UltraFast.MCMCSettings(sweep=lattice.nspins, nsamples=1000, nthermalization=200))
            
            gs_optimiser = UltraFast.construct_gs_optimiser(gs_config; 
                                                          model=model, 
                                                          hamiltonian=hamiltonian, 
                                                          sampler=sampler)
            
            # @test gs_optimiser isa UltraFast.Optimisation.GroundStateOptimisation
        end
        
        @testset "construct_gs_optimiser_convenience" begin
            convenience_config = Dict(
                "version" => Dict("fileversion" => "2.0"),
                "lattice" => Dict(
                    "type" => "Default",
                    "Lx" => 4,
                    "Ly" => 4
                ),
                "model" => Dict(
                    "type" => "FastTranslationInvariantRBM",
                    "alpha" => 2,
                    "weight_initializer" => "real_default_uniform"
                ),
                "hamiltonian" => Dict(
                    "type" => "Heisenberg",
                    "J_x" => 1.0,
                    "J_y" => 1.0
                ),
                "sampler" => Dict(
                    "type" => "MHSampler",
                    "nthermalization" => 200,
                    "nsamples" => 2000,
                    "sweep" => 16
                ),
                "gradient" => Dict(
                    "type" => "StochasticReconfiguration",
                    "max_epsilon" => 0.0001,
                    "falloff_rate" => 0.90,
                    "initial_falloff_rate" => 100
                ),
                "optimiser" => Dict(
                    "type" => "GradientDescent",
                    "learning_rate" => 0.005
                ),
                "groundstateoptimiser" => Dict(
                    "type" => "DefaultGroundState",
                    "niterations" => 500
                )
            )
            
            # gs_optimiser = UltraFast.construct_gs_optimiser_convenience(convenience_config)
            # @test gs_optimiser isa UltraFast.Optimisation.GroundStateOptimisation
        end
    end
    
    @testset "Error Handling" begin
        @testset "Version Mismatch" begin
            bad_version_config = Dict(
                "version" => Dict("fileversion" => "1.0"),  # Wrong version
                "lattice" => Dict(
                    "type" => "Default",
                    "Lx" => 4,
                    "Ly" => 4
                )
            )
            
            @test_throws ErrorException UltraFast.construct_lattice(bad_version_config)
        end
        
        @testset "Missing Version" begin
            no_version_config = Dict(
                "lattice" => Dict(
                    "type" => "Default",
                    "Lx" => 4,
                    "Ly" => 4
                )
            )
            
            @test_throws ErrorException UltraFast.construct_lattice(no_version_config)
        end
        
        @testset "Missing Category" begin
            missing_category_config = Dict(
                "version" => Dict("fileversion" => "2.0")
                # Missing "lattice" key
            )
            
            @test_throws ErrorException UltraFast.construct_lattice(missing_category_config)
        end
        
        @testset "Unknown Type" begin
            unknown_type_config = Dict(
                "version" => Dict("fileversion" => "2.0"),
                "lattice" => Dict(
                    "type" => "UnknownLatticeType",
                    "Lx" => 4,
                    "Ly" => 4
                )
            )
            
            @test_throws KeyError UltraFast.construct_lattice(unknown_type_config)
        end
    end
    
    @testset "JSON File Loading Tests - Part 2" begin
        
        @testset "config.json - ParallelMCMCSampler Configuration" begin
            config_path = joinpath(@__DIR__, "config.json")
            @test isfile(config_path)
            
            config = JSON3.read(read(config_path, String), Dict)

            println("Loaded configuration: ", config)
            
            # Test individual components
            lattice = UltraFast.construct_lattice(config)
            @test lattice isa UltraFast.LatticeConfig
            @test lattice.nspins == 16
            
            model = UltraFast.construct_model(config; lattice=lattice)
            @test model isa UltraFast.SymmetryRBM.FastTranslationInvariantRBM
            
            hamiltonian = UltraFast.construct_hamiltonian(config; lattice=lattice)
            @test hamiltonian isa UltraFast.Hamiltonians.Heisenberg
            
            sampler = UltraFast.construct_sampler(config)
            @test sampler isa UltraFast.MultiProcessing.ParallelMCMCSampler
            @test sampler.n_chains == 10
            @test sampler.sampler isa UltraFast.Samplers.MHSampler
            
            gradient = UltraFast.construct_gradient(config)
            @test gradient isa UltraFast.Optimisation.SmatrixGradient
            
            # Test full convenience constructor
            gs_optimiser = UltraFast.construct_gs_optimiser_convenience(config)
            @test gs_optimiser isa UltraFast.Optimisation.GroundStateOptimisation
        end
        
        @testset "config_parallel.json - MHSampler Configuration" begin
            config_path = joinpath(@__DIR__, "config_parallel.json")
            @test isfile(config_path)
            
            config = JSON3.read(read(config_path, String), Dict)
            
            # Test individual components
            lattice = UltraFast.construct_lattice(config)
            @test lattice isa UltraFast.LatticeConfig
            @test lattice.nspins == 16
            
            model = UltraFast.construct_model(config; lattice=lattice)
            @test model isa UltraFast.SymmetryRBM.FastTranslationInvariantRBM
            
            hamiltonian = UltraFast.construct_hamiltonian(config; lattice=lattice)
            @test hamiltonian isa UltraFast.Hamiltonians.Heisenberg
            
            sampler = UltraFast.construct_sampler(config)
            @test sampler isa UltraFast.Samplers.MHSampler
            @test sampler.settings.nthermalization == 200
            @test sampler.settings.nsamples == 2000
            @test sampler.settings.sweep == 16
            
            gradient = UltraFast.construct_gradient(config)
            @test gradient isa UltraFast.Optimisation.SmatrixGradient
            
            # optimiser = UltraFast.construct_optimiser(config)
            # @test optimiser isa UltraFast.GradientDescent
            
            # Test full convenience constructor
            # gs_optimiser = UltraFast.construct_gs_optimiser_convenience(config)
            # @test gs_optimiser isa UltraFast.Optimisation.GroundStateOptimisation
        end
    end
    
    @testset "IOConstructor Extensibility" begin
        io_constructor = UltraFast.IOConstructor()
        
        # Add a custom sampler constructor
        custom_sampler_constructor = (settings; ioconstructor=UltraFast.IOConstructor()) -> begin
            # Mock custom sampler (would be a real implementation)
            return "CustomSampler with settings: $(settings)"
        end
        
        UltraFast.extend!(io_constructor, :sampler, "CustomSampler", custom_sampler_constructor)
        
        # Test that the custom constructor works
        custom_config = Dict(
            "version" => Dict("fileversion" => "2.0"),
            "sampler" => Dict(
                "type" => "CustomSampler",
                "custom_param" => "test_value"
            )
        )
        
        result = UltraFast.construct_object(:sampler, custom_config, io_constructor)
        @test result isa String
        @test occursin("CustomSampler", result)
        @test occursin("test_value", result)
    end
end