using Statistics
using Distributed

struct SRObservables <: Observable end


function observe(o::SRObservables; states::AbstractArray{Int}, logwavefunctions::AbstractArray{T}, model::Model{T}, hamiltonian::Hamiltonian) where T
    @assert size(states, 2) == size(logwavefunctions, 1) "States and logwavefunctions must have the same number of samples"

    if ndims(states) == 2 && ndims(logwavefunctions) == 1
        return observe_SR_(states, logwavefunctions, model, hamiltonian)
    else
        @assert ndims(states) > 2 "States must be at least 2D (nspins, nsamples, ...)"
        @assert ndims(logwavefunctions) > 1 "Logwavefunctions must be at least 1D (nsamples, ...)"
        
        return observe_multithreaded(o, states=states, logwavefunctions=logwavefunctions, model=model, hamiltonian=hamiltonian)
    end
end

function observe_SR_(states::AbstractMatrix{Int}, logwavefunctions::AbstractVector{T}, model::Model{T}, hamiltonian::Hamiltonian) where T
    nparams = number_of_parameters(model)
    nsamples = size(states, 2)

    Elocs = zeros(T, nsamples)

    OkconjOkprime = zeros(T, nparams, nparams)
    Ok = zeros(T, nparams)
    ElocOkconj = zeros(T, nparams)

    for i = 1:nsamples
        Eloc_ = Eloc(hamiltonian, model, states[:,i], logwavefunctions[i])
        Elocs[i] = Eloc_

        grad = gradient(model, states[:,i])

        OkconjOkprime += conj(grad) * transpose(grad)
        Ok += grad
        ElocOkconj += Eloc_ * conj(grad)
    end

    OkconjOkprime /= nsamples
    Ok /= nsamples
    ElocOkconj /= nsamples
    
    return (Eloc=mean(Elocs), Elocs=Elocs, OkconjOkprime=OkconjOkprime, Ok=Ok, ElocOkconj=ElocOkconj, StdEloc=std(Elocs))
end

function observe_multithreaded(o::SRObservables; states::AbstractArray{Int}, logwavefunctions::AbstractArray{T}, model::Model{T}, hamiltonian::Hamiltonian) where T
    states = flatten_batch(states; keep=3)
    logwavefunctions = flatten_batch(logwavefunctions; keep=2)

    @assert size(states, 3) == size(logwavefunctions, 2) "States and logwavefunctions must have the same number of batches"
        
    nbatches = size(states, 3)
    nsamples_per_batch = size(states, 2)
    nsamples = nbatches * nsamples_per_batch


    output = pmap(i -> begin
        observe_SR_(states[:,:,i], logwavefunctions[:,i], deepcopy(model), hamiltonian)
    end, 1:nbatches)

    Elocs = vcat([o.Elocs for o in output]...)
    OkconjOkprime = sum([o.OkconjOkprime for o in output]) / nbatches
    Ok = sum([o.Ok for o in output]) / nbatches
    ElocOkconj = sum([o.ElocOkconj for o in output]) / nbatches
    StdEloc = std(Elocs)
    Eloc = mean(Elocs)

    return (Eloc=Eloc, Elocs=Elocs, OkconjOkprime=OkconjOkprime, Ok=Ok, ElocOkconj=ElocOkconj, StdEloc=StdEloc) 
end