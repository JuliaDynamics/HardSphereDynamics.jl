"""
Hard sphere fluid in N dimensions
"""
mutable struct HardSphereFluid{N,T}
	box::RectangularBox{N,T}
	balls::Vector{MovableBall{N,T}}

end



function HardSphereFluid(box::RectangularBox{N,T}, balls::Vector{MovableBall{N,T}}) where {N,T}
	partner1, partner2, collision_type, min_collision_time = find_collision(balls, box)
	current_time = zero(T)

	return HardSphereFluid{N,T}(box, balls, current_time, min_collision_time, partner1, partner2, collision_type)

end



function HardSphereFluid{N,T}(box::RectangularBox{N,T}, num_balls, r) where {N,T}

	balls = [MovableBall(zero(SVector{N,T}), zero(SVector{N,T}), r) for i in 1:num_balls]
	initial_condition!(balls, box)

	return HardSphereFluid(box, balls)
end

HardSphereFluid{N,T}(num_balls, r) where {N,T} = HardSphereFluid{N,T}(unit_hypercube(N, T), num_balls, r)

HardSphereFluid(N, num_balls, r) = HardSphereFluid{N,Float64}(num_balls, r)






"""
	evolve!(fluid::HardSphereFluid, num_collisions::Integer)

Evolve fluid for `num_collisions` collisions (sphere--sphere
and sphere--wall collisions are counted).

Returns positions and post-collisions velocities, as well as
times at which collisions occur and collision type.
"""
function evolve!(fluid::HardSphereFluid, num_collisions::Integer)

	@unpack balls, box, next_collision_time = fluid

    positions = [ [ball.x for ball in balls] ]
	velocities = [ [ball.v for ball in balls] ]
	times = [0.0]
	collision_types = [:none]

    for i in 1:num_collisions

		flow!(balls, (fluid.next_collision_time - fluid.current_time))
		fluid.current_time = fluid.next_collision_time

		push!(collision_types, fluid.collision_type)

		collide!(fluid)
		find_collision!(fluid)

        push!(positions, [ball.x for ball in balls])
		push!(velocities, [ball.v for ball in balls])
		push!(times, fluid.current_time)

    end

    return positions, velocities, times, collision_types

end


"""
	flow!(fluid::HardSphereFluid, t)

Update hard sphere fluid by flowing for a time `t`, taking
account of possible collisions during that time.
"""

function flow!(fluid::HardSphereFluid, t)

	@unpack balls, box = fluid

	time_to_next_collision = fluid.next_collision_time - fluid.current_time

	while t > time_to_next_collision
		t -= time_to_next_collision

		flow!(balls, time_to_next_collision)
		fluid.current_time += time_to_next_collision

		collide!(fluid)
		find_collision!(fluid)

		time_to_next_collision = fluid.next_collision_time - fluid.current_time

	end

	flow!(balls, t)
	fluid.current_time += t

end


"""
	evolve!(fluid::HardSphereFluid, times)

Time evolution, calculating positions and velocities at given times.
"""
function evolve!(fluid::HardSphereFluid, times)
	@unpack balls = fluid

	positions = [ [ball.x for ball in balls] ]
	velocities = [ [ball.v for ball in balls] ]
	ts = [0.0]

	current_t = 0.0

	for t in times
		flow!(fluid, t - current_t)
        push!(positions, [ball.x for ball in balls])
		push!(velocities, [ball.v for ball in balls])
		push!(ts, t)

		current_t = t
    end

    return positions, velocities, ts
end

"""
	evolve!(fluid::HardSphereFluid, δt, final_time)

Calculate positions and velocities at times up to `final_time`,
spaced by `δt`.

"""
evolve!(fluid::HardSphereFluid, δt, final_time) = evolve!(fluid, δt:δt:final_time)
