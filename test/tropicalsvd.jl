using Test
using TropicalNumbers
using Random

m = 5
n = 5
Random.seed!(1234)
c = [TropicalAndOr(rand()>0.5) for i in 1:m, j in 1:n]

