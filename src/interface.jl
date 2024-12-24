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

function solvebip(sat::ConstraintSatisfactionProblem; bsconfig::BranchingStrategy = BranchingStrategy(table_solver = TNContractionSolver(), selector = KNeighborSelector(2), measure=NumOfVertices()), reducer=DeductionReducer())
    p,syms = sat2bip(sat)
    bs = initialize_branching_status(p)
    bs = reduce_problem(p,bs,collect(1:p.literal_num),reducer)
    ns,res = branch_and_reduce(p,bs, bsconfig, reducer)
    return ns,get_answer(res,p.literal_num)
end

function solve_factoring(n::Int, m::Int, N::Int)
    fproblem = Factoring(m, n, N)
    res = reduceto(CircuitSAT,fproblem)
    ans,vals = solvebip(res.circuit)
    a, b = ProblemReductions.read_solution(fproblem, [vals[res.p]...,vals[res.q]...])
    return a,b
end

function solve_sat(sat::ConstraintSatisfactionProblem)
    res,vals = solvebip(sat)
    return res, Dict(zip(sat.symbols,vals))
end


function solve_factoring_count(n::Int, m::Int, N::Int)
    fproblem = Factoring(m, n, N)
    res = reduceto(CircuitSAT,fproblem)
    ns,vals,count =  solvebip_count(res.circuit)
    a, b = ProblemReductions.read_solution(fproblem, [vals[res.p]...,vals[res.q]...])
    @show count
    return a,b
end

function solvebip_count(sat::ConstraintSatisfactionProblem; bs::BranchingStrategy = BranchingStrategy(table_solver = TNContractionSolver(), selector = KNeighborSelector(2), measure=NumOfVertices()), reducer=DeductionReducer())
    p,syms = sat2bip(sat)
    res = branch_and_reduce(p, bs, reducer,typeof(BooleanResultBranchCount(true, 2, fill(0,p.literal_num))))
    return get_answer(res,p.literal_num)
end

function solve_factoring_count(p1::Int, p2::Int)
    n = Int(ceil(log2(p1+1)))
    m = Int(ceil(log2(p2+1)))
    N = p1*p2
    println("n = $n, m = $m, N = $N")
    return solve_factoring_count(n,m,N)
end