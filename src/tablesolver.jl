struct TNContractionSolver <: AbstractTableSolver end

function OptimalBranchingCore.branching_table(bip::BooleanInferenceProblem, bs::AbstractBranchingStatus,solver::TNContractionSolver, subbip::SubBIP)
    decided_v = [ i for i in 1:bip.literal_num if readbit(bs.decided_mask, i) == 1]
    subhe2v = [setdiff(bip.he2v[e], decided_v) for e in 1: length(bip.he2v)]

    eincode = DynamicEinCode{Int}(subhe2v[subbip.edges], subbip.vs)
	optcode = optimize_code(eincode, uniformsize(eincode, 2), GreedyMethod())

    sub_tensors = optcode([vec2tensor(slice_tensor(bip.tensors[e],bs.decided_mask,bs.config,bip.he2v[e])) for e in subbip.edges]...)

	# sub_tensors = optcode(((bip.tensors[subbip.edges]))...)
	out_vs_num = length(subbip.outside_vs_ind)
	vs_num = length(subbip.vs)
	ind_pos = [i ∈ subbip.outside_vs_ind ? findfirst(==(i), subbip.outside_vs_ind) : findfirst(==(i), setdiff(1:vs_num, subbip.outside_vs_ind)) for i in 1:vs_num]
	possible_configurations = Vector{Vector{Bool}}[]
	for i in 0:(2^out_vs_num-1)
		answer = [i & (1 << j) != 0 for j in 0:out_vs_num-1]
		out_index = [i ? 2 : 1 for i in answer]
		vec = [i ∈ subbip.outside_vs_ind ? out_index[ind_pos[i]] : (:) for i in 1:vs_num]
		new_tensors = sub_tensors[vec...]
		in_indies = findall(==(Tropical(0.0)), new_tensors)
		if length(in_indies) == 0
			continue
		end
		pcs = [[i ∈ subbip.outside_vs_ind ? out_index[ind_pos[i]] : in_index[ind_pos[i]] for i in 1:vs_num] .== fill(2, vs_num) for in_index in in_indies]
		push!(possible_configurations, pcs)
	end
	return BranchingTable(vs_num, possible_configurations)
end