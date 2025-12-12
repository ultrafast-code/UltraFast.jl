#include("common_include.jl")
using DelimitedFiles
using Statistics
using BenchmarkTools
using Test
#using JET

#lattice =
lattice = UltraFast.Lattice.LatticeConfig(Lx=4, Ly=4)

model = UltraFast.SymmetryRBM.FastTranslationInvariantRBM(lattice, 2)

mc_settings = UltraFast.Samplers.MCMCSettings(
    sweep=lattice.nspins,
    nsamples=1000,
    nthermalization=200)

hamiltonian = UltraFast.Hamiltonians.Heisenberg(
    lattice=lattice,
    parallel=false)

gs = UltraFast.Optimisation.GroundStateOptimisation(hamiltonian,
    model;
    settings=mc_settings,
    niterations=300)

UltraFast.Optimisation.optimize!(gs)

mc_settings_2 = UltraFast.Samplers.MCMCSettings(
    sweep=lattice.nspins,
    nsamples=10000,
    nthermalization=200)

#Create energy observable
Energy = UltraFast.Observables.SamplingEnergyObservable{ComplexF64}(mc_settings_2.nsamples)

#Initiate dictionary which will become named tuple of operators
observables_dict = Dict{Symbol,Any}(Symbol("EnergyObs")=>Energy)

#Add all correlations to dictionary
for j in 1:lattice.nspins
    observables_dict[Symbol("correlation_1_"*string(j))] = UltraFast.Observables.SpinCorrelationObservable{ComplexF64}(mc_settings_2.nsamples,1,j,lattice)
end

#Convert to named tuple for use in sampling (safer w/ julia)
observables = NamedTuple(observables_dict)

#Collect observables into single SamplingObservables object
sObs = UltraFast.Samplers.SamplingObservables(model, hamiltonian, mc_settings; compute_SR=true, observables=observables)

sampler = UltraFast.Samplers.MHSampler(model, hamiltonian, mc_settings_2, sObs)

UltraFast.Samplers.sample!(sampler)

println(real(mean((UltraFast.Observables.value(observables[Symbol("EnergyObs")]))))/(4*lattice.nspins))
for j in 1:lattice.nspins
    println(real(mean(UltraFast.Observables.value(observables[Symbol("correlation_1_"*string(j))]))))
end

exact_correlations = Dict(
    "1_1"=>3,
    "1_2"=>-1.4035604010536091,
    "1_3"=>0.8550611415977042,
    "1_4"=>-1.4035604010536091,
    "1_5"=>-1.4035604010536091,
    "1_6"=>0.8550611415977042,
    "1_7"=>-0.808656687852374,
    "1_8"=>0.8550611415977042,
    "1_9"=>0.8550611415977042,
    "1_10"=>-0.808656687852374,
    "1_11"=>0.7185015060377071,
    "1_12"=>-0.8086566878523731,
    "1_13"=>-1.4035604010536091,
    "1_14"=>0.8550611415977056,
    "1_15"=>-0.808656687852374,
    "1_16"=>0.8550611415977056,
)

#Test if energy matches the exact diagonalization value
@test isapprox(real(mean((UltraFast.Observables.value(observables[Symbol("EnergyObs")]))))/(4*lattice.nspins), -0.70178020052, rtol=0.01)
for j in 1:lattice.nspins
    @test isapprox(real(mean(UltraFast.Observables.value(observables[Symbol("correlation_1_"*string(j))]))), exact_correlations["1_"*string(j)],rtol=0.05)
end