using BooleanInference
using Test
using BooleanInference.GenericTensorNetworks: ∧, ∨, ¬
using BooleanInference.OptimalBranchingCore: select_variables

@testset "neighboring" begin
    @bools a b c d e
    cnf = ∧(∨(b), ∨(a,¬c), ∨(d,¬b), ∨(¬c,¬d), ∨(a,e), ∨(a,e,¬c))
    bip,syms = cnf2bip(cnf)

    subbip = neighboring(bip,1)
    @test subbip == [1, 4]

    subbip = neighboring(bip,2)
    @test subbip == [2, 3, 5]
end

@testset "k_neighboring" begin
    @bools a b c d e
    cnf = ∧(∨(b), ∨(a,¬c), ∨(d,¬b), ∨(¬c,¬d), ∨(a,e), ∨(a,e,¬c))
    bip,syms = cnf2bip(cnf)

    subbip = k_neighboring(bip,1,2)
    @test subbip == [1, 3, 4]

    subbip = k_neighboring(bip,2,2)
    @test subbip == [2, 3, 4, 5]
end

@testset "KNeighborSelector,neighbor_subbip" begin
    @bools a b c d e f g
    cnf = ∧(∨(a, b, ¬d, ¬e), ∨(¬a, d, e, ¬f), ∨(f, g), ∨(¬b, c))
    sat = Satisfiability(cnf)
    bip,syms = sat2bip(sat)

    subbip = select_variables(bip,BooleanInference.NumOfVertices(),KNeighborSelector(2))
    @test subbip.vs == collect(1:7)
    @test subbip.edges == collect(1:4)
    @test subbip.outside_vs_ind == []

    subbip = neighbor_subbip(bip,neighboring(bip,7))
    @test subbip.vs == [1, 2, 3, 4, 7]
    @test subbip.edges == [1,4]
    @test subbip.outside_vs_ind == [1,3,4]
end