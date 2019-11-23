abstract type EventHandler end

struct AllToAll <: EventHandler
    current_time::T
    next_collision_time::T
    partner1::Int
    partner2::Int
    collision_type::Symbol
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
