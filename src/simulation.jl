struct HardSphereSimulation{N, T,
                            F<:HardSphereFluid{N,T},
                            H<:AbstractEventHandler,
                            L<:AbstractFlowDynamics,
                            C<:AbstractCollisionDynamics}
    fluid::F
    handler::H
    flow_dynamics::L
    collision_dynamics::C
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





function flow!(balls::Vector{<:MovableBall}, t, flow_type::AbstractFlowDynamics)
	for ball in balls
		flow!(ball, t, flow_type)
	end
end
