using BooleanInference
using BooleanInference.GenericTensorNetworks
using Test
using BooleanInference.GenericTensorNetworks: ∧, ∨, ¬
using BooleanInference.OptimalBranchingCore: reduce_problem
import BooleanInference.ProblemReductions: @circuit, Assignment,BooleanExpr


@testset "reduce_problem" begin
	@bools a b c d e f g
	cnf = ∧(∨(a, b, ¬d, ¬e), ∨(¬a, d, e, ¬f), ∨(f, g), ∨(¬b, c), ∨(¬a))
	bip, syms = cnf2bip(cnf)
	reduced_bip, res = reduce_problem(bip, DeductionReducer())
	@test reduced_bip.he2v == [[2, 3, 4], [5, 6], [2, 7]]

	@bools a b c d e
	cnf = ∧(∨(b), ∨(a, ¬c), ∨(d, ¬b), ∨(¬c, ¬d), ∨(a, e), ∨(a, e, ¬c))
	bip, syms = cnf2bip(cnf)
	reduced_bip, res = reduce_problem(bip, DeductionReducer())
	@test reduced_bip.he2v == [[2, 5]]
	@test res == ConfigSampler(StaticElementVector(2, [1, 0, 0, 1, 0]))

	circuit = @circuit begin
		c = x ∧ y
	end
	push!(circuit.exprs, Assignment([:c], BooleanExpr(true)))
	bip, syms = cir2bip(circuit)
	reduced_bip, res = reduce_problem(bip, DeductionReducer())
	@test reduced_bip.he2v == []
	@test reduced_bip.tensors == []
	@test res == ConfigSampler(StaticElementVector(2, [1, 1, 1]))
end

