mutable struct HardSphereSimulation{
    N, T,
    F<:HardSphereFluid{N,T},
    H<:AbstractEventHandler,
    L<:AbstractFlowDynamics,
    C<:AbstractCollisionDynamics
	}

    fluid::F
    event_handler::H
    flow_dynamics::L
    collision_dynamics::C
	current_time::T
end

HardSphereSimulation(fluid::HardSphereFluid{N,T}, event_handler, flow_dynamics, collision_dynamics) where {N,T}=
	HardSphereSimulation(fluid, event_handler, flow_dynamics, collision_dynamics, zero(T))



overlap(b1::MovableBall, b2::MovableBall) =
    normsq(b1.x - b2.x) < (b1.r + b2.r)^2

overlap(b::MovableBall, balls::Vector{MovableBall{N,T}}) where {N,T} =
    any(overlap.(Ref(b), balls))


"""
Generate initial condition for balls.

Uses random sequential deposition:
place a disc at a time and check that it doesn't overlap with any previously placed disc.

Generates allowed ball positions and uniform velocities.
"""
function initial_condition!(balls::Vector{MovableBall{N,T}}, box) where {N,T}

    U = Uniform.(box.lower .+ balls[1].r, box.upper .- balls[1].r)
    balls[1].x = rand.(U)

    for i = 2:length(balls)
        U = Uniform.(box.lower .+ balls[i].r, box.upper .- balls[i].r)
        balls[i].x = rand.(U)

        count = 0

        while overlap(balls[i], balls[1:i-1])
            balls[i].x = rand.(U)
            count += 1

            count > 10^5 && error("Unable to place disc $i")
        end
    end


    # generate velocities with sum(v_i^2) = 1:f
    for i = 1:length(balls)
        balls[i].v = @SVector randn(N)
    end

    sumsq = sum(normsq(balls[i].v) for i = 1:length(balls))

    for i = 1:length(balls)
        balls[i].v /= sqrt(sumsq)
    end
end

initial_condition!(fluid::HardSphereFluid) = initial_condition!(fluid.balls, fluid.box)


"Carry out collision assuming already at moment of collision"
function collide!(fluid::HardSphereFluid, event_handler, collision_dynamics)

	@unpack balls, box = fluid
	@unpack partner1, partner2, collision_type = event_handler

	if collision_type == :wall_collision
		collide!(balls[partner1], box.walls[partner2], collision_dynamics)

	elseif collision_type == :disc_collision
		collide!(balls[partner1], balls[partner2], collision_dynamics)

	else
		error("No collision")
	end

end




"""
	evolve!(fluid::HardSphereFluid, num_collisions::Integer)

Discrete-time evolution: Evolve fluid for `num_collisions` collisions.
Both sphere--sphere and sphere--wall collisions are counted as collisions.

Returns post-collision states, times at which collisions occur, and collision types.
"""
function evolve!(simulation::HardSphereSimulation{N,T}, num_collisions::Integer) where {N,T}

	@unpack fluid, flow_dynamics, collision_dynamics, event_handler = simulation

    # positions = [ [ball.x for ball in balls] ]
	# velocities = [ [ball.v for ball in balls] ]
	states = [deepcopy(fluid.balls)]
	times = [0.0]
	collision_types = [:none]


    for i in 1:num_collisions

		flow!(fluid.balls, (event_handler.next_collision_time - simulation.current_time), flow_dynamics)
		simulation.current_time = event_handler.next_collision_time

		push!(collision_types, event_handler.collision_type)

		collide!(fluid, event_handler, collision_dynamics)
		find_collision!(event_handler, fluid, flow_dynamics)

		push!(states, deepcopy(fluid.balls))
        push!(times, simulation.current_time)

    end

    return states, times, collision_types

end


"""
	flow!(fluid::HardSphereFluid, t)

Update hard sphere fluid by flowing for a time `t`, taking
account of possible collisions during that time.
"""

function flow!(simulation::HardSphereSimulation, t)

	@unpack fluid, flow_dynamics, collision_dynamics, event_handler = simulation
	# @unpack balls, box = fluid

	time_to_next_collision = event_handler.next_collision_time - simulation.current_time

	while t > time_to_next_collision
		t -= time_to_next_collision

		flow!(fluid.balls, time_to_next_collision, flow_dynamics)
		simulation.current_time += time_to_next_collision

		collide!(fluid, event_handler, collision_dynamics)
		find_collision!(event_handler, fluid, flow_dynamics)

		time_to_next_collision = event_handler.next_collision_time - simulation.current_time

	end

	flow!(fluid.balls, t, flow_dynamics)
	simulation.current_time += t

end


"""
	evolve!(fluid::HardSphereFluid, times)

Time evolution, calculating positions and velocities at given times.
"""
function evolve!(simulation::HardSphereSimulation{N,T}, times) where {N,T}

	@unpack fluid, flow_dynamics, collision_dynamics, event_handler = simulation

	states = [deepcopy(fluid.balls)]
	ts = [0.0]

	current_t = 0.0

	for t in times
		flow!(simulation, t - current_t)
        push!(states, deepcopy(fluid.balls))
		push!(ts, t)

		current_t = t
    end

    return states, ts
end


"""
	evolve!(fluid::HardSphereFluid, δt, final_time)

Calculate positions and velocities at times up to `final_time`,
spaced by `δt`.

"""
evolve!(simulation::HardSphereSimulation, δt, final_time) = evolve!(simulation, δt:δt:final_time)


#=
# states, times, collision_types = evolve!(simulation, 100);


using StaticArrays

box = HardSphereDynamics.RectangularBox(SA[-0.5, -0.5, -10.0],
					SA[+0.5, +0.5, +10.0])

fluid = HardSphereFluid{3,Float64}(box, 100, 0.05)
initial_condition!(fluid)
# flow_type = FreeFlow()
flow_type = ExternalFieldFlow(SA[0.0, 0.0, -1.0])

function run_simulation(N, r, flow_type)

	box = HardSphereDynamics.RectangularBox(SA[-0.5, -0.5, -3.0],
					SA[+0.5, +0.5, +3.0])

	fluid = HardSphereFluid{3,Float64}(box, N, r)

	initial_condition!(fluid)
	collision_type = ElasticCollision()
	event_handler = AllToAll(fluid, flow_type)

	simulation =  HardSphereSimulation(
		fluid, event_handler, flow_type, collision_type);

	states, times = evolve!(simulation, 0.01, 100);

	visualize_3d(states, sleep_step=0.005, lower=box.lower, upper=box.upper)
end


using Makie
visualize_3d(states, sleep_step=0.001, lower=box.lower, upper=box.upper)
=#
