function cnf2bip(cnf::CNF)
    return sat2bip(Satisfiability(cnf))
end

function sat2bip(sat::ConstraintSatisfactionProblem)
    problem = GenericTensorNetwork(sat)
    he2v = getixsv(problem.code)
    tensors = GenericTensorNetworks.generate_tensors(Tropical(1.0), problem)
    vec_tensors = [vec(t) for t in tensors]
    new_tensors = [replace(t,Tropical(1.0) => zero(Tropical{Float64})) for t in vec_tensors]
    return BooleanInferenceProblem(new_tensors, he2v, length(problem.problem.symbols)), problem.problem.symbols
end

function cir2bip(cir::Circuit)
    return sat2bip(CircuitSAT(cir))
end

function solvebip(sat::ConstraintSatisfactionProblem; bsconfig::BranchingStrategy = BranchingStrategy(table_solver = TNContractionSolver(), selector = KNeighborSelector(1,1), measure=NumOfVertices()), reducer=DeductionReducer())
    p,syms = sat2bip(sat)
    bs = initialize_branching_status(p)
    bs = deduction_reduce(p,bs,collect(1:length(p.he2v)))
    # ns,res = mybranch_and_reduce(p,bs, bsconfig, reducer)
    ns,res,count_num = branch_and_reduce(p,bs, bsconfig, reducer)
    @show count_num
    return ns,get_answer(res,p.literal_num)
end

function solve_factoring(n::Int, m::Int, N::Int; bsconfig::BranchingStrategy = BranchingStrategy(table_solver = TNContractionSolver(), selector =KNeighborSelector(1,1), measure=NumOfVertices()), reducer=DeductionReducer())
    # global BRANCHNUMBER = 0
    fproblem = Factoring(m, n, N)
    res = reduceto(CircuitSAT,fproblem)
    ans,vals = solvebip(res.circuit; bsconfig, reducer)
    a, b = ProblemReductions.read_solution(fproblem, [vals[res.p]...,vals[res.q]...])
    @show ans
    # @show BRANCHNUMBER
    return a,b
end

function solve_sat(sat::ConstraintSatisfactionProblem)
    res,vals = solvebip(sat)
    return res, Dict(zip(sat.symbols,vals))
end