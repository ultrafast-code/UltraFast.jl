```@meta
CurrentModule = UltraFast
```

# Optimisation

## Samplers
What should a sampler return? 
- `states`, the sampled states
- `logwavefunctions`, the log wavefunction values of the sampled states
- `n_accepted`, if MCMC based, the number of accepted moves
- `n_flips`, if MCMC based, the number of proposed moves
- `n_chains`, if parallel chains, the number of chains
- `runtime`, the time it took to do the sampling

```@autodocs
Modules = [UltraFast.Samplers]
```