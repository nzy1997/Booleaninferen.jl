struct DeductionReducer <: AbstractReducer end

function OptimalBranchingCore.reduce_problem(p::BooleanInferenceProblem, bs::AbstractBranchingStatus, reducing_queue::Vector{Int}, ::DeductionReducer)
	while !isempty(reducing_queue)
		isempty(reducing_queue) && break
		edge_num = popfirst!(reducing_queue)
		(bs.undecided_literals[edge_num] <= 0) && continue

		zerocount, sumpos = check_reduce(p.he2v[edge_num], bs, p.tensors[edge_num])
		(zerocount == 1) || continue

		bs, aedges = decide_literal(bs, p, p.he2v[edge_num], Clause(2^length(p.he2v[edge_num]) - 1, sumpos - 1))

		reducing_queue = reducing_queue ∪ aedges
	end
	return bs
end

function check_reduce(he2vi, mask, config, tensor)
	count = 0
	sum = 0
	decided_literal_num = 0
	for j in 1:length(he2vi)
		if readbit(mask, he2vi[j]) == 1
			sum += Int(readbit(config, he2vi[j])) * (1 << (j - 1))
			decided_literal_num += 1
		end
	end
	sumpos = 0
	for i in 0:2^(length(he2vi)-decided_literal_num)-1
		sum1 = sum
		counti = 0
		for j in 1:length(he2vi)
			if !(readbit(mask, he2vi[j]) == 1)
				counti += 1
				sum1 += (1 << (j - 1)) * readbit(i, counti)
			end
		end
		if tensor[sum1+1] == Tropical(0.0)
			count += 1
			sumpos = sum1 + 1
		end
	end
	return count, sumpos
end
function check_reduce(he2vi, bs::AbstractBranchingStatus, tensor)
	return check_reduce(he2vi, bs.decided_mask, bs.config, tensor)
end


function decide_literal(bs::AbstractBranchingStatus, p::BooleanInferenceProblem, vertices::Vector{Int}, clause::Clause{N}) where N
	data = Int[]
	decided_v = Int[]
	for (k, v) in enumerate(vertices)
		if readbit(clause.mask, k) == 1 && (readbit(bs.decided_mask, v) == 0)
			push!(decided_v, v)
			push!(data, Int(readbit(clause.val, k)))
		end
	end
	return decide_literal(bs, p, decided_v, data)
end

function decide_literal(bs::AbstractBranchingStatus, p::BooleanInferenceProblem, dls::Int, new_vals::Vector{Int})
	return decide_literal(bs, p, [dls], new_vals)
end
function decide_literal(bs::BranchingStatus{C}, p::BooleanInferenceProblem, dls::Vector{Int}, new_vals::Vector{Int}) where C
	config = copy(bs.config)
	mask = bs.decided_mask | vec2lluint(dls, typeof(config))
	for i in 1:length(dls)
		new_vals[i] == 1 || continue
		config = config | LongLongUInt{C}(1) << (dls[i] - 1)
	end
	undecided_literals = copy(bs.undecided_literals)
	aedges = Int[] # Edges that have been changed
    # testa = mapreduce(v -> p.v2he[v], ∪, dls)
	for edge_num in mapreduce(v -> p.v2he[v], ∪, dls)
		if bs.undecided_literals[edge_num] > 0
			zerocount, _ = check_reduce(p.he2v[edge_num], mask, config, p.tensors[edge_num])
			decided_num = count(x -> x in dls, p.he2v[edge_num])
			if (zerocount == 2^(undecided_literals[edge_num] - decided_num))
				undecided_literals[edge_num] = -1
			else
				undecided_literals[edge_num] -= decided_num
				push!(aedges, edge_num)
			end
		end
	end
	return BranchingStatus(config, mask, undecided_literals), aedges
end

function _vertex_in_edge(he2vi, dls::Vector{Int})
	pos = Int[]
	for i in 1:length(dls)
		v = dls[i]
		if v in he2vi
			push!(pos, findfirst(==(v), he2vi))
		end
	end
	return pos
end
