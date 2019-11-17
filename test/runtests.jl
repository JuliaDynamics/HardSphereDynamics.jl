using HardSphereDynamics

using LinearAlgebra
using Test

using StaticArrays


import HardSphereDynamics: normal, collision_time, flow!, collide!

@testset "HardSphereDynamics.jl" begin

    b = MovableBall(SVector(0.0, 0.0), SVector(1.0, 0.0), 2.0)
    @test normal(b, SVector(2.0, 0.0)) == SVector(1.0, 0.0)

    Π = FixedPlane(SVector(10, 0), SVector(1, 0))
    @test collision_time(b, Π) == 8

    b1 = MovableBall(SVector(0.0, 0.0), normalize(SVector(1.0, 0.0)), 1.0)
    b2 = MovableBall(SVector(10.0, 0.5), normalize(SVector(-1.0, 0.0)), 1.0)

    @test collision_time(b1, b2) == 4.031754163448146

    flow!(b1, t)
    flow!(b2, t)

    collide!(b1, b2)

    @test b1.v == SVector(-0.8750000000000002, -0.48412291827592724)

end
