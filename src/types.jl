struct BooleanInferenceProblem <: AbstractProblem
    tensors::Vector{Array{Tropical{Float64}}}
    he2v::Vector{Vector{Int}}
    literal_num::Int
end
# Base.isempty(p::BooleanInferenceProblem) = isempty(p.variables)
Base.copy(p::BooleanInferenceProblem) = BooleanInferenceProblem(copy(p.tensors), copy(p.he2v), p.literal_num)

struct NumOfVertices <: AbstractMeasure end
OptimalBranchingCore.measure(p::BooleanInferenceProblem, ::NumOfVertices) = isempty(p.he2v) ? 0 : length(reduce(∪, p.he2v))

struct NumOfClauses <: AbstractMeasure end
OptimalBranchingCore.measure(p::BooleanInferenceProblem, ::NumOfClauses) = length(p.he2v)