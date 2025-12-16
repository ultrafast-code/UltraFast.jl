# UltraFast

`UltraFast.jl` is an open source Julia package for simulating quantum many-body
systems using Neural Quantum States (NQS). 

The package implements ground state optimization of Restricted Boltzmann Machine
(RBM) ansatz with Stochastic Reconfiguration. It supports parallelization using
`Distributed.jl` scaling the Monte Carlo sampling across multiple CPU cores,
allowing for efficient simulations of larger systems.

The documentation can be found 
[here](https://ultrafast-code.github.io/UltraFast.jl/).

## How to install
To install `UltraFast.jl`, run the following command in the Julia REPL:
```julia
import Pkg
Pkg.add("https://github.com/ultrafast-code/UltraFast.jl")
```

## Examples

In
[examples/groundstate_heisenberg_model.jl](examples/groundstate_heisenberg_model.jl)
and [examples/parallel-groundstate.jl](examples/parallel-groundstate.jl) you can
find example scripts to compute the ground state of the Heisenberg model on a 2D
lattice.

## Citing and authors
It is written by R.J.L.F. Berns, P.F.A. Coenders, G. Fabiani and J.H. Mentink
for research purpose. Any use of UltraFast.jl for scientific research has to
provide citation to ultrafast-code/UltraFast.jl.

See [`CITATION.bib`](CITATION.bib) for how to cite `UltraFast.jl` in your publications.
