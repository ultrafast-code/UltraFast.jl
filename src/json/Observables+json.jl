# JSON serialization of some Observables
JSON.lower(t::Observables.Observable) = error("Observable $(typeof(t)) not implemented for JSON serialization")
# JSON serialization of EnergyObservable
JSON.lower(t::Observables.EnergyObservable) = Dict("type"=>"Energy", "settings"=>Dict("samples"=>t.samples, "iterations"=>t.iterations, "total"=> t.samples * t.iterations, "type" => typeof(t.data)))

# JSON serialization of TimeObservable
JSON.lower(t::Observables.TimeObservable) = Dict("type"=>"Time", "settings"=>Dict("samples"=>t.samples, "iterations"=>t.iterations, "total"=> t.samples * t.iterations, "type" => typeof(t.data)))

# JSON serialization of HalfStateObservable
JSON.lower(t::Observables.HalfStateObservable) = Dict("type"=>"HalfState", "settings"=>Dict("samples"=>t.samples, "iterations"=>t.iterations, "total"=> t.samples * t.iterations, "type" => typeof(t.data)))

# JSON serialization of StateObservable
JSON.lower(t::Observables.StateObservable) = Dict("type"=>"State", "settings"=>Dict("samples"=>t.samples, "iterations"=>t.iterations, "total"=> t.samples * t.iterations, "type" => typeof(t.data)))

# JSON serialization of BoltzmannStateObservable
JSON.lower(t::Observables.BoltzmannStateObservable) = Dict("type"=>"BoltzmannState", "settings"=>Dict("samples"=>t.samples, "iterations"=>t.iterations, "total"=> t.samples * t.iterations, "type" => typeof(t.data)))

