#!/usr/bin/env julia

"""
Demo script showing what error messages developers see when implementing Model interface.

This demonstrates the user experience when someone creates a custom model type
but forgets to implement required methods.
"""

using Pkg
Pkg.activate(".")
push!(LOAD_PATH, "./src")

using UltraFast.Models

println("🔧 Model Interface Error Handling Demo")
println("=====================================")
println()

# Create a custom model type (but don't implement required methods)
struct MyCustomQuantumModel{T} <: Model{T}
    lattice_size::Int
    complexity_parameter::T
end

# Create an instance
my_model = MyCustomQuantumModel(16, 2.5)
println("✨ Created custom model: MyCustomQuantumModel{Float64}(lattice_size=16, complexity_parameter=2.5)")
println()

# Try to use methods that haven't been implemented yet
methods_to_test = [
    ("number_of_parameters", () -> number_of_parameters(my_model)),
    ("nspins", () -> nspins(my_model)),
    ("wavefunction_value", () -> wavefunction_value(my_model, [1, -1, 1, -1])),
]

for (name, func) in methods_to_test
    println("🚫 Trying to call $name...")
    try
        func()
    catch e
        # Show the helpful error message
        println("   ERROR: $(e.msg)")
        println()
    end
end

println("✅ Methods with default implementations:")

# Test methods that should work by default
println("   • identifier(my_model) = \"$(identifier(my_model))\"")
println("   • handle_state_update!(my_model, state, flips) = $(handle_state_update!(my_model, [1, -1], [1]))")
println("   • new_state!(my_model, state) = $(new_state!(my_model, [1, -1]))")

println()
println("💡 The error messages clearly tell developers:")
println("   1. Which method needs to be implemented")
println("   2. The exact type name involved")
println("   3. Template code showing how to implement it")
println("   4. This guides developers to write correct implementations!")