

function Heisenberg(settings; lattice::LatticeConfig)
    return Heisenberg(
        J_x = get(settings, "J_x", 1.0),
        J_y = get(settings, "J_y", 1.0),
        lattice = lattice,
        mag0 = get(settings, "mag0", true),
        parallel = get(settings, "parallel", false),
        marshall_sign_rule = get(settings, "marshall_sign_rule", true)
    )
end

function settings(H::Heisenberg)
    return Dict(
        "type" => "Heisenberg",
        "J_x" => H.J_x,
        "J_y" => H.J_y,
        "nspins" => H.lattice.nspins,
        "mag0" => H.mag0,
        "parallel" => H.parallel,
        "marshall_sign_rule" => H.marshall_sign_rule,
        "Lx" => H.lattice.settings.Lx,
        "Ly" => H.lattice.settings.Ly,
    )
end