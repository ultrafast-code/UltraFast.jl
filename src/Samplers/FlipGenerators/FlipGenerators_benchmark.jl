include("FlipGenerator.jl")
include("../../helpers/random_spin_state_generator.jl")
using BenchmarkTools

state = random_spin_state(100, true)

println("antiferromagnetic_flip")
@benchmark antiferromagnetic_flip($state)

println("antiferromagnetic_flip_original")
@benchmark antiferromagnetic_flip_original($state)

print("rejection_free_antiferromagnetic_flip")
@benchmark rejection_free_antiferromagnetic_flip($state)

println("rejection_free_antiferromagnetic_flip_v2")
@benchmark rejection_free_antiferromagnetic_flip_v2($state)

println("rejection_free_ferromagnetic_flip")
@benchmark rejection_free_ferromagnetic_flip($state)

