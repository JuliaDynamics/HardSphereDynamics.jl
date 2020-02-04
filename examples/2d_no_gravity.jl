using Revise, HardSphereDynamics, StaticArrays

table = HardSphereDynamics.RectangularBox(SA[-0.5, -0.5],
                                          SA[+0.5, +0.5])

N, r = 100, 0.02
fluid = HardSphereFluid{2,Float64}(table, N, r)
initial_condition!(fluid, lower=table.lower, upper=-table.lower)

collision_type = ElasticCollision()
flow_type = FreeFlow() # ExternalFieldFlow(SA[0.0, 0.0, -10.0])
event_handler = AllToAll(fluid, flow_type)

simulation =  HardSphereSimulation(
    fluid, event_handler, flow_type, collision_type);

states, times = evolve!(simulation, 0.01, 100);

states

states isa Vector{Vector{MovableBall{2,Float64,Float64}}}
states isa Vector{<:Vector{<:MovableBall{2}}}
MovableBall{2,Float64,Float64} <: MovableBall{2}


using Makie

visualize_2d(states)
#, sleep_step=0.005)#, lower=table.lower, upper=-table.lower)



using ForwardDiff

import ForwardDiff: Dual
