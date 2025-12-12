module Lattice

"""
    LatticeSettings(; Lx, Ly, nspins = Lx*Ly)

Settings to define a 2D lattice

# Fields
- `Lx::Int`: Number of lattice sites in the x-direction.
- `Ly::Int`: Number of lattice sites in the y-direction.
- `nspins::Int`: Total number of spins (defaults to `Lx * Ly`).

# Examples

```jldoctest
julia> s = LatticeSettings(Lx=4, Ly=2)
LatticeSettings(4, 2, 8)

julia> s.nspins
8

julia> s2 = LatticeSettings(Lx=3, Ly=3, nspins=7)
LatticeSettings(3, 3, 7)
```
"""
Base.@kwdef struct LatticeSettings
    Lx::Int
    Ly::Int
    nspins::Int = Lx*Ly
end

"""
    Check if the lattice is square.
"""
is_square(lattice::LatticeSettings) = lattice.Lx == lattice.Ly
"""
    Check if the lattice is a (one-dimensional) chain.
"""
is_chain(lattice::LatticeSettings) = lattice.Ly == 1 || lattice.Lx == 1

include("Heisenberg_lattice.jl")

"""
    LatticeConfig(; Lx, Ly)
    LatticeConfig(settings::LatticeSettings)

Configuration of a 2D lattice system, including bonds, sublattices, and translation group.

# Fields
- `settings::LatticeSettings`: Lattice parameters.
- `nspins::Int`: Total number of spins.
- `bonds_x::Vector{Tuple{Int,Int}}`: Bonds along x-direction.
- `bonds_y::Vector{Tuple{Int,Int}}`: Bonds along y-direction.
- `sublattice_A::Vector{Int}`: Indices of sublattice A.
- `sublattice_B::Vector{Int}`: Indices of sublattice B.
- `translation_group::Vector{Permutation}`: Translation symmetry group.

# Examples

```jldoctest
julia> c = LatticeConfig(Lx=2, Ly=2)
LatticeConfig(Lx=2, Ly=2, nspins=4)

julia> c.nspins
4

julia> s = LatticeSettings(Lx=3, Ly=2)
LatticeSettings(3, 2, 6)

julia> c2 = LatticeConfig(s)
LatticeConfig(Lx=3, Ly=2, nspins=6)
```
"""
struct LatticeConfig
    settings::LatticeSettings
    bonds_x::Vector{Tuple{Int,Int}}
    bonds_y::Vector{Tuple{Int,Int}}
    nspins::Int
    sublattice_A::Vector{Int}
    sublattice_B::Vector{Int}
    translation_group::Vector{Permutation}
end

function LatticeConfig(;Lx::Int, Ly::Int)
    nspins = Lx * Ly
    bonds_x, bonds_y, sublattice_A, sublattice_B, translation_group = InitLattice(Lx, Ly, nspins)
    bonds_x, bonds_y = InitLattice_(Lx, Ly, nspins)
    settings = LatticeSettings(Lx=Lx, Ly=Ly, nspins=nspins)
    LatticeConfig(settings,
                  bonds_x,
                  bonds_y,
                  settings.nspins,
                  sublattice_A,
                  sublattice_B,
                  translation_group)
end

"""
    Check if the lattice is a (one-dimensional) chain.
"""
is_chain(lattice::LatticeConfig) = is_chain(lattice.settings)
"""
    Check if the lattice is square.
"""
is_square(lattice::LatticeConfig) = is_square(lattice.settings)

# convenience constructor
LatticeConfig(settings::LatticeSettings) = LatticeConfig(Lx=settings.Lx, Ly=settings.Ly)

include("lattice+io.jl")
include("lattice+prettyio.jl")

export LatticeConfig, LatticeSettings, is_chain, is_square

end # module Lattice