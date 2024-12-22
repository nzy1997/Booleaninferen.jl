module BooleanInference

using OptimalBranchingCore
using OptimalBranchingCore: AbstractProblem,select_variables,apply_branch
using OptimalBranchingCore.BitBasis
using GenericTensorNetworks
using GenericTensorNetworks.OMEinsum
import ProblemReductions: CircuitSAT,Circuit
# using GenericTensorNetworks: ∧, ∨, ¬

# types
export BooleanInferenceProblem

# algebra
export BooleanResult

# interface
export cnf2bip,cir2bip,sat2bip,solvebip

# reducer
export DeductionReducer

# selector
export KNeighborSelector,neighboring,k_neighboring,neighbor_subbip

include("types.jl")
include("algebra.jl")
include("interface.jl")
include("reducer.jl")
include("selector.jl")
include("tablesolver.jl")
include("branch.jl")
end
