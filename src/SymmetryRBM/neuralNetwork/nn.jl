#Initialize neural network --> Restricted Boltzmann machine (RBM)
module OldGiammarcoRBM

using Random

#define structure type containing the visible biases a,
#the hidden biases b and the weights W of the RBM.
# struct RBM_par
#     a::Array{Complex{Float64},1}
#     b::Array{Complex{Float64},1}
#     W::Array{Complex{Float64},2}
# end


struct RBM_par{T <: Number}
    a::Array{T,1}
    b::Array{T,1}
    W::Array{T,2}
end

struct RBM_parF32
    a::Array{Complex{Float32},1}
    b::Array{Complex{Float32},1}
    W::Array{Complex{Float32},2}
end

function getRBM_parF32(RBM::RBM_par)
    return RBM_parF32(RBM.a, RBM.b, RBM.W)
end

#initialize the network parameters with random numbers
function init_RBM_par(alpha::Int64, nspins::Int64)
    #generate random seed dependent on the network size alpha and  number of spins nspins
    seed_ = alpha*nspins*rand(0:20000);
    Random.seed!(seed_)

    #initialize visible biases as vector of zeros
    a_ = zeros(ComplexF64, nspins)

    #initialize hiddens biases as vector of complex random numbers
    b_ = rand(-0.01:0.0001:0.01, nspins*alpha) .+ im*rand(-0.01:0.0001:0.01, nspins*alpha)

    #initialize weights as matrix of complex random numbers
    W_ = rand(-0.01:0.0001:0.01, nspins, nspins*alpha) .+ im*rand(-0.01:0.0001:0.01, nspins, nspins*alpha)

    return RBM_par(a_,b_,W_)
end


#Calculate the wavefunction projected onto the input state
function RBM_wf(par::RBM_par,state::Array{Int64,1},alpha::Int64,nspins::Int64)

    rbm = sum(par.a .* state)

    for h=1:alpha*nspins
        @views thetah = par.b[h] .+ sum(state[v] .* par.W[:,h]);
        rbm += log(2*cosh(thetah));
    end;

    return exp(rbm);
end;

export RBM_wf, init_RBM_par, RBM_par, RBM_parF32, getRBM_parF32

end