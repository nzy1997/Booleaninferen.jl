using BooleanInference
using Test
using BooleanInference.GenericTensorNetworks

@testset "algebra" begin
    br1 = BooleanResult(false, 2, [1, 0,0,0,1])
    br2 = BooleanResult(true, 2, [1, 0,0,0,1])
    br3 = BooleanResult(true, 2, [1, 1,1,0,0])

    @test br1*br2 == BooleanResult(false, 2, [1, 0,0,0,1])
    @test br2*br3 == BooleanResult(true, 2, [1, 1,1,0,1])

    brone = one(BooleanResult{5,1,1})
    @test brone == BooleanResult(Tropical(0.0), ConfigSampler(StaticElementVector(2, fill(0, 5))))
    @test brone*br2 == br2
    @test br2*brone == br2
    @test brone*br1 == br1
    @test br1*brone == br1

    brzero = zero(BooleanResult{5,1,1})
    @test brzero == BooleanResult(Tropical(-Inf), ConfigSampler(StaticElementVector(2, fill(0, 5))))
end