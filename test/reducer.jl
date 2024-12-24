using BooleanInference
using BooleanInference.GenericTensorNetworks
using Test
using BooleanInference.GenericTensorNetworks: ∧, ∨, ¬
using BooleanInference.OptimalBranchingCore: reduce_problem
import BooleanInference.ProblemReductions: @circuit, Assignment,BooleanExpr
using BooleanInference.OptimalBranchingCore.BitBasis


@testset "reduce_problem" begin
	@bools a b c d e f g
	cnf = ∧(∨(a, b, ¬d, ¬e), ∨(¬a, d, e, ¬f), ∨(f, g), ∨(¬b, c), ∨(¬a))
	bip, syms = cnf2bip(cnf)
    bs = initialize_branching_status(bip)
	bsnew = reduce_problem(bip, bs, collect(1:5),DeductionReducer())
	@test bsnew.decided_mask == 1
    @test bsnew.config == 0
    @test bsnew.undecided_literals == [3,-1,2,2,-1]

	@bools x1 x2 x3 x4 x5
	cnf = ∧(∨(x1), ∨(x2, ¬x3), ∨(x4, ¬x1), ∨(¬x3, ¬x4), ∨(x2, x5), ∨(x2, x5, ¬x3))
	bip, syms = cnf2bip(cnf)
	bs = initialize_branching_status(bip)
	bsnew = reduce_problem(bip, bs, collect(1:6),DeductionReducer())
	@test bsnew.decided_mask == 13
    @test bsnew.config == 9
    @test bsnew.undecided_literals == [-1,-1,-1,-1,2,-1]

	circuit = @circuit begin
		c = x ∧ y
	end
	push!(circuit.exprs, Assignment([:c], BooleanExpr(true)))
	bip, syms = cir2bip(circuit)
    bs = initialize_branching_status(bip)
	bsnew = reduce_problem(bip, bs, collect(1:2),DeductionReducer())
    @test bsnew.decided_mask == 7
    @test bsnew.config == 7
    @test bsnew.undecided_literals == [-1,-1]
end

@testset "decide_literal" begin
    @bools a b c d e f g
    cnf = ∧(∨(a, b, ¬d, ¬e), ∨(¬a, d, e, ¬f), ∨(f, g), ∨(¬b, c))
	bip, syms = cnf2bip(cnf)
    bs = initialize_branching_status(bip)
    bs_new ,aedges = decide_literal(bs,bip,[1,2],[0,1])
    @test bs_new.undecided_literals == [-1,-1,2,1]
    @test bs_new.config == 2
    @test bs_new.decided_mask == 3
    @test aedges == [4]
end
