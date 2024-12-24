struct DeductionReducer <: AbstractReducer end

function OptimalBranchingCore.reduce_problem(p::BooleanInferenceProblem, bs::AbstractBranchingStatus, reducing_queue::Vector{Int}, ::DeductionReducer)
	while !isempty(reducing_queue)
        isempty(reducing_queue) && break
        edge_num = popfirst!(reducing_queue)
        (bs.undecided_literals[edge_num] <= 0) && continue
        decided_v, decided_vals = lluint2vec(bs.decided_mask,bs.config,p.he2v[edge_num])

        st = slice_tensor(p.tensors[edge_num], _vertex_in_edge(p.he2v[edge_num],decided_v), decided_vals.+1 , length(p.he2v[edge_num]))
        
        (count(==(Tropical(0.0)),st) == 1) || continue
        v = findfirst(==(Tropical(0.0)),st)
        pos_vals = bin_to_vec(v-1,bs.undecided_literals[edge_num])


        undecided_v = setdiff(p.he2v[edge_num], decided_v)

        bs, aedges = decide_literal(bs, p, undecided_v, pos_vals)

        reducing_queue = reducing_queue ∪ aedges
	end
	return bs
end

function slice_tensor(tensor::AbstractVector, mask::LongLongUInt, config::LongLongUInt, he2vi::Vector{Int})
    decided_v,decided_vals = lluint2vec(mask,config,he2vi)
    return slice_tensor(tensor, _vertex_in_edge(he2vi,decided_v), decided_vals.+1 , length(he2vi))
end

function decide_literal(bs::AbstractBranchingStatus, p::BooleanInferenceProblem, dls::Int, new_vals::Vector{Int})
    return decide_literal(bs, p,[dls],new_vals)
end
function decide_literal(bs::AbstractBranchingStatus, p::BooleanInferenceProblem, dls::Vector{Int}, new_vals::Vector{Int})
    vedges = [e for e in reduce(∪, [p.v2he[v] for v in dls]) if bs.undecided_literals[e] > 0]
    config = copy(bs.config)
    mask = bs.decided_mask | vec2lluint(dls,typeof(config))
    [config = config | 1 << (dls[i]-1) for i in 1:length(dls) if new_vals[i] == 1]
    undecided_literals = copy(bs.undecided_literals)
    aedges = Int[] # Edges that have been changed
    for edge_num in vedges
        st = slice_tensor(p.tensors[edge_num], mask, config, p.he2v[edge_num])
        if all(==(Tropical(0.0)),st)
            undecided_literals[edge_num] = -1
        else
            undecided_literals[edge_num] -= count(x -> x in dls, p.he2v[edge_num])
            push!(aedges, edge_num)
        end
	end
    return BranchingStatus(config, mask, undecided_literals), aedges
end

function decide_mask(mask::LongLongUInt, config::LongLongUInt,dls::Vector{Int}, new_vals::Vector{Int})
    mask = mask | vec2lluint(dls,typeof(config))
    [config = config | 1 << (i-1) for i in dls if new_vals[i] == 2]
    return masknew, config
end

function remove_zeros!(he2v, tensors)
    allzeros = [all(==(Tropical(0.0)), t) for t in tensors]
    he2v = he2v[.!allzeros]
    tensors = tensors[.!allzeros]
    return he2v, tensors
end

function remove_literal(vertices::Vector{Int}, p::BooleanInferenceProblem, clause::Clause{N}) where N
    data = fill(0, p.literal_num)
    decided_v = Int[]
    for (k, v) in enumerate(vertices)
        if readbit(clause.mask, k) == 1 
            push!(decided_v, v)
            if readbit(clause.val, k) == 1
                data[v] = 1
            end
        end
    end
    p_new = decide_literal(p, decided_v, data)
    return p_new, BooleanResult(true, 2, data).config
end

function decide_literal(p::BooleanInferenceProblem, vertices::Vector{Int}, data::Vector{Int})
    he2v = copy(p.he2v)
    tensors = copy(p.tensors)
    for v in vertices
        he2v, tensors,data = decide_literal!(he2v, tensors, v, data[v]+1,data)
    end
    return BooleanInferenceProblem(tensors, he2v, p.literal_num)
end

# TODO: Decide all literals once
function decide_literal!(he2v, tensors, v, v_val::Int,data)
	vedges = findall(x -> v in x, he2v)
    data[v] = v_val-1
	for edge_num in vedges
		v_num = findfirst(==(v), he2v[edge_num])
		if length(he2v[edge_num]) == 1
			tensors[edge_num] = [tensors[edge_num][fill(:, v_num - 1)..., v_val, fill(:, length(he2v[edge_num]) - v_num)...]]
		else
			tensors[edge_num] = tensors[edge_num][fill(:, v_num - 1)..., v_val, fill(:, length(he2v[edge_num]) - v_num)...]
		end
		he2v[edge_num] = setdiff(he2v[edge_num], [v])
	end
	return he2v, tensors,data
end

function decide_literal!(he2v, tensors, dls::Vector{Int}, new_vals::Vector{Int},data::Vector{Int})
    for i in 1:length(dls)
		v = dls[i]
		v_val = new_vals[i]
        he2v, tensors,data = decide_literal!(he2v, tensors, v, v_val,data)
	end
    return he2v, tensors, data
end

function _vertex_in_edge(he2vi,dls::Vector{Int})
    pos = Int[]
    for i in 1:length(dls)
        v = dls[i]
        if v in he2vi
            push!(pos, findfirst(==(v), he2vi))
        end
    end
    return pos
end

function _make_colon_vector(pos,vals,n::Int)
    return [i ∈ pos ? vals[findfirst(==(i),pos)] : (:) for i in 1:n]
end

function decide_literal!(he2v, tensors, v2he, dls::Vector{Int}, new_vals::Vector{Int},data::Vector{Int})
    # @show dls
    # @show new_vals
    # @show v2he
    vedges = reduce(∪, [v2he[v] for v in dls])
    # @show vedges
    [v2he[v] = Int[] for v in dls]
    # @show v2he
	for edge_num in vedges
        pos, vals = _vertex_in_edge(he2v[edge_num],dls,new_vals)
        colon_vec = _make_colon_vector(pos,vals,length(he2v[edge_num]))
        if length(pos) == length(he2v[edge_num])
            tensors[edge_num] = [tensors[edge_num][colon_vec...]]
        else
            tensors[edge_num] = tensors[edge_num][colon_vec...]
        end
		he2v[edge_num] = setdiff(he2v[edge_num], dls)
	end
    data[dls] = new_vals .- 1
	return he2v, tensors, data,v2he
end

function decide_literal!(he2v, tensors, v2he, dls::Int, new_vals::Int,data::Vector{Int})
    return decide_literal!(he2v, tensors, v2he, [dls], [new_vals], data)
end