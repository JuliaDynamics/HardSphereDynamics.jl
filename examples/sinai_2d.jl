# using Revise
using HardSphereDynamics
using StaticArrays
using LinearAlgebra

box = HardSphereDynamics.unit_hypercube(2, Float64)

balls = [MovableBall(SVector(0.0, 0.0), SVector(0.0, 0.0), 0.2, Inf),
        MovableBall(SVector(0.3, 0.0), normalize(SVector(1.0, sqrt(2))), 0.1)]

fluid = HardSphereFluid(box, balls)
