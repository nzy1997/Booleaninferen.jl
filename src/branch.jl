function OptimalBranchingCore.apply_branch(p::BooleanInferenceProblem, clause::Clause{INT}, vertices::Vector{T}) where {INT<:Integer, T<:Integer}
    p_new, res = remove_literal(vertices, p, clause)
    p_new2, res2 = reduce_problem(p_new, DeductionReducer())
    return p_new2, res * res2
end

function OptimalBranchingCore.branch_and_reduce(problem::BooleanInferenceProblem, config::BranchingStrategy, reducer::AbstractReducer)
    stopped, res = check_stopped(problem) 
    stopped && return res

    rp, reducedvalue = reduce_problem(problem, reducer)
    # rp !== problem && return branch_and_reduce(rp, config, reducer) * reducedvalue

    # branch the problem
    subbip = select_variables(rp, config.measure, config.selector)  # select a subset of variables
    tbl = branching_table(rp, config.table_solver, subbip)      # compute the BranchingTable
    result = optimal_branching_rule(tbl, subbip.vs, rp, config.measure, config.set_cover_solver)  # compute the optimal branching rule
    for branch in result.optimal_rule.clauses
        subproblem, localvalue = apply_branch(rp, branch, subbip.vs)
        res = branch_and_reduce(subproblem, config, reducer) * (localvalue) * reducedvalue
        if res.rs == Tropical(0.0)
            return res
        end
    end
    return res
end

function check_stopped(problem::BooleanInferenceProblem)
    if isempty(problem.tensors)
        return true, one(BooleanResult{problem.literal_num, 1, 1})
    end
	if any([all(==(Tropical(-Inf)), t) for t in problem.tensors])
		return true, zero(BooleanResult{problem.literal_num, 1, 1})
	end
    return false, zero(BooleanResult{problem.literal_num, 1, 1})
end