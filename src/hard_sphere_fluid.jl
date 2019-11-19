"""
Hard sphere fluid in N dimensions
"""
mutable struct HardSphereFluid{N,T}
	box::RectangularBox{N,T}
	balls::Vector{MovableBall{N,T}}
	current_time::T
	next_collision_time::T
	partner1::Int
	partner2::Int
	collision_type::Symbol
end


overlap(b1::MovableBall, b2::MovableBall) = normsq( b1.x - b2.x ) < (b1.r + b2.r)^2

overlap(b::MovableBall, balls::Vector{MovableBall{N,T}}) where {N,T} = any(overlap.(Ref(b), balls))


"""
Generate initial condition for balls.

Uses random sequential deposition:
place a disc at a time and check that it doesn't overlap with any previously placed disc.
"""
function initial_condition!(balls::Vector{MovableBall{N,T}}, box) where {N,T}

	U = Uniform.(box.lower .+ balls[1].r, box.upper .- balls[1].r)
	balls[1].x = rand.(U)

	for i in 2:length(balls)
		U = Uniform.(box.lower .+ balls[i].r, box.upper .- balls[i].r)
		balls[i].x = rand.(U)

		count = 0

		while overlap(balls[i], balls[1:i-1])
			balls[i].x = rand.(U)
			count += 1

			count > 10^5 && error("Unable to place disc $i")
		end
	end

	# velocities with sum(v_i^2) = 1
	for i in 1:length(balls)
		balls[i].v = @SVector randn(N)
	end

	sumsq = sum(normsq(balls[i].v) for i in 1:length(balls))

	for i in 1:length(balls)
		balls[i].v /= sqrt(sumsq)
	end

end


function find_collision(balls, box)

	partner1 = -1
	partner2 = -1
	min_collision_time = Inf
	collision_type = :none

	for i in 1:length(balls)
		wall, t = collision(balls[i], box)

		if t < min_collision_time
			partner1 = i
			partner2 = wall
			collision_type = :wall_collision
			min_collision_time = t
		end
	end

	for i in 1:length(balls)
		for j in i+1:length(balls)
			t = collision_time(balls[i], balls[j])

			if t < min_collision_time
				partner1 = i
				partner2 = j
				collision_type = :disc_collision
				min_collision_time = t
			end
		end
	end

	return partner1, partner2, collision_type, min_collision_time
end

find_collision(fluid::HardSphereFluid) = find_collision(fluid.balls, fluid.box)

function find_collision!(fluid::HardSphereFluid)
	partner1, partner2, collision_type, min_collision_time = find_collision(fluid)

	fluid.partner1 = partner1
	fluid.partner2 = partner2
	fluid.collision_type = collision_type
	fluid.next_collision_time += min_collision_time
end


"Carry out collision assuming already at moment of collision"
function collide!(fluid::HardSphereFluid)

	@unpack balls, box, partner1, partner2, collision_type = fluid

	if collision_type == :wall_collision
		collide!(balls[partner1], box.walls[partner2])

	elseif collision_type == :disc_collision
		collide!(balls[partner1], balls[partner2])

	else
		error("No collision")
	end

end



function HardSphereFluid{N,T}(box::RectangularBox{N,T}, balls::Vector{MovableBall{N,T}}) where {N,T}
	partner1, partner2, collision_type, min_collision_time = find_collision(balls, box)
	current_time = zero(T)

	return HardSphereFluid{N,T}(box, balls, current_time, min_collision_time, partner1, partner2, collision_type)

end



function HardSphereFluid{N,T}(box::RectangularBox{N,T}, num_balls, r) where {N,T}

	balls = [MovableBall(zero(SVector{N,T}), zero(SVector{N,T}), r) for i in 1:num_balls]
	initial_condition!(balls, box)

	return HardSphereFluid{N,T}(box, balls)
end

HardSphereFluid{N,T}(num_balls, r) where {N,T} = HardSphereFluid{N,T}(unit_hypercube(N, T), num_balls, r)

HardSphereFluid(N, num_balls, r) = HardSphereFluid{N,Float64}(num_balls, r)




function flow!(balls::Vector{<:MovableBall}, t)
	for ball in balls
		flow!(ball, t)
	end
end



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
