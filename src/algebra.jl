struct BooleanResult{N,S,C}
    rs::Tropical{Float64} # -inf stands for false, 0.0 stands for true
    config::ConfigSampler{N,S,C}
end
function get_answer(br::BooleanResult) 
    # return br.rs == Tropical(0.0), br.config.x
    return br
end

BooleanResult(rs::Tropical{Float64}, nflavor::Int, x::AbstractVector) = BooleanResult(rs, ConfigSampler(StaticElementVector(nflavor, x)))
BooleanResult(b::Bool, nflavor::Int, x::AbstractVector)  = BooleanResult(Tropical(b ? 0.0 : -Inf), ConfigSampler(StaticElementVector(nflavor, x)))

Base.:(==)(a::BooleanResult, b::BooleanResult) = a.rs == b.rs && a.config == b.config
# Base.:(+)(a::BooleanResult, b::BooleanResult) = BooleanResult(a.rs + b.rs, a.config+ b.config)
Base.:(*)(a::BooleanResult, b::BooleanResult) = BooleanResult(a.rs * b.rs, a.config * b.config)
function Base.one(::Type{BooleanResult{N,S,C}}) where {N,S,C}
    BooleanResult(Tropical(0.0), ConfigSampler(StaticElementVector(N, fill(0, N))))
end
function Base.zero(::Type{BooleanResult{N,S,C}}) where {N,S,C}
    BooleanResult(Tropical(-Inf), ConfigSampler(StaticElementVector(N, fill(0, N))))
end