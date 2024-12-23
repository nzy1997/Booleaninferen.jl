struct BooleanInferenceProblem{C} <: AbstractProblem
    tensors::Vector{Vector{Tropical{Float64}}}
    he2v::Vector{Vector{Int}}
    v2he::Vector{Vector{Int}}
    literal_num::Int
end
# Base.isempty(p::BooleanInferenceProblem) = isempty(p.variables)
BooleanInferenceProblem(tensor::Vector{Vector{Tropical{Float64}}}, he2v::Vector{Vector{Int}},literal_num::Int)= BooleanInferenceProblem(tensor, _vectoint(literal_num,he2v), _vec2int(literal_num,[findall(x->i in x, he2v) for i in 1:literal_num]), literal_num)
# [findall(x->i in x, he2v) for i in 1:maximum(maximum,he2v)]
Base.copy(p::BooleanInferenceProblem) = BooleanInferenceProblem(copy(p.tensors), copy(p.he2v),copy(p.v2he), p.literal_num)

struct NumOfVertices <: AbstractMeasure end
OptimalBranchingCore.measure(p::BooleanInferenceProblem, ::NumOfVertices) = isempty(p.he2v) ? 0 : length(reduce(∪, p.he2v))

struct NumOfClauses <: AbstractMeasure end
OptimalBranchingCore.measure(p::BooleanInferenceProblem, ::NumOfClauses) = length(p.he2v)

function initialize_branching_status(p::BooleanInferenceProblem)
    t = (p.literal_num-1) ÷ 64 + 1
    return BranchingStatus{t}(LongLongUInt{t}(0), LongLongUInt{t}(0), length.(p.he2v))
end

function he2v2sparse(he2v::Vector{Vector{Int}})
    n = length(he2v)
    m = length(reduce(∪, he2v))
    sparse_matrix = spzeros(Bool, n, m)
    for i in 1:n
        sparse_matrix[i,he2v[i]] .= true
    end
    return sparse_matrix
end