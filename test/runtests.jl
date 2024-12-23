using BooleanInference
using Test

@testset "algebra.jl" begin
    include("algebra.jl")
end

@testset "interface.jl" begin
    include("interface.jl")
end

@testset "reducer.jl" begin
    include("reducer.jl")
end

@testset "selector.jl" begin
    include("selector.jl")
end

