function Eloc(H::Heisenberg, model::Model, state::AbstractArray{Int, 1}, currenstatelog::T)  where {T<:Number} #where T<:Number 
    if H.parallel
        return Eloc_parallel(H, model, state, currenstatelog)
    else
        return Eloc_sequential(H, model, state, currenstatelog)
    end
end

function Eloc_sequential(H::Heisenberg, model::Model, state::AbstractArray{Int, 1}, currenstatelog::T) where {T<:Number}
    totalenergy = zero(T)

    # the following property can be removed if the model is already initialized at 'state'
    new_state!(model, state)

    # sum over all the bonds and calculate the bond energy per bond for the SzSz term
    for bond in H.lattice.bonds_x
        totalenergy += state[bond[1]] * state[bond[2]] #TODO: * H.Jx
    end
    
    for bond in H.lattice.bonds_y
        totalenergy += state[bond[1]] * state[bond[2]] #TODO * H.Jy
    end

    # sum over all the bonds and calculate the bond energy per bond for the SxSx
    # + SySy term We consider all the terms that are a bond flip away from the
    # current state. A bond flip means that we flip the spin of two neighboring
    # from |up down> to |down up>

    # sum over all the bonds and calculate the bond energy per bond for the SxSx
    # SySy term.
    nondiagonalstatelog = zero(T)

    sign = H.marshall_sign_rule ? -1.0 : 1.0

    for bond in H.lattice.bonds_x
        if state[bond[1]] != state[bond[2]]
            nondiagonalstatelog = wavefunction_value(model, state, [bond[1], bond[2]])
            totalenergy += sign * 2.0 * exp(nondiagonalstatelog - currenstatelog)
        end
    end

    for bond in H.lattice.bonds_y
        if state[bond[1]] != state[bond[2]]
            nondiagonalstatelog = wavefunction_value(model, state, [bond[1], bond[2]])
            totalenergy += sign * 2.0 * exp(nondiagonalstatelog - currenstatelog)
        end
    end

    return totalenergy
end

function Eloc_parallel(H::Heisenberg, model::Model, state::AbstractArray{<:Int, 1}, currenstatelog::T) where T<:Number
    totalenergy = zero(T)

    # sum over all the bonds and calculate the bond energy per bond for the SzSz term
    for bond in H.lattice.bonds_x
        totalenergy += state[bond[1]] * state[bond[2]]
    end
    
    for bond in H.lattice.bonds_y
        totalenergy += state[bond[1]] * state[bond[2]]
    end

    # sum over all the bonds and calculate the bond energy per bond for the SxSx
    # + SySy term We consider all the terms that are a bond flip away from the
    # current state. A bond flip means that we flip the spin of two neighboring
    # from |up down> to |down up>

    # sum over all the bonds and calculate the bond energy per bond for the SxSx
    # SySy term.
    
    flips = zeros(Int, 2, 2*H.lattice.nspins)
    total_flips = 0

    for bond in H.lattice.bonds_x
        if state[bond[1]] != state[bond[2]]
            total_flips += 1
            flips[:, total_flips] .= [bond[1], bond[2]]
        end
    end
    
    for bond in H.lattice.bonds_y
        if state[bond[1]] != state[bond[2]]
            total_flips += 1
            flips[:, total_flips] .= [bond[1], bond[2]]
        end
    end

    nondiagonalstatelogs = zeros(T, total_flips)

    states = hcat(fill(state, total_flips)...)

    nondiagonalstatelogs = wavefunction_value_parallel(model, states, flips[:, 1:total_flips])

    sign = H.marshall_sign_rule ? -1.0 : 1.0

    totalenergy += sign * 2.0 * sum(exp.(nondiagonalstatelogs .- currenstatelog))

    return totalenergy
end