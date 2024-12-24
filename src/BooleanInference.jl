module BooleanInference

using SparseArrays
using OptimalBranchingCore
using OptimalBranchingCore: AbstractProblem,select_variables,apply_branch,reduce_problem,_vec2int
using OptimalBranchingCore.BitBasis
using GenericTensorNetworks
using GenericTensorNetworks.OMEinsum
import ProblemReductions
import ProblemReductions: CircuitSAT,Circuit,Factoring,reduceto

# using GenericTensorNetworks: ∧, ∨, ¬

# status
export BranchingStatus, initialize_branching_status
# stride 
export tensor2vec,get_tensor_number,slice_tensor, vec2tensor,vec2lluint,lluint2vec
# types
export BooleanInferenceProblem,BooleanResultBranchCount

# algebra
export BooleanResult

# interface
export cnf2bip,cir2bip,sat2bip,solvebip,solve_factoring,solve_sat,solve_factoring_count

# reducer
export DeductionReducer,decide_literal

# selector
export KNeighborSelector,neighboring,k_neighboring,neighbor_subbip

include("status.jl")
include("stride.jl")
include("types.jl")
include("algebra.jl")
include("interface.jl")
include("reducer.jl")
include("selector.jl")
include("tablesolver.jl")
include("branch.jl")
end
