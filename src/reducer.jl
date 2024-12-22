struct DeductionReducer <: AbstractReducer end

function OptimalBranchingCore.reduce_problem(p::BooleanInferenceProblem, ::DeductionReducer) where R
    he2v = copy(p.he2v)
	tensors = copy(p.tensors)
    
    data = fill(0, p.literal_num)
	while true
        he2v, tensors = remove_zeros!(he2v, tensors)
        unitedge = findfirst(x -> count(==(Tropical(0.0)),x) == 1 ,tensors)
        isnothing(unitedge) && break
		vs = he2v[unitedge]
        v_val = findfirst(==(Tropical(0.0)), tensors[unitedge])
        if v_val isa CartesianIndex
            v_val = collect(v_val.I)
        else
            vs = vs[1]
        end
		he2v, tensors, data = decide_literal!(he2v, tensors, vs, v_val, data)
	end
	return BooleanInferenceProblem(tensors, he2v, p.literal_num), BooleanResult(true, p.literal_num, data)
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
    return p_new, BooleanResult(true, p.literal_num, data)
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