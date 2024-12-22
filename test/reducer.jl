using BooleanInference
using BooleanInference.GenericTensorNetworks
using Test
using BooleanInference.GenericTensorNetworks: ∧, ∨, ¬
using BooleanInference.OptimalBranchingCore: reduce_problem


@testset "reduce_problem" begin
    @bools a b c d e f g
    cnf = ∧(∨(a, b, ¬d, ¬e), ∨(¬a, d, e, ¬f), ∨(f, g), ∨(¬b, c), ∨(¬a))
    bip = cnf2bip(cnf)
    reduced_bip,res = reduce_problem(bip,DeductionReducer())
    @test reduced_bip.he2v == [[2, 3, 4], [5, 6], [2, 7]]
    @test res.rs == Tropical(0.0)

    @bools a b c d e
    cnf = ∧(∨(b), ∨(a,¬c), ∨(d,¬b), ∨(¬c,¬d), ∨(a,e), ∨(a,e,¬c))
    bip = cnf2bip(cnf)
    reduced_bip,res = reduce_problem(bip,DeductionReducer())
    @test reduced_bip.he2v == [[2, 5]]
    @test res == BooleanResult(true, 5, [1, 0,0,1,0])

    circuit = @circuit begin
        c = x ∧ y
    end
    push!(circuit.exprs, Assignment([:c],BooleanExpr(true)))
    bip = cir2bip(circuit)
    reduced_bip,res = reduce_problem(bip,DeductionReducer())
    @test reduced_bip.he2v == []
    @test reduced_bip.tensors == []
    @test res == BooleanResult(true, 3, [1, 1, 1])
end

