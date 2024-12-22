function cnf2bip(cnf::CNF)
    return sat2bip(Satisfiability(cnf))
end

function sat2bip(sat::ConstraintSatisfactionProblem)
    problem = GenericTensorNetwork(sat)
    he2v = getixsv(problem.code)
    tensors = GenericTensorNetworks.generate_tensors(Tropical(1.0), problem)
    new_tensors = [replace(t,Tropical(1.0) => zero(Tropical{Float64})) for t in tensors]
    return BooleanInferenceProblem(new_tensors, he2v, length(problem.problem.symbols)), problem.problem.symbols
end

function cir2bip(cir::Circuit)
    return sat2bip(CircuitSAT(cir))
end

function solvebip(sat::ConstraintSatisfactionProblem; bs::BranchingStrategy = BranchingStrategy(table_solver = TNContractionSolver(), selector = KNeighborSelector(2), measure=NumOfVertices()), reducer=DeductionReducer())
    p,syms = sat2bip(sat)
    res = branch_and_reduce(p, bs, reducer)
    return get_answer(res), res.config.data[1:p.literal_num] .== one(UInt64)
end

function factoring(n::Int, m::Int, N::Int)
    fproblem = Factoring(m, n, N)
    res = reduceto(CircuitSAT,fproblem)
    ans,vals = solvebip(res.circuit)
    a, b = ProblemReductions.read_solution(fproblem, [vals[res.p]...,vals[res.q]...])
    return a,b
end