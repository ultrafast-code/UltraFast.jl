```@meta
CurrentModule = UltraFast
```
# Models

This module contains the variational ansätze implemented in UltraFast and can be
used to define custom models. 

## Restricted Boltzmann Machine
We have implemented several versions of the RBM. The [Standard RBM](@ref) is
implemented with Flux.jl and does not assume any symmetries. The [Translation
invariant RBM](@ref) assumes translation symmetry and is implemented also with
Flux.jl. The [Fast translation invariant RBM](@ref) is a more efficient version
that uses a lookup table to calculate the wavefunction values and does not use
Flux.jl.

### Standard RBM
```@docs
UltraFast.Models.RBM
```

```@docs
UltraFast.Models.RBM(lattice::LatticeSettings, alpha::Int; init=complex_glorot_uniform(gain=0.001), isComplex = true, beta=1.0)
```

### Translation invariant RBM
```@docs
UltraFast.SymmetryRBM.TranslationInvariantRBM
```

### Fast translation invariant RBM
```@docs
UltraFast.SymmetryRBM.FastTranslationInvariantRBM
```

## Custom models
A custom model must subtype the abstract `Model` type and implement the following methods:

### Descriptive methods
Implementations must provide:
- `nspins(m::Model)`: Return the number of spins in the system
- `number_of_parameters(m::Model)`: Return the total number of trainable parameters
- `hyperparameters(m::Model)`: Return model hyperparameters, note that it should be
  possible to reconstruct the model from these hyperparameters.
- `params_description(m::Model)`: Print parameter information in a human-readable format

### Gradients/wavefunction
Implementations must provide:
- `gradient(m::Model)`: Compute gradients with respect to model parameters
- `wavefunction_value(m::Model, states::AbstractVector)`: Evaluate the wavefunction at given state(s), with and without flips

### Optimization methods
Implementations must provide:
- `setup_optimiser(m::Model)`: Set up the optimizer state for training
- `update_weights!(m::Model)`: Update model weights using gradients and optimizer state

### Getting/setting weights
Implementations must provide:
- `get_weights(m::Model)`: Retrieve the current model weights as a vector
- `set_weights!(m::Model, weights::AbstractVector)`: Set the model weights to a provided vector of new weights

### Example custom model

As an example, we will implement an RBM with translation symmetry in Flux.

This model is also known as the 'invariant RBM' and can be loaded through `UltraFast.SymmetryRBM.TranslationInvariantRBM`.

```julia
using UltraFast.Models
using UltraFast.Lattices
import UltraFast.SymmetryRBM.TranslationInvarianceTools: WeightTranslator, weights_from!, independent_weights_from!, independent_weights_from, weights_from
```


## API

### Abstract Types

```@docs
UltraFast.Models.Model
```

```@docs
UltraFast.Models.FluxModel
```

```@docs
UltraFast.Models.ComplexFluxModel
```

### Model Information and Descriptive Methods

```@docs
UltraFast.Models.nspins
```

```@docs
UltraFast.Models.number_of_parameters
```

```@docs
UltraFast.Models.hyperparameters
```

```@docs
UltraFast.Models.params_description
```

```@docs
UltraFast.Models.identifier
```

```@docs
UltraFast.Models.settings
```

### Wavefunction Evaluation

```@docs
UltraFast.Models.wavefunction_value
```

```@docs
UltraFast.Models.wavefunction_values
```

```@docs
UltraFast.Models.wavefunction_value_parallel
```

### Gradient Computation

```@docs
UltraFast.Models.gradient
```

```@docs
UltraFast.Models.gradient_parallel
```

### Weight Management

```@docs
UltraFast.Models.get_weights
```

```@docs
UltraFast.Models.get_flattened_weights
```

```@docs
UltraFast.Models.get_RBM_weights
```

```@docs
UltraFast.Models.set_weights!
```

### Optimization

```@docs
UltraFast.Models.setup_optimiser
```

```@docs
UltraFast.Models.update_weights!
```


### Model Saving and Loading

```@docs
UltraFast.Models.save_model
```