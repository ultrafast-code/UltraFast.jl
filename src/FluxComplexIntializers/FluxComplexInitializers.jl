"""helper functions for initializing neural networks"""
module FluxComplexInitializers

import Flux: glorot_normal, glorot_uniform, trainable
import Random: AbstractRNG, default_rng 

"""complex version of glorot_normal"""
function complex_glorot_normal(rng::AbstractRNG, dims::Integer...; kwargs...)
    return glorot_normal(rng, dims...; kwargs...) + im * glorot_normal(rng, dims...; kwargs...)
end

complex_glorot_normal(dims::Integer...; kw...) = complex_glorot_normal(default_rng(), dims...; kw...)
complex_glorot_normal(rng::AbstractRNG=default_rng(); init_kwargs...) = (dims...; kwargs...) -> complex_glorot_normal(rng, dims...; init_kwargs..., kwargs...)

"""complex version of glorot_uniform"""
function complex_glorot_uniform(rng::AbstractRNG, dims::Integer...; kwargs...)
    return glorot_uniform(rng, dims...; kwargs...) + im * glorot_uniform(rng, dims...; kwargs...)
end

complex_glorot_uniform(dims::Integer...; kw...) = complex_glorot_uniform(default_rng(), dims...; kw...)
complex_glorot_uniform(rng::AbstractRNG=default_rng(); init_kwargs...) = (dims...; kwargs...) -> complex_glorot_uniform(rng, dims...; init_kwargs..., kwargs...)

"""get the number of parameters of a model"""
function get_number_of_parameters(model)
    return sum(length, trainable(model))
end

"""Default initialization"""
function default_uniform(rng::AbstractRNG, dims::Integer...; kwargs...)
    return rand(rng, -0.01:0.0001:0.01, dims...) .+ im*rand(rng, -0.01:0.0001:0.01, dims...) 
end

default_uniform(dims::Integer...; kw...) = default_uniform(default_rng(), dims...; kw...)
default_uniform(rng::AbstractRNG=default_rng(); init_kwargs...) = (dims...; kwargs...) -> default_uniform(rng, dims...; init_kwargs..., kwargs...)

"""Default real initialization"""
function real_default_uniform(rng::AbstractRNG, dims::Integer...; kwargs...)
    return rand(rng, -0.01:0.0001:0.01, dims...)
end

real_default_uniform(dims::Integer...; kw...) = real_default_uniform(default_rng(), dims...; kw...)
real_default_uniform(rng::AbstractRNG=default_rng(); init_kwargs...) = (dims...; kwargs...) -> real_default_uniform(rng, dims...; init_kwargs..., kwargs...)


"""Default Imaginary initialization"""
function imaginary_default_uniform(rng::AbstractRNG, dims::Integer...; kwargs...)
    return rand(rng, -0.01:0.0001:0.01, dims...)*im
end

imaginary_default_uniform(dims::Integer...; kw...) = imaginary_default_uniform(default_rng(), dims...; kw...)
imaginary_default_uniform(rng::AbstractRNG=default_rng(); init_kwargs...) = (dims...; kwargs...) -> imaginary_default_uniform(rng, dims...; init_kwargs..., kwargs...)

export get_number_of_parameters, complex_glorot_normal, complex_glorot_uniform, default_uniform, real_default_uniform, imaginary_default_uniform

end



