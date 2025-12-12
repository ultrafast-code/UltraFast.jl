# This module defines the lattice geometry, namely the bonds
# in the lattice with or without periodic boundary condition (Pbc)
# for the Heisenberg model in a L_x x L_y lattice

#module Lattice
using Permutations

"""
    InitLattice(L_x::Int64, L_y::Int64, nspins::Int64)

Initializes the lattice structure for the Heisenberg Hamiltonian by storing all the bonds.

# Arguments
- `L_x::Int64`: Number of lattice sites along the x-direction.
- `L_y::Int64`: Number of lattice sites along the y-direction.
- `nspins::Int64`: Total number of spins in the lattice.

# Returns
A data structure representing the initialized lattice with all bonds stored for the Heisenberg model.

function written by Pim Coenders 2025
"""

function InitLattice(L_x::Int64, L_y::Int64, nspins::Int64)
    @assert L_x*L_y==nspins

    #Define translation in x and y directions
    Tx = Permutation([i%L_x + 1 + L_x*fld(i-1,L_x) for i in 1:nspins])
    Ty = Permutation([(i+L_x-1)%nspins + 1 for i in 1:nspins])

    #Define translation group as list of permutations of [1,2,3,...,nspins]
    translation_group = Permutation[]
    for ty in 0:(L_y-1)
        for tx in 0:(L_x-1)
            push!(translation_group, (Tx^tx)*(Ty^ty))
        end
    end

    #Define bonds in x and y directions
    bonds_x = [(i,Tx[i]) for i in 1:nspins if i != Tx[i]]
    bonds_y = [(i,Ty[i]) for i in 1:nspins if i != Ty[i]]

    #Define sublattices A and B
    sublattice_A = []
    sublattice_B = []
    for i in 1:nspins
        #if x and y coordinate are the same modulo 2, the site belong to sublattice A
        if ((i-1)%L_x)%2==fld(i-1,L_x)%2
            push!(sublattice_A,i)
        else
            push!(sublattice_B,i)
        end
    end

    bonds_x = unique(bonds_x)
    bonds_y = unique(bonds_y)

    return bonds_x, bonds_y, sublattice_A, sublattice_B, translation_group
end
    

function InitLattice_(L_x::Int64, L_y::Int64, nspins::Int64)

    #Define arrays that will be filled with nearest neigbourng bonds
    v_bonds = Array{Tuple{Int64, Int64}}(undef, 0)
    h_bonds = Array{Tuple{Int64, Int64}}(undef, 0)

    #Set boundary conditions
    if L_x > 2 && L_y > 2
        pbc_v = true
        pbc_h = true
    elseif L_x <= 2 && L_y > 2
        pbc_v = true
        pbc_h = false
    elseif L_x > 2 && L_y == 2
        pbc_v = false
        pbc_h = true
    else
        pbc_v = false
        pbc_h = false
    end


    #Check if the number of spins is compatible with the given lattice size
    if (L_x * L_y != nspins)
        println("Error , the number of spins is not compabitle with lattice length ")
        error()
    end

    nn = Array{Array{Int64}}(undef, nspins)
    for i=1:nspins
        nn[i]= Array{Int64}(undef,4)
    end;

    #Defining the nearest-neighbors
    for i = 1:nspins

        if pbc_h
            nn[i][1] = PbcH(L_x, i - 1, i)
        else
            nn[i][1] = PbcH(L_x, i - 1, i)
        end

        if pbc_h
            nn[i][2] = PbcH(L_x, i + 1, i)
        else
            nn[i][2] = PbcH(L_x, i + 1, i)
        end

        if pbc_v
            nn[i][3] = PbcV(nspins, i - L_x)
        else
            nn[i][3] = V(nspins, i - L_x)
        end

        if pbc_v
            nn[i][4] = PbcV(nspins, i + L_x)
        else
            nn[i][4] = V(nspins, i + L_x)
        end
    end

    #Push nearest neighbouring bonds along y into the array v_bonds
    for i = 1:nspins
        for k = 3:4
            j = nn[i][k]
            if i < j
                push!(v_bonds, (i, j))
            end
        end
    end

    #Push nearest neighbouring bonds along x into the array h_bonds
    for i = 1:nspins
        for k = 1:2
            j = nn[i][k]
            if i < j
                push!(h_bonds, (i, j))
            end
        end
    end

    #We only keep inequivalent bonds
    bondsH = unique(h_bonds)
    bondsV = unique(v_bonds)

    return bondsH, bondsV

end


"Small functions to set up the lattice Horizontal (x) Pbc"
function PbcH(L_x::Int64, nn::Int64, s::Int64)
    if (s - 1) % L_x == 0 && nn == (s - 1)
        return (s + L_x - 1)
    elseif (s) % L_x == 0 && nn == (s + 1)
        return (s - L_x + 1)
    else
        return nn
    end
end;


"Small functions to set up the lattice Vertical (y) Pbc"
function PbcV(nspins::Int64, nn::Int64)
    if nn > nspins
        return (nn - nspins)
    elseif nn <= 0
        return (nspins + nn)
    else
        return nn
    end
end;


"Small functions to set up the lattice Horizontal (x) without Pbc"
function H(L_x::Int64, nn::Int64, s::Int64)
    if s % L_x == 0 && nn == (s - 1)
        return -1
    elseif (s + 1) % L_x == 0 && nn == (s + 1)
        return -1
    else
        return nn
    end
end;


"Small functions to set up the lattice Vertical (y) without Pbc"
function V(nspins::Int64, nn::Int64)
    if nn > nspins
        return -1
    elseif nn < 0
        return -1
    else
        return nn
    end
end;