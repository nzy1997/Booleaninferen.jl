struct BooleanResult{N,S,C}
    rs::Tropical{Float64} # -inf stands for false, 0.0 stands for true
    config::ConfigSampler{N,S,C}
end

BooleanResult{N,S,C}(bs::ConfigSampler) where {N,S,C} = BooleanResult(Tropical(0.0), bs)

BooleanResult(b::Bool, x::AbstractVector)  = BooleanResult(b,2,x)
BooleanResult(rs::Tropical{Float64}, nflavor::Int, x::AbstractVector) = BooleanResult(rs, ConfigSampler(StaticElementVector(nflavor, x)))
BooleanResult(b::Bool, nflavor::Int, x::AbstractVector)  = BooleanResult(Tropical(b ? 0.0 : -Inf), ConfigSampler(StaticElementVector(nflavor, x)))

Base.:(==)(a::BooleanResult, b::BooleanResult) = a.rs == b.rs && a.config == b.config

# Base.:(+)(a::BooleanResult, b::BooleanResult) = (a.rs == Tropical(-Inf)) ? b : a
function Base.:(+)(a::BooleanResult, b::BooleanResult) 
    if a.rs == Tropical(-Inf)
        return b
    else
        return a
    end
end

Base.:(*)(a::BooleanResult, b::BooleanResult) = BooleanResult(a.rs * b.rs, a.config * b.config)
function Base.one(::Type{BooleanResult{N,S,C}}) where {N,S,C}
    BooleanResult(Tropical(0.0), ConfigSampler(StaticElementVector(2, fill(0, N))))
end
function Base.zero(::Type{BooleanResult{N,S,C}}) where {N,S,C}
    BooleanResult(Tropical(-Inf), ConfigSampler(StaticElementVector(2, fill(0, N))))
end
zero_count(::Type{BooleanResult{N,S,C}}) where {N,S,C} = zero(BooleanResult{N,S,C})
struct BooleanResultBranchCount{N,S,C}
    rs::Tropical{Float64} # -inf stands for false, 0.0 stands for true
    config::ConfigSampler{N,S,C}
    count::Int
end

function Base.:(==)(a::BooleanResultBranchCount, b::BooleanResultBranchCount) 
    return a.rs == b.rs && a.config == b.config && a.count == b.count
end

function Base.:(+)(a::BooleanResultBranchCount, b::BooleanResultBranchCount) 
    br = BooleanResult(a.rs , a.config) + BooleanResult(b.rs , b.config)
    return BooleanResultBranchCount(br.rs, br.config, a.count + b.count)
end

function Base.:(*)(a::BooleanResultBranchCount, b::BooleanResultBranchCount) 
    return BooleanResultBranchCount(a.rs * b.rs, a.config * b.config, a.count * b.count)
end

BooleanResultBranchCount{N,S,C}(bs::ConfigSampler) where {N,S,C} = BooleanResultBranchCount(Tropical(0.0), bs, 1)

function Base.one(::Type{BooleanResultBranchCount{N,S,C}}) where {N,S,C}
    BooleanResultBranchCount(Tropical(0.0), ConfigSampler(StaticElementVector(2, fill(0, N))),1)
end
function Base.zero(::Type{BooleanResultBranchCount{N,S,C}}) where {N,S,C}
    BooleanResultBranchCount(Tropical(-Inf), ConfigSampler(StaticElementVector(2, fill(0, N))),1)
end
zero_count(::Type{BooleanResultBranchCount{N,S,C}}) where {N,S,C} = BooleanResultBranchCount(Tropical(-Inf), ConfigSampler(StaticElementVector(2, fill(0, N))),0)

BooleanResultBranchCount(b::Bool, x::AbstractVector)  = BooleanResultBranchCount(b,2,x)

BooleanResultBranchCount(b::Bool, nflavor::Int, x::AbstractVector)  = BooleanResultBranchCount(Tropical(b ? 0.0 : -Inf), ConfigSampler(StaticElementVector(nflavor, x)),1)

function get_answer(br::BooleanResult,n::Int) 
    return br.rs == Tropical(0.0), br.config.data[1:n] .== one(UInt64)
end

function get_answer(br::BooleanResultBranchCount,n::Int) 
    return br.rs == Tropical(0.0), br.config.data[1:n] .== one(UInt64),br.count
end
