using BooleanInference
using Test

@testset "algebra" begin
    br1 = BooleanResult(false, 5, [1, 0,0,0,1])
    br2 = BooleanResult(true, 5, [1, 0,0,0,1])
    br3 = BooleanResult(true, 5, [1, 1,1,0,0])

    @test br1*br2 == BooleanResult(false, 5, [1, 0,0,0,1])
    @test br2*br3 == BooleanResult(true, 5, [1, 1,1,0,1])

    brone = one(BooleanResult{5,Int,Vector{Int}})
    @test brone == BooleanResult(Tropical(0.0), ConfigSampler(StaticElementVector(5, fill(0, 5))))
    @test brone*br2 == br2
    @test br2*brone == br2
    @test brone*br1 == br1
    @test br1*brone == br1

    brzero = zero(BooleanResult{5,Int,Vector{Int}})
    @test brzero == BooleanResult(Tropical(-Inf), ConfigSampler(StaticElementVector(5, fill(0, 5))))
end