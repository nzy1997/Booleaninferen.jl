function OptimalBranchingCore.apply_branch(p::BooleanInferenceProblem, bs::AbstractBranchingStatus,clause::Clause{INT}, vertices::Vector{T}) where {INT<:Integer, T<:Integer}
    bs_new, aedges = decide_literal(bs,p, vertices, clause)
    return reduce_problem(p, bs_new, aedges,DeductionReducer())
end

function OptimalBranchingCore.branch_and_reduce(problem::BooleanInferenceProblem, bs::AbstractBranchingStatus,config::BranchingStrategy, reducer::AbstractReducer)
    stopped, res = check_stopped(bs)
    stopped && return res, bs

    # branch the problem
    subbip = select_variables(problem, bs, config.measure, config.selector)  # select a subset of variables
    tbl = branching_table(problem,bs, config.table_solver, subbip)      # compute the BranchingTable
    result = optimal_branching_rule(tbl, subbip.vs, bs,problem, config.measure, config.set_cover_solver)  # compute the optimal branching rule
    for branch in result.optimal_rule.clauses
        res, bs_new = branch_and_reduce(problem, apply_branch(problem,bs, branch, subbip.vs), config, reducer)
        if res
            return res, bs_new
        end
    end
    return false, bs
end

function check_stopped(bs::AbstractBranchingStatus)
    # global BRANCHNUMBER
    # if there is no clause, then the problem is solved.
    if all(bs.undecided_literals .== -1)
        # BRANCHNUMBER += 1
        return true,true
    end
    if any(bs.undecided_literals .== 0)
        # BRANCHNUMBER += 1
        return true,false
    end
    return false,false
end

function OptimalBranchingCore.optimal_branching_rule(table::BranchingTable, variables::Vector, bs::AbstractBranchingStatus,p::BooleanInferenceProblem, m::AbstractMeasure, solver::AbstractSetCoverSolver)
    candidates = collect(candidate_clauses(table))
    size_reductions = [measure(bs, m) - measure((apply_branch(p,bs, candidate, variables)), m) for candidate in candidates]
    return minimize_γ(table, candidates, size_reductions, solver; γ0=2.0)
end

function mybranch_and_reduce(problem::BooleanInferenceProblem, bs::AbstractBranchingStatus,config::BranchingStrategy, reducer::AbstractReducer)
    stopped, res = check_stopped(bs)
    stopped && return res, bs

    v = findfirst(x -> readbit(bs.decided_mask,x) == 0, 1:problem.literal_num)

    res, bs_new = branch_and_reduce(problem, apply_branch(problem,bs, Clause(0b1, 0b1), [v]), config, reducer)
    if res
        return res, bs_new
    end

    res, bs_new = branch_and_reduce(problem, apply_branch(problem,bs, Clause(0b1, 0b0), [v]), config, reducer)
    if res
        return res, bs_new
    end

    return false, bs
end
