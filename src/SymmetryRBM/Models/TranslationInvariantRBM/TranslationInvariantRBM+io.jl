function TranslationInvariantRBM(settings; lattice::LatticeConfig)
    alpha = settings["alpha"]
    init = settings["weight_initializer"]

    if init == "complex_default_uniform"
        TranslationInvariantRBM(lattice.settings, alpha::Int; init = Models.default_uniform())
    elseif init == "real_default_uniform"
        TranslationInvariantRBM(lattice.settings, alpha::Int; init = Models.real_default_uniform())
    else
        error("Unknown weight initializer: $init")
    end
end