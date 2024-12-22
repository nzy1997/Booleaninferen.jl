function cnf2bip(cnf::CNF)
    return sat2bip(Satisfiability(cnf))
end

function sat2bip(sat::ConstraintSatisfactionProblem)
    problem = GenericTensorNetwork(sat)
    he2v = getixsv(problem.code)
    tensors = GenericTensorNetworks.generate_tensors(Tropical(1.0), problem)
    new_tensors = [replace(t,Tropical(1.0) => zero(Tropical{Float64})) for t in tensors]
    return BooleanInferenceProblem(new_tensors, he2v, length(problem.problem.symbols))
end

function cir2bip(cir::Circuit)
    return sat2bip(CircuitSAT(cir))
end

function solvebip(sat::ConstraintSatisfactionProblem; bs::BranchingStrategy = BranchingStrategy(table_solver = TNContractionSolver(), selector = KNeighborSelector(2), measure=NumOfVertices()), reducer=DeductionReducer())
    p = sat2bip(sat)
    res = branch_and_reduce(p, bs, reducer)
    return get_answer(res)
end

function solvebip(cnf::CNF)
    return solvebip(Satisfiability(cnf))
    Dict(zip(symbols,tnp.vals))
end
