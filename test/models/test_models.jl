function latticesetup(Lx::Int, Ly::Int)
    lattice = UltraFast.LatticeConfig(Lx, Ly)
    samplingConfig = UltraFast.SetupMonteCarloSampling(lattice; iterations = 30)
    return lattice, samplingConfig
end

function test_model(model::UltraFast.Models.Model, lattice::UltraFast.LatticeConfig)
    mag0 = true
    # Generate a spin state|
    state = UltraFast.GenRandomState2(mag0, lattice.nspins)

    # Run the model and see whether it doesn't crash
    UltraFast.Models.wavefunction_value(model, state)
end

@testset "quantum vision transformer" begin
    include("test_quantum_vision_transformer.jl")
end

# @testset "optimized_RBM" begin
#     include("test_optimized_RBM.jl")
# end

@testset "standard_RBM" begin
    include("test_standard_RBM.jl")
end

