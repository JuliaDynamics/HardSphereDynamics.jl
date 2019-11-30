"""
Hard sphere fluid in N dimensions
"""
mutable struct HardSphereFluid{N,T}
	box::RectangularBox{N,T}
	balls::Vector{MovableBall{N,T}}
end


#
# function HardSphereFluid(box::RectangularBox{N,T}, balls::Vector{MovableBall{N,T}}) where {N,T}
# 	partner1, partner2, collision_type, min_collision_time = find_collision(balls, box)
# 	current_time = zero(T)
#
# 	return HardSphereFluid{N,T}(box, balls, current_time, min_collision_time, partner1, partner2, collision_type)
#
# end



function HardSphereFluid{N,T}(box::RectangularBox{N,T}, num_balls, r) where {N,T}

	balls = [MovableBall(zero(SVector{N,T}), zero(SVector{N,T}), r) for i in 1:num_balls]

	return HardSphereFluid{N,T}(box, balls)
end





HardSphereFluid(N, num_balls, r) = HardSphereFluid{N,Float64}(unit_hypercube(N, Float64), num_balls, r)
