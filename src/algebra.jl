struct BooleanResult{N,S,C}
    rs::Tropical{Float64} # -inf stands for false, 0.0 stands for true
    config::ConfigSampler{N,S,C}
end
function get_answer(br::BooleanResult,n::Int) 
    return br.rs == Tropical(0.0), br.config.data[1:n] .== one(UInt64)
end

BooleanResult(rs::Tropical{Float64}, nflavor::Int, x::AbstractVector) = BooleanResult(rs, ConfigSampler(StaticElementVector(nflavor, x)))
BooleanResult(b::Bool, nflavor::Int, x::AbstractVector)  = BooleanResult(Tropical(b ? 0.0 : -Inf), ConfigSampler(StaticElementVector(nflavor, x)))

Base.:(==)(a::BooleanResult, b::BooleanResult) = a.rs == b.rs && a.config == b.config

# Base.:(+)(a::BooleanResult, b::BooleanResult) = (a.rs == Tropical(-Inf)) ? b : a

Base.:(*)(a::BooleanResult, b::BooleanResult) = BooleanResult(a.rs * b.rs, a.config * b.config)
function Base.one(::Type{BooleanResult{N,S,C}}) where {N,S,C}
    BooleanResult(Tropical(0.0), ConfigSampler(StaticElementVector(2, fill(0, N))))
end
function Base.zero(::Type{BooleanResult{N,S,C}}) where {N,S,C}
    BooleanResult(Tropical(-Inf), ConfigSampler(StaticElementVector(2, fill(0, N))))
end

struct BooleanResultBranchCount{N,S,C}
    br::BooleanResult{N,S,C}
    count::Int
end

function Base.:(==)(a::BooleanResultBranchCount, b::BooleanResultBranchCount) 
    return a.br == b.br && a.count == b.count
end

function Base.:(+)(a::BooleanResultBranchCount, b::BooleanResultBranchCount) 
    return BooleanResultBranchCount(a.br + b.br, a.count + b.count)
end

function Base.:(*)(a::BooleanResultBranchCount, b::BooleanResultBranchCount) 
    return BooleanResultBranchCount(a.br * b.br, a.count * b.count)
end