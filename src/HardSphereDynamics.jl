module HardSphereDynamics

export FixedPlane, MovableBall, HardSphereFluid
export initial_condition!, evolve!


# stdlib:
using LinearAlgebra

# libraries:
using StaticArrays
using Parameters
using Distributions


normsq(v) = sum(abs2, v)

using Requires

function __init__()
    @require Makie="ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a" include("makie_visualization.jl")
end


include("box.jl")

include("ball.jl")
include("collisions.jl")
include("hard_sphere_fluid.jl")



end # module
