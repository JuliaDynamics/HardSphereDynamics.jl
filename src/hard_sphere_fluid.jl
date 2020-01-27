"""
Hard sphere fluid in N dimensions
"""
mutable struct HardSphereFluid{N,T1,T2,T3}
	box::RectangularBox{N,T1}
	balls::Vector{MovableBall{N,T2,T3}}
end


#
# function HardSphereFluid(box::RectangularBox{N,T}, balls::Vector{MovableBall{N,T}}) where {N,T}
# 	partner1, partner2, collision_type, min_collision_time = find_collision(balls, box)
# 	current_time = zero(T)
#
# 	return HardSphereFluid{N,T}(box, balls, current_time, min_collision_time, partner1, partner2, collision_type)
#
# end



function HardSphereFluid{N,T}(box::RectangularBox{N}, num_balls, r) where {N,T}

	balls = [MovableBall(zero(SVector{N,T}), zero(SVector{N,T}), r) for i in 1:num_balls]

	return HardSphereFluid(box, balls)
end





HardSphereFluid(N, num_balls, r) = HardSphereFluid{N,Float64}(unit_hypercube(N, Float64), num_balls, r)


# construct a new hard-sphere fluid with given state
# state is vector of positions and vector of velocities
# this creates a fluid of a different *type* in general
function HardSphereFluid(fluid::HardSphereFluid, state)
	balls = fluid.balls
	positions, velocities = state

	new_balls = [MovableBall(positions[i], velocities[i], balls[i].r, balls[i].m) for i in 1:length(balls)]

	return HardSphereFluid(fluid.box, new_balls)
end


function state(fluid::HardSphereFluid)
	return vcat([b.x for b in fluid.balls],
				[b.v for b in fluid.balls])
end

function update!(fluid::HardSphereFluid, state)
	balls = fluid.balls
	num_balls = length(balls)

	for i in 1:num_balls
		balls[i].x = state[i]
	end

	for i in 1:num_balls
		balls[i].v = state[i + num_balls]
	end
end
