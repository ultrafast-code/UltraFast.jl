struct EnergyOptimiser
    sampler::Sampler
    model::Model
    lattice::LatticeConfig
end

function EnergyOptimiser(;sampler::Sampler, model::Model, lattice::LatticeConfig)
    EnergyOptimiser(sampler, model, lattice)
end

function optimise(optimiser::EnergyOptimiser, nsamples::Int, observableCallback::Function = () -> nothing, thermalizationCallback::Function = () -> nothing)
    state = UltraFast.Samplers.GenRandomState(true, optimiser.lattice.nspins)
    UltraFast.Samplers.sampling!(optimiser.sampler, state, optimiser.model, nsamples; observableCallback=observableCallback, thermalizationCallback=thermalizationCallback)
end