module HardSphereDynamics

export FixedPlane, MovableBall, HardSphereFluid
export initial_condition!, evolve!


# stdlib:
using LinearAlgebra

# libraries:
using StaticArrays
using Parameters
using Distributions

using Requires


function __init__()
    @require AbstractPlotting="537997a7-5e4e-5d89-9595-2241ea00577e" include("makie_visualization.jl")
end


normsq(v) = sum(abs2, v)


include("box.jl")

include("ball.jl")
include("collisions.jl")
include("hard_sphere_fluid.jl")



end # module
