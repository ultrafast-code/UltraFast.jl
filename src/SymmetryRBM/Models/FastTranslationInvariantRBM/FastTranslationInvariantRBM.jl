using .WvDerivativeTi

using .OldGiammarcoRBM
using .ParameterConversion
using LoopVectorization


mutable struct FastTranslationInvariantRBM{T} <: Model{T}
    lattice::LatticeSettings
    alpha::Int
    RBMPar::RBM_par{T}
    W_RBM::Array{T,1}
    const filter_ind::Array{Int64,2}
    Lt::Array{T,1}
    gradient_store::Array{T,1}
end



#initialize the network parameters with random numbers
function RBM_par(alpha::Int64, nspins::Int64; init = Models.default_uniform())    
    #initialize hiddens biases as vector of complex random numbers
    b_ = init(nspins*alpha)

    #initialize weights as matrix of complex random numbers
    W_ = init(nspins, nspins*alpha)

    #initialize visible biases as vector of zeros
    a_ = zeros(eltype(b_), nspins)

    return RBM_par(a_, b_, W_)
end

"""
    FastTranslationInvariantRBM(lattice::LatticeSettings, alpha::Int; init = Models.default_uniform())

Translation-invariant Restricted Boltzmann Machine (RBM) which uses a lookup
table for efficient computation of the wavefunction and its derivatives.

# Arguments
- `lattice::LatticeSettings`: The lattice configuration.
- `alpha::Int`: The number of hidden units in the RBM.
- `init`: (Optional) Initialization function for RBM parameters. Defaults to
  `Models.default_uniform()`.

# Returns
- `FastTranslationInvariantRBM{T}`: A translation-invariant RBM model where `T`
  is the element type of the weight matrix.

# Details
The function initializes:
- RBM parameters (weights and biases)
- A lookup table for efficient computation of the wavefunction
- Temporary storage arrays for intermediate calculations
"""
function FastTranslationInvariantRBM(lattice::LatticeSettings, alpha::Int; init = Models.default_uniform())
    Lx = lattice.Lx
    Ly = lattice.Ly
    
    # initialize the filter indices for translation invariance
    filter_ind = WvDerivativeTi.transl_inv_tool(lattice.nspins, alpha, Lx, Ly)

    # initialize the RBM parameters
    RBMPar = RBM_par(alpha, lattice.nspins; init = init)
    
    T = eltype(RBMPar.W)

    W_RBM = zeros(T, alpha + alpha * lattice.nspins) #init(alpha + alpha * lattice.nspins)# # alpha + alpha*nspins
    ParToW(RBMPar, W_RBM, lattice.nspins, alpha)

    # lookup table
    Lt = zeros(T, alpha * lattice.nspins) #InitLt(RBMPar, initialstate, alpha, lattice.nspins)

    # make the model
    return FastTranslationInvariantRBM{T}(lattice, alpha, RBMPar, W_RBM, filter_ind, Lt, zeros(T, alpha + alpha * lattice.nspins))
end

#FastTranslationInvariantRBM(lattice::LatticeConfig, alpha::Int) = FastTranslationInvariantRBM(lattice.settings, alpha)
FastTranslationInvariantRBM(lattice::LatticeConfig, alpha::Int; kwargs...) = FastTranslationInvariantRBM(lattice.settings, alpha; kwargs...)

# Implementation of the Model abstract type
Models.number_of_parameters(m::FastTranslationInvariantRBM) = size(m.W_RBM)[1]
Models.params_description(m::FastTranslationInvariantRBM) = println("nparams = $(Models.number_of_parameters(m)) - FastTranslationInvariantRBM")

Models.nspins(m::FastTranslationInvariantRBM) = m.lattice.nspins
Models.hyperparameters(m::FastTranslationInvariantRBM) = Dict("alpha"  => m.alpha)
Models.identifier(m::FastTranslationInvariantRBM) = "FastTranslationInvariantRBM"
Models.settings(m::FastTranslationInvariantRBM) = Dict("type" => Models.identifier(m), "nspins" => m.lattice.nspins, "alpha" => m.alpha)

# Implementation of the FastTranslationInvariantRBM abstract type
function Models.gradient(m::FastTranslationInvariantRBM, state::Array{Int})
    Models.new_state!(m, state)
    WvDerivativeTi.Var_derivatives!(state, m.gradient_store, m.Lt, m.filter_ind, m.lattice.nspins, m.alpha)
    return m.gradient_store
end

# return the log of the wavefunction
function Models.wavefunction_value(m::FastTranslationInvariantRBM, state::Array{Int}; efficient::Bool=false)
    if efficient
        return sum(log.(2cosh.(m.Lt)))
    end

    Models.new_state!(m, state)
    return sum(log.(2cosh.(m.Lt)))
