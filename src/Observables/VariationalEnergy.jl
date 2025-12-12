
struct VariationalEnergy <: Observable end

function observe(o::VariationalEnergy; states::AbstractArray{Int}, logwavefunctions::AbstractArray{T}, model::Model{T}, hamiltonian::Hamiltonian) where T
    states = flatten_batch(states; keep=2)
    logwavefunctions = flatten_batch(logwavefunctions; keep=1)

    Elocs = zeros(T, size(states, 2))
    
    for i = 1:size(states, 2)
        Elocs[i] = Eloc(hamiltonian, model, states[:,i], logwavefunctions[i])
    end

    return Elocs
end