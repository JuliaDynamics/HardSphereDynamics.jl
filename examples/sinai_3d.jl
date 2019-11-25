# using Revise
using HardSphereDynamics
using StaticArrays
using LinearAlgebra

box = HardSphereDynamics.unit_hypercube(3, Float64)

balls = [MovableBall(SVector(0.0, 0.0, 0.0), SVector(0.0, 0.0, 0.0), 0.2, Inf),
        MovableBall(SVector(0.3, 0.0, 0.0), normalize(SVector(1.0, sqrt(2), sqrt(3))), 0.1)]

fluid = HardSphereFluid(box, balls)

δt = 0.01
final_time = 100
positions, velocities, times = evolve!(fluid, δt, final_time)  # return data at given times


# using Plots

using Makie

visualize_3d(fluid, positions, velocities)
