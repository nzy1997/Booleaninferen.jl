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
function OptimalBranchingCore.select_variables(p::BooleanInferenceProblem,bs::AbstractBranchingStatus,m::M, selector::KNeighborSelector) where{M<:AbstractMeasure}
    he2v,edge_list = subhg(p, bs)
    vs = k_neighboring(he2v, he2v[1][1], selector.k-1)
    return neighbor_subbip(he2v, vs,edge_list)
end

function k_neighboring(he2v::Vector{Vector{Int}}, vs, k::Int)
    for _ in 1:k
        vs = neighboring(he2v, vs)
    end
    return vs
end

function _neighboring(he2v::Vector{Vector{Int}}, vs::Vector{Int})
    edges = sort([i for i in 1:length(he2v) if !isempty(he2v[i] ∩ vs)])
    vs = sort(reduce(∪, he2v[edges]))
    return vs, edges
end
function neighboring(he2v::Vector{Vector{Int}}, vs::Vector{Int})
    return first(_neighboring(he2v, vs))
end

function neighboring(he2v::Vector{Vector{Int}}, v::Int)
    return neighboring(he2v, [v])
end
neighbor_subbip(he2v::Vector{Vector{Int}}, v::Int,edge_list) = neighbor_subbip(he2v, [v],edge_list)
function neighbor_subbip(he2v::Vector{Vector{Int}}, vs::Vector{Int},edge_list)
    vs, edges = _neighboring(he2v, vs)
    return SubBIP(vs, edge_list[edges],[ind for ind in 1:length(vs) if any([vs[ind] ∈ v for v in he2v[setdiff(1:length(he2v),edges)]])])
end

function subhg(bip::BooleanInferenceProblem, bs::AbstractBranchingStatus)
    decided_v = [ i for i in 1:bip.literal_num if readbit(bs.decided_mask, i) == 1]
    return [setdiff(bip.he2v[e], decided_v) for e in 1: length(bip.he2v) if bs.undecided_literals[e] > 0],[e for e in 1: length(bip.he2v) if bs.undecided_literals[e] > 0]
end