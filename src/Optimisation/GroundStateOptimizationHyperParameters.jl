"""
    struct GroundStateOptimizationHyperParameters

A structure type containing hyperparameters for ground state optimization.

Fields:
- `samples::Int64`: The number of Monte Carlo samples.
- `iterations::Int64`: The number of iteration steps.
- `sweep::Int64`: The number of flips per sweep. After one sweep the configuration is considered independent.
- `thermalizationsweeps::Int64`: The number of thermalization sweeps expressed as
  a multiple of the sweeps
"""
Base.@kwdef struct GroundStateOptimizationHyperParameters
  sweep::Int64
  samples::Int64 = 2000
  iterations::Int64 = 300
  thermalizationsweeps::Int64 = 200
end
