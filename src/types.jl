struct BooleanInferenceProblem <: AbstractProblem
    tensors::Vector{Array{Tropical{Float64}}}
    he2v::Vector{Vector{Int}}
    v2he::Vector{Vector{Int}}
    literal_num::Int
end
# Base.isempty(p::BooleanInferenceProblem) = isempty(p.variables)
BooleanInferenceProblem(tensor::Vector{Array{Tropical{Float64}}}, he2v::Vector{Vector{Int}},literal_num::Int)= BooleanInferenceProblem(tensor, he2v, [findall(x->i in x, he2v) for i in 1:literal_num], literal_num)
# [findall(x->i in x, he2v) for i in 1:maximum(maximum,he2v)]
Base.copy(p::BooleanInferenceProblem) = BooleanInferenceProblem(copy(p.tensors), copy(p.he2v),copy(p.v2he), p.literal_num)

struct NumOfVertices <: AbstractMeasure end
OptimalBranchingCore.measure(p::BooleanInferenceProblem, ::NumOfVertices) = isempty(p.he2v) ? 0 : length(reduce(∪, p.he2v))

struct NumOfClauses <: AbstractMeasure end
OptimalBranchingCore.measure(p::BooleanInferenceProblem, ::NumOfClauses) = length(p.he2v)