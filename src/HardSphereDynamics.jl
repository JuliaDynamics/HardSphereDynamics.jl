module HardSphereDynamics

export FixedPlane, MovableBall, HardSphereFluid
export initial_condition!, time_evolution!


# stdlib:
using LinearAlgebra

# libraries:
using StaticArrays
using Parameters
using Distributions


normsq(v) = sum(abs2, v)


include("box.jl")

include("ball.jl")
include("collisions.jl")
include("hard_sphere_fluid.jl")



end # module
