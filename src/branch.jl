function OptimalBranchingCore.apply_branch(p::BooleanInferenceProblem, clause::Clause{INT}, vertices::Vector{T}) where {INT<:Integer, T<:Integer}
    p_new, res = remove_literal(vertices, p, clause)
    p_new2, res2 = reduce_problem(p_new, DeductionReducer())
    return p_new2, (res * res2)
end

function OptimalBranchingCore.branch_and_reduce(problem::BooleanInferenceProblem, bs::AbstractBranchingStatus,config::BranchingStrategy, reducer::AbstractReducer,result_type)
    rp, reducedvalue = reduce_problem(problem, reducer)

    stopped, res = check_stopped(bs)
    stopped && return res, bs

    # branch the problem
    subbip = select_variables(rp, config.measure, config.selector)  # select a subset of variables
    tbl = branching_table(rp, config.table_solver, subbip)      # compute the BranchingTable
    result = optimal_branching_rule(tbl, subbip.vs, rp, config.measure, config.set_cover_solver)  # compute the optimal branching rule
    for branch in result.optimal_rule.clauses
        subproblem, localvalue = apply_branch(rp, branch, subbip.vs)
        res2 = branch_and_reduce(subproblem, config, reducer,result_type) * result_type(localvalue) * result_type(reducedvalue)
        res = res2 + res
        if res2.rs == Tropical(0.0)
            return res
        end
    end
    return res
end

function check_stopped(bs::AbstractBranchingStatus)
    # if there is no clause, then the problem is solved.
    if all(bs.undecided_literals .== -1)
        return true,true
    end
    if any(bs.undecided_literals .== 0)
        return true,false
    end
    return false,false
end

function check_stopped(problem::BooleanInferenceProblem,result_type)
    # if there is no clause, then the problem is solved.
    if isempty(problem.tensors)
        # @show "here"
        return true, one(result_type)
    end
    # if there is a clause with all -inf, then the problem is unsolvable.
	if any([all(==(Tropical(-Inf)), t) for t in problem.tensors])
        # @show "here2"
		return true, zero(result_type)
	end
    return false, zero_count(result_type)
end