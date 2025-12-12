using JSON

JSON.lower(l::LatticeConfig) = JSON.lower(l.settings)

# Dictionary deserialization
LatticeSettings(settings::Dict) = LatticeSettings(Lx = settings["Lx"], Ly = settings["Ly"])

# Dictionary deserialization
LatticeConfig(settings::Dict) = LatticeSettings(settings) |> LatticeConfig