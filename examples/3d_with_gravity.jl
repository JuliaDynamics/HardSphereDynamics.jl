using HardSphereDynamics, StaticArrays

table = HardSphereDynamics.RectangularBox(SA[-0.5, -0.5, -1.0],
                SA[+0.5, +0.5, +3.0])

fluid = HardSphereFluid{3,Float64}(table, N, r)

initial_condition!(fluid, lower=table.lower, upper=-table.lower)
collision_type = ElasticCollision()

flow_type = ExternalFieldFlow(SA[0.0, 0.0, -10.0])
event_handler = AllToAll(fluid, flow_type)

simulation =  HardSphereSimulation(
    fluid, event_handler, flow_type, collision_type);

states, times = evolve!(simulation, 0.01, 100);


using Makie

visualize_3d(states, sleep_step=0.005, lower=table.lower, upper=-table.lower)