end

function Models.wavefunction_value(m::FastTranslationInvariantRBM, state::Array{Int}, flips::Array{Int})
    if length(flips) === 0
        return Complex(0) # Float64 when using LoopVectorization
    end

    logwf = Complex(0) # Float64 when using LoopVectorization

    #Change due to the visible bias
    # TODO THIS IS ACTUALLY ONLY HALF IMPLEMENTED, The bias a is usually zero so code will do nothing.
    for i = eachindex(flips)
        logwf -= m.RBMPar.a[flips[i]] * 2 * state[flips[i]]
    end

    

    #Change due to the weights
    @fastmath for h = 1:m.alpha*m.lattice.nspins
        thetahp = m.Lt[h]

        # #for i = eachindex(flips)
        for i = eachindex(flips)
            thetahp -= 2.0 * state[flips[i]] * m.RBMPar.W[flips[i], h]
        end

        logwf += log(2cosh(thetahp))
    end

    # # Change due to the weights
    # @tturbo for h in eachindex(m.Lt) #1:m.alpha*m.lattice.nspins
    #     thetahp = m.Lt[h]

    #     # #for i = eachindex(flips)
    #     for i in eachindex(flips)
    #         thetahp -= 2.0 * state[flips[i]] * m.RBMPar.W[flips[i], h]
    #     end

    #     logwf += log(2cosh(thetahp))
    # end

    return logwf
end

function UpdateLt(RBMPar::RBM_par, Lt::Array{<:Number,1}, state::Array{Int,1}, flips::Array{Int,1}, alpha::Int, nspins::Int)

    if length(flips) === 0
        return
    end

    for h = 1:alpha*nspins
        for i = 1:length(flips)
            Lt[h] -= 2.0 * state[flips[i]] * RBMPar.W[flips[i], h]
        end
    end

     
    # @tturbo for h in eachindex(Lt)
    #     for i in eachindex(flips)
    #         Lt[h] -= 2.0 * state[flips[i]] * RBMPar.W[flips[i], h]
    #     end
    # end


end


# Implementation of the FastTranslationInvariantRBM abstract type
function Models.handle_state_update!(m::FastTranslationInvariantRBM, state::AbstractVector, flips::AbstractVector)
    UpdateLt(m.RBMPar, m.Lt, state, flips, m.alpha, m.lattice.nspins)
end

function InitLt(RBMPar::Par, state::Array{Int64,1}, alpha::Int, nspins::Int) where {T, Par <: RBM_par{T}}

    Lt_ = Array{T}(undef, alpha * nspins)

    for h = 1:alpha*nspins
        Lt_[h] = RBMPar.b[h]
        for v = 1:nspins
            Lt_[h] += state[v] * RBMPar.W[v, h]
        end
    end

    return Lt_

end

function Models.new_state!(m::FastTranslationInvariantRBM, state::AbstractVector)
    # TODO - check whether all the weights are in sync AKA RBMPar::RBM_par ≈ W_RBM::Array{Complex{Float64},1}
    
    m.Lt = InitLt(m.RBMPar, state, m.alpha, m.lattice.nspins)
end

Models.setup_optimiser(m::FastTranslationInvariantRBM, optimiser::Optimisers.AbstractRule) = Optimisers.setup(optimiser, m.W_RBM)

function Models.update_weights!(opt_state, m::FastTranslationInvariantRBM, gradient::AbstractVector)
    opt_state, m.W_RBM = Optimisers.update!(opt_state, m.W_RBM, gradient)
    #println(m.W_RBM)
    WToPar(m.RBMPar, m.W_RBM, m.alpha, m.lattice.nspins, m.lattice.Lx, m.lattice.Ly)
    return opt_state
end

Models.get_flattened_weights(m::FastTranslationInvariantRBM) = m.W_RBM

function Models.get_RBM_weights(m::FastTranslationInvariantRBM)
    return (W=m.RBMPar.W, b=m.RBMPar.b)
end

# function loadweights!(m::M, W_RBM::AbstractVector{T}) where {T, M<:FastTranslationInvariantRBM{T}}
#     m.W_RBM = W_RBM
#     WToPar(m.RBMPar, m.W_RBM, m.alpha, m.lattice.nspins, m.lattice.Lx, m.lattice.Ly)
# end

function independent_weights(m::FastTranslationInvariantRBM)
    return m.W_RBM
end

function Models.set_weights!(m::FastTranslationInvariantRBM, new_independent_weights::AbstractVector)
  m.W_RBM .= new_independent_weights
  WToPar(m.RBMPar, m.W_RBM, m.alpha, m.lattice.nspins, m.lattice.Lx, m.lattice.Ly)
end

include("FastTranslationInvariantRBM+io.jl")