using PrettyTables

Base.show(io::IO, l::LatticeConfig) = parameter_info(io, l)

function parameter_info(io, l::LatticeConfig)
    print(io, "LatticeConfig(Lx=$(l.settings.Lx), Ly=$(l.settings.Ly), nspins=$(l.settings.nspins))")
end