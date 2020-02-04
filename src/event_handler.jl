abstract type AbstractEventHandler{T} end

mutable struct AllToAll{T} <: AbstractEventHandler{T}
    next_collision_time::T
    partner1::Int
    partner2::Int
    collision_type::Symbol
end

AllToAll{T}() where {T} = AllToAll{T}(0, -1, -1, :none)

function AllToAll(fluid::HardSphereFluid{N,T1,T2,T3}, flow_type) where {N,T1,T2,T3}
	event_handler = AllToAll{T2}()
	find_collision!(event_handler, fluid, flow_type)

	return event_handler
end

function find_collision(::AllToAll, balls, box, flow::AbstractFlowDynamics)

	partner1 = -1
	partner2 = -1
	min_collision_time = Inf
	collision_type = :none

	for i in 1:length(balls), j in 1:length(box.walls)

		t = collision_time(balls[i], box.walls[j], flow)

		if t < min_collision_time
			partner1 = i
			partner2 = j
			collision_type = :wall_collision
			min_collision_time = t
		end

	end

	for i in 1:length(balls), j in i+1:length(balls)

		t = collision_time(balls[i], balls[j], flow)

		if t < min_collision_time
			partner1 = i
			partner2 = j
			collision_type = :disc_collision
			min_collision_time = t
		end

	end

	return partner1, partner2, collision_type, min_collision_time
end


find_collision(event_handler, fluid::HardSphereFluid, flow_type) = find_collision(event_handler, fluid.balls, fluid.box, flow_type)


function find_collision!(event_handler::AllToAll, fluid::HardSphereFluid, flow_type)
	partner1, partner2, collision_type, min_collision_time = find_collision(event_handler, fluid, flow_type)

	event_handler.partner1 = partner1
	event_handler.partner2 = partner2
	event_handler.collision_type = collision_type
	event_handler.next_collision_time += min_collision_time
end
