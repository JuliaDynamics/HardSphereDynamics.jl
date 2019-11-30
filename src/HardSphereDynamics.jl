module HardSphereDynamics

export FixedPlane, MovableBall, HardSphereFluid
export initial_condition!, evolve!
export FreeFlow, ExternalFieldFlow
export ElasticCollision
export AllToAll
export HardSphereSimulation

# stdlib:
using LinearAlgebra

# libraries:
using StaticArrays
using Parameters
using Distributions

using Requires


function __init__()
    @require AbstractPlotting="537997a7-5e4e-5d89-9595-2241ea00577e" begin
        include("visualization/makie_visualization.jl")
    end
end


normsq(v) = sum(abs2, v)

# types:
include("ball.jl")
include("box.jl")
include("hard_sphere_fluid.jl")

# flow dynamics:
include("flow.jl")
include("free_flow.jl")
include("external_field_flow.jl")

# simulation:
include("collisions.jl")
include("event_handler.jl")
include("simulation.jl")


end # module
