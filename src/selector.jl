struct SingleVertex <: AbstractSelector end

function OptimalBranchingCore.select_variables(p::BooleanInferenceProblem, m::M, selector::SingleVertex) where{M<:AbstractMeasure}
    return [p.he2v[1][1]]
end

struct SubBIP
    vs::Vector{Int}
    edges::Vector{Int}
    outside_vs_ind::Vector{Int}
end

struct KNeighborSelector <: AbstractSelector
    k::Int
end

# TODO: Better initial point
function OptimalBranchingCore.select_variables(p::BooleanInferenceProblem, m::M, selector::KNeighborSelector) where{M<:AbstractMeasure}
    vs = k_neighboring(p, p.he2v[1][1], selector.k-1)
    return neighbor_subbip(p, vs)
end

function k_neighboring(bip::BooleanInferenceProblem, vs, k::Int)
    for _ in 1:k
        vs = neighboring(bip, vs)
    end
    return vs
end

function _neighboring(bip::BooleanInferenceProblem, vs::Vector{Int})
    edges = sort([i for i in 1:length(bip.he2v) if !isempty(bip.he2v[i] ∩ vs)])
    vs = sort(reduce(∪, bip.he2v[edges]))
    return vs, edges
end
function neighboring(bip::BooleanInferenceProblem, vs::Vector{Int})
    return first(_neighboring(bip, vs))
end

function neighboring(bip::BooleanInferenceProblem, v::Int)
    return neighboring(bip, [v])
end

function neighbor_subbip(bip::BooleanInferenceProblem, vs::Vector{Int})
    vs, edges = _neighboring(bip, vs)
    return SubBIP(vs, edges,[ind for ind in 1:length(vs) if any([vs[ind] ∈ v for v in bip.he2v[setdiff(1:length(bip.he2v),edges)]])])
end