# loading.jl
# Path: src/weightio/loading.jl
using NamedTupleTools

function loadindependent(filepath::String, alpha::Int, nspins::Int, L_x::Int, L_y::Int) 
    RBM_Par = init_RBM_par(alpha, nspins)

    WRBM = readdlm(filepath, Float32)[:] .+ 0.0im

    WToPar(RBM_Par, WRBM, alpha, nspins, L_x, L_y)

    RBM_ParF32 = getRBM_parF32(RBM_Par)

    #println(typeof(RBM_ParF32))

    function fluxRBM!(model)
        params = Flux.state(model)

        println(size(params.layers[1].weight), " ", size(RBM_ParF32.W))
        println(size(params.layers[1].bias), " ", size(RBM_ParF32.b))

        params.layers[1].weight .= transpose(RBM_ParF32.W)
        params.layers[1].bias .= RBM_ParF32.b

        

        Flux.loadmodel!(model, params);
    end

    return RBM_ParF32, fluxRBM!
end

function loadindependent(filepath_re::String, filepath_im::String, alpha::Int, nspins::Int, L_x::Int, L_y::Int) 
    RBM_Par = init_RBM_par(alpha, nspins)

    WRBM = readdlm(filepath_re, Float64)[:] .+ readdlm(filepath_im, Float64)[:] .* im

    WToPar(RBM_Par, WRBM, alpha, nspins, L_x, L_y)

    RBM_ParF32 = getRBM_parF32(RBM_Par)

    function fluxRBM!(model)
        params = Flux.state(model)

        println(size(params.layers[1].weight), " ", size(RBM_ParF32.W))
        println(size(params.layers[1].bias), " ", size(RBM_ParF32.b))

        params.layers[1].weight .= transpose(RBM_ParF32.W)
        params.layers[1].bias .= RBM_ParF32.b

        

        Flux.loadmodel!(model, params);
    end

    return RBM_ParF32, fluxRBM!
end

