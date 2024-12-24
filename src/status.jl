abstract type AbstractBranchingStatus end
struct BranchingStatus{C} <: AbstractBranchingStatus
    config::LongLongUInt{C}
    decided_mask::LongLongUInt{C}
    undecided_literals::Vector{Int} # undecided literals in each clause, 0 means unsatisfiable, -1 means already satisfied
end

struct BranchingStatusBranchCount{C} <: AbstractBranchingStatus
    config::LongLongUInt{C}
    decided_mask::LongLongUInt{C}
    undecided_literals::Vector{Int} # undecided literals in each clause, 0 means unsatisfiable, -1 means already satisfied
    count::Int
end

function get_answer(bs::BranchingStatus,n::Int)
    return [Int(readbit(bs.config,i)) for i in 1:n]
end