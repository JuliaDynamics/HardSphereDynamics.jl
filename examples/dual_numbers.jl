using Revise, HardSphereDynamics, StaticArrays

table = HardSphereDynamics.RectangularBox(SA[-0.5, -0.5],
                                          SA[+0.5, +0.5])

N, r = 10, 0.1
fluid = HardSphereFluid{2,Float64}(table, N, r)
initial_condition!(fluid, lower=table.lower, upper=-table.lower)

collision_type = ElasticCollision()
flow_type = FreeFlow() # ExternalFieldFlow(SA[0.0, 0.0, -10.0])
event_handler = AllToAll(fluid, flow_type)

simulation =  HardSphereSimulation(
    fluid, event_handler, flow_type, collision_type);

states, times = evolve!(simulation, 0.01, 100);

states



using ForwardDiff

import ForwardDiff: Dual

simulation

state = HardSphereDynamics.state(simulation)

length(state)

function make_duals(v::Vector{SVector{N,T}}, M) where {N,T}

    vv = reduce(vcat, v)  # all components as a single vector
    NN = length(vv)

    duals = [Dual(vv[i], ntuple(j -> M[i, j], Val(NN))) for i in 1:length(vv)]

    return [SVector{N}(duals[i:i+N-1]) for i in 1:N:NN]


    # TODO
end


using LinearAlgebra

duals = make_duals(state, I)

length(duals)

n = length(duals) ÷ 2

state[1:n]

simulation

simulation.fluid


duals[1:n]

duals

new_simulation = HardSphereSimulation(simulation, duals)

event_handler = new_simulation.event_handler

HardSphereDynamics.evolve!(new_simulation, 0.1, 1.0)
