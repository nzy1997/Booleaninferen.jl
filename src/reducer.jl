struct DeductionReducer <: AbstractReducer end

function OptimalBranchingCore.reduce_problem(p::BooleanInferenceProblem, bs::AbstractBranchingStatus, reducing_queue::Vector{Int}, ::DeductionReducer)
    he2v = copy(p.he2v)
	tensors = copy(p.tensors)
    v2he = copy(p.v2he)
    data = fill(0, p.literal_num)
	while !isempty(reducing_queue)
        edge_num = popfirst!(reducing_queue)
        slice_tensor(p.tensors[edge_num], he2v[edge_num], edge_num, data)
        he2v, tensors = remove_zeros!(he2v, tensors)
        unitedge = findfirst(x -> count(==(Tropical(0.0)),x) == 1 ,tensors)
        # @show unitedge
        # @show tensors[unitedge]
        # @show he2v[unitedge]
        isnothing(unitedge) && break
		vs = he2v[unitedge]
        v_val = findfirst(==(Tropical(0.0)), tensors[unitedge])
        if v_val isa CartesianIndex
            v_val = collect(v_val.I)
        else
            vs = vs[1]
        end
		he2v, tensors, data = decide_literal!(he2v, tensors, vs, v_val, data)
        # he2v, tensors, data,v2he = decide_literal!(he2v, tensors,v2he, vs, v_val, data)
	end
	return BooleanInferenceProblem(tensors, he2v,v2he, p.literal_num), BooleanResult(true, 2, data).config
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

function _vertex_in_edge(he2vi,dls::Vector{Int},new_vals::Vector{Int})
    pos = Int[]
    vals = Int[]
    for i in 1:length(dls)
        v = dls[i]
        if v in he2vi
            push!(pos, findfirst(==(v), he2vi))
            push!(vals, new_vals[i])
        end
    end
    return pos, vals
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